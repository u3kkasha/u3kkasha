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
  antigravityMcpConfig = homeConfig.home.file.".gemini/config/mcp_config.json";
  codexUpstreamConfig = homeConfig.home.file.".codex/config.toml";
  nixdConfigPath = builtins.toString homeConfig.xdg.configFile."nixd/config.json".source;
  niriConfig = builtins.readFile homeConfig.xdg.configFile."niri/config.kdl".source;
  hypridleConfig = builtins.readFile homeConfig.xdg.configFile."hypr/hypridle.conf".source;

  testResults = lib.runTests {
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
    testGlobalGitIdentityIsAbsent = {
      expr =
        builtins.all
          (
            settings:
            !(lib.hasAttrByPath [ "user" "name" ] settings) && !(lib.hasAttrByPath [ "user" "email" ] settings)
          )
          [
            homeConfig.programs.git.settings
            wslHomeConfig.programs.git.settings
          ];
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
    testContainerRuntimeUsesDocker = {
      expr =
        map
          (host: {
            docker = host.config.virtualisation.docker.enable;
            podman = host.config.virtualisation.podman.enable;
          })
          [
            nixos
            nixos-wsl
          ];
      expected = [
        {
          docker = true;
          podman = false;
        }
        {
          docker = true;
          podman = false;
        }
      ];
    };
    testContainerSystemPackagesExcludePodman = {
      expr =
        let
          packageNames = host: map lib.getName host.config.environment.systemPackages;
        in
        builtins.all
          (
            host:
            builtins.all (name: !(builtins.elem name (packageNames host))) [
              "podman"
              "podman-compose"
              "podman-tui"
            ]
          )
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
          "docker"
        ];
        wsl = [
          "wheel"
          "docker"
        ];
      };
    };
    testNixCachePolicy = {
      expr =
        map
          (host: {
            substituters = builtins.filter (
              url: url != "https://cache.nixos.org/"
            ) host.config.nix.settings.substituters;
            publicKeys = builtins.filter (
              key: !(lib.hasPrefix "cache.nixos.org-1:" key)
            ) host.config.nix.settings.trusted-public-keys;
          })
          [
            nixos
            nixos-wsl
          ];
      expected =
        map
          (_: {
            substituters = internal.cacheSubstituters;
            publicKeys = internal.cachePublicKeys;
          })
          [
            1
            2
          ];
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
      expr = lib.hasInfix "/nix/store/" nixdConfigPath && lib.hasInfix "nixd-config.json" nixdConfigPath;
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
    testCodexUsesDisabledUpstreamConfig = {
      expr = {
        inherit (codexUpstreamConfig) enable;
        sourceName = codexUpstreamConfig.source.name;
      };
      expected = {
        enable = false;
        sourceName = "codex-config";
      };
    };
    testAgentPackages = {
      expr = {
        codex = homeConfig.programs.codex.package.pname;
        opencode = homeConfig.programs.opencode.package.pname;
        specKit = lib.getName (
          lib.findFirst (package: lib.getName package == "spec-kit") null homeConfig.home.packages
        );
      };
      expected = {
        codex = "codex";
        opencode = "opencode";
        specKit = "spec-kit";
      };
    };
    testOpenCodeUsesSpecKitContext = {
      expr = homeConfig.programs.opencode.settings.instructions;
      expected = [
        "AGENTS.md"
        ".specify/memory/constitution.md"
        ".specify/memory/current-system.md"
      ];
    };
    testDuckDbCliPackage = {
      expr = builtins.any (package: lib.getName package == "duckdb") homeConfig.home.packages;
      expected = true;
    };
    testAntigravityCliIntegration = {
      expr =
        map
          (config: {
            inherit (config.programs.antigravity-cli) enable enableMcpIntegration;
            package = config.programs.antigravity-cli.package.pname;
          })
          [
            homeConfig
            wslHomeConfig
          ];
      expected = [
        {
          enable = true;
          enableMcpIntegration = true;
          package = "antigravity-cli";
        }
        {
          enable = true;
          enableMcpIntegration = true;
          package = "antigravity-cli";
        }
      ];
    };
    testAntigravityCliMcpRegistry = {
      expr = map (config: builtins.attrNames config.programs.antigravity-cli.mcpServers) [
        homeConfig
        wslHomeConfig
      ];
      expected = map (_: builtins.attrNames mcpServers) [
        1
        2
      ];
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
    testNiriResumeUsesNativeCommand = {
      expr =
        lib.hasInfix "after_sleep_cmd = niri msg action power-on-monitors" hypridleConfig
        && !(lib.hasInfix "hyprctl" hypridleConfig);
      expected = true;
    };
    testNiriPhysicalOutputIsHostOwned = {
      expr =
        lib.hasInfix ''output "eDP-1"'' niriConfig
        && lib.hasInfix ''mode "1920x1080@60.000"'' niriConfig
        && lib.hasInfix ''output "eDP-1"'' homeConfig.internal.niri.outputConfig;
      expected = true;
    };
    testWslClosureExcludesGuiPackages = {
      expr =
        let
          packageNames = map lib.getName wslHomeConfig.home.packages;
        in
        !wslHomeConfig.home.pointerCursor.enable
        && builtins.all (name: !(builtins.elem name packageNames)) [
          "bibata-cursors"
          "ghostty"
          "niri"
          "wlsunset"
        ];
      expected = true;
    };
  };
in
if testResults == [ ] then
  pkgs.runCommand "configuration-tests"
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

      python3 - ${codexUpstreamConfig.source} <<'PY'
      import json
      import sys
      import tomlkit

      with open(sys.argv[1], encoding="utf-8") as stream:
          generated = tomlkit.load(stream)

      expected_servers = set(json.loads('${builtins.toJSON (builtins.attrNames mcpServers)}'))
      assert set(generated["mcp_servers"]) == expected_servers
      PY

      python3 - ${antigravityMcpConfig.source} <<'PY'
      import json
      import sys

      with open(sys.argv[1], encoding="utf-8") as stream:
          generated = json.load(stream)

      expected_servers = set(json.loads('${builtins.toJSON (builtins.attrNames mcpServers)}'))
      assert set(generated["mcpServers"]) == expected_servers
      assert generated["mcpServers"]["context7"]["serverUrl"] == "${mcpServers.context7.url}"
      assert "url" not in generated["mcpServers"]["context7"]
      PY

      touch "$out"
    ''
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
