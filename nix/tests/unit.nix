{
  pkgs,
  lib,
  nixosConfigurations,
}:
let
  inherit (lib) internal;
  inherit (nixosConfigurations) nixos nixos-wsl;
  homeConfig = nixos.config.home-manager.users.${internal.username};
  wslHomeConfig = nixos-wsl.config.home-manager.users.${internal.username};
  mcpServers = homeConfig.programs.mcp.servers;
  nixdConfig = builtins.fromJSON (
    builtins.readFile homeConfig.xdg.configFile."nixd/config.json".source
  );
  discoveredPaths =
    root: map (path: lib.removePrefix "${toString root}/" (toString path)) (internal.scanPaths root);

  testResults = lib.runTests {
    testHomeScanPathsDiscoversModules = {
      expr = discoveredPaths ../modules/home;
      expected = [
        "antigravity.nix"
        "bash.nix"
        "cli.nix"
        "codex.nix"
        "direnv.nix"
        "ghostty.nix"
        "git.nix"
        "helix.nix"
        "mcp.nix"
        "niri.nix"
        "nixd.nix"
        "nushell.nix"
        "opencode.nix"
        "snip.nix"
        "utils.nix"
        "wlsunset.nix"
        "wsl.nix"
        "yazi.nix"
        "zellij.nix"
      ];
    };
    testNixosScanPathsDiscoversModules = {
      expr = discoveredPaths ../modules/nixos;
      expected = [
        "desktop"
        "docker"
        "gaming"
        "podman"
        "system"
      ];
    };
    testUsername = {
      expr = homeConfig.home.username;
      expected = internal.username;
    };
    testDefaultEditor = {
      expr = {
        inherit (homeConfig.home.sessionVariables) EDITOR VISUAL;
      };
      expected = {
        EDITOR = internal.defaultEditor;
        VISUAL = internal.defaultEditor;
      };
    };
    testEmailFormat = {
      expr = builtins.match "[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+" internal.email != null;
      expected = true;
    };
    testNixosHostName = {
      expr = nixos.config.networking.hostName;
      expected = "nixos";
    };
    testNixosStateVersion = {
      expr = nixos.config.system.stateVersion;
      expected = internal.systemStateVersion;
    };
    testThemeFlavor = {
      expr = homeConfig.catppuccin.flavor;
      expected = internal.themeFlavor;
    };
    testContainerRuntimeExclusivity = {
      expr =
        builtins.all
          (host: !(host.config.virtualisation.docker.enable && host.config.virtualisation.podman.enable))
          [
            nixos
            nixos-wsl
          ];
      expected = true;
    };
    testContainerGroupMembership = {
      expr = {
        nixos = lib.unique nixos.config.users.users.${internal.username}.extraGroups;
        wsl = lib.unique nixos-wsl.config.users.users.${internal.username}.extraGroups;
      };
      expected = {
        nixos = [
          "wheel"
          "podman"
        ];
        wsl = [
          "wheel"
          "podman"
        ];
      };
    };
    testNixTrustIsRootOnly = {
      expr = {
        nixos = lib.unique nixos.config.nix.settings.trusted-users;
        wsl = lib.unique nixos-wsl.config.nix.settings.trusted-users;
      };
      expected = {
        nixos = [ "root" ];
        wsl = [ "root" ];
      };
    };
    testNixdUsesLockedFlake = {
      expr =
        let
          expressions = [
            nixdConfig.nixd.nixpkgs.expr
            nixdConfig.nixd.options.nixos.expr
            nixdConfig.nixd.options.home-manager.expr
          ];
        in
        builtins.all (
          expression:
          builtins.match ".*<nixpkgs>.*" expression == null
          && builtins.match ".*\\.\\./\\.\\..*" expression == null
          && builtins.match ".*(/nix/store/|source).*" expression != null
        ) expressions;
      expected = true;
    };
    testMcpRegistry = {
      expr = builtins.attrNames mcpServers;
      expected = [
        "context7"
        "gh-grep"
        "github"
        "microsoft-learn"
        "nixos"
        "nushell"
        "nuxt"
        "nuxt-ui"
        "playwright"
        "semble"
        "serena"
      ];
    };
    testPackagedMcpServers = {
      expr = builtins.all (name: lib.hasPrefix "/nix/store/" mcpServers.${name}.command) [
        "github"
        "nixos"
        "playwright"
        "semble"
        "serena"
      ];
      expected = true;
    };
    testMcpCommandsAvoidRuntimeResolvers = {
      expr =
        let
          resolverNames = [
            "bunx"
            "dnx"
            "npx"
            "pipx"
            "pnpx"
            "uvx"
          ];
          localServers = lib.filterAttrs (_: server: server ? command && server.command != null) mcpServers;
        in
        builtins.all (server: !(builtins.elem (builtins.baseNameOf server.command) resolverNames)) (
          builtins.attrValues localServers
        );
      expected = true;
    };
    testAgentPackages = {
      expr = {
        antigravity = homeConfig.programs.antigravity-cli.package.pname;
        codex = homeConfig.programs.codex.package.pname;
        opencode = homeConfig.programs.opencode.package.pname;
      };
      expected = {
        antigravity = "antigravity-cli";
        codex = "codex";
        opencode = "opencode";
      };
    };
    testWslHostName = {
      expr = nixos-wsl.config.networking.hostName;
      expected = "nixos-wsl";
    };
    testWslEnabled = {
      expr = nixos-wsl.config.internal.wsl.enable;
      expected = true;
    };
    testWslHomeManagerUser = {
      expr = nixos-wsl.config.home-manager.users.${internal.username}.internal.wsl.enable;
      expected = true;
    };
    testWslGuiDisabled = {
      expr = wslHomeConfig.internal.gui.enable;
      expected = false;
    };
    testWslClosureExcludesGuiPackages = {
      expr =
        let
          packageNames = map lib.getName wslHomeConfig.home.packages;
        in
        builtins.all (name: !(builtins.elem name packageNames)) [
          "ghostty"
          "niri"
          "wlsunset"
        ];
      expected = true;
    };
  };
in
if testResults == [ ] then
  pkgs.runCommand "unit-tests"
    {
      nativeBuildInputs = [
        (pkgs.python3.withPackages (pythonPackages: [ pythonPackages.tomlkit ]))
      ];
    }
    ''
      base="$TMPDIR/base.toml"
      current="$TMPDIR/current.toml"

      printf '%s\n' \
        '[mcp_servers.locked]' \
        'command = "/nix/store/locked/bin/server"' \
        > "$base"
      printf '%s\n' \
        'model = "user-choice"' \
        '[mcp_servers.stale]' \
        'command = "npx"' \
        > "$current"

      python3 ${../modules/home/codex-merge.py} "$base" "$current"
      python3 - "$current" <<'PY'
      import sys
      import tomlkit

      with open(sys.argv[1], encoding="utf-8") as stream:
          merged = tomlkit.load(stream)

      assert merged["model"] == "user-choice"
      assert list(merged["mcp_servers"]) == ["locked"]
      assert merged["mcp_servers"]["locked"]["command"].startswith("/nix/store/")
      PY

      touch "$out"
    ''
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
