{
  pkgs,
  lib,
  internal,
  nixosConfigurations,
}:
let
  inherit (nixosConfigurations) nixos nixos-wsl;
  homeConfig = nixos.config.home-manager.users.${internal.username};
  wslHomeConfig = nixos-wsl.config.home-manager.users.${internal.username};
  mcpServers = homeConfig.programs.mcp.servers;
  localMcpServers = lib.filterAttrs (
    _: server: server ? command && server.command != null
  ) mcpServers;
  codexUpstreamConfig = homeConfig.home.file.".codex/config.toml";
  expectedAgentInstructions = builtins.readFile ../modules/home/agent-instructions.md;
  niriConfig = builtins.readFile homeConfig.xdg.configFile."niri-config".source;
  hypridleConfig = builtins.readFile homeConfig.xdg.configFile."hypr/hypridle.conf".source;

  testResults = lib.runTests {
    testSystemStateVersions = {
      expr = map (host: host.config.system.stateVersion) [
        nixos
        nixos-wsl
      ];
      expected = [
        internal.systemStateVersion
        internal.systemStateVersion
      ];
    };
    testHomeStateVersions = {
      expr = map (config: config.home.stateVersion) [
        homeConfig
        wslHomeConfig
      ];
      expected = [
        internal.homeStateVersion
        internal.homeStateVersion
      ];
    };
    testCuratedNixSkillsAndCodexSkillSources = {
      expr =
        map
          (config: {
            nixSkillAgents = config.programs.nix-skills.agents;
            nixSkills = config.programs.nix-skills.skills;
            codexHasPinnedSkills = builtins.all (name: builtins.hasAttr name config.programs.codex.skills) [
              "modern-web-guidance"
              "nuxt-ui"
            ];
            codexSkillsHaveInstructions = builtins.all (skill: builtins.pathExists "${skill}/SKILL.md") (
              builtins.attrValues config.programs.codex.skills
            );
          })
          [
            homeConfig
            wslHomeConfig
          ];
      expected =
        map
          (_: {
            nixSkillAgents = [ "codex" ];
            nixSkills = [
              "nix-language"
              "nix-workflow"
              "nixpkgs-development"
              "nixos-operations"
              "home-manager"
              "devenv-project"
            ];
            codexHasPinnedSkills = true;
            codexSkillsHaveInstructions = true;
          })
          [
            1
            2
          ];
    };
    testContainerRuntimeUsesDocker = {
      expr = map (host: host.config.virtualisation.docker.enable) [
        nixos
        nixos-wsl
      ];
      expected = [
        true
        true
      ];
    };
    testDockerGroupMembership = {
      expr =
        builtins.all (host: builtins.elem "docker" host.config.users.users.${internal.username}.extraGroups)
          [
            nixos
            nixos-wsl
          ];
      expected = true;
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
    testNixTrustedUsers = {
      expr = {
        nixos = lib.unique nixos.config.nix.settings.trusted-users;
        wsl = lib.unique nixos-wsl.config.nix.settings.trusted-users;
      };
      expected = {
        nixos = [ "root" ];
        wsl = [
          "root"
          "ukasha"
        ];
      };
    };
    testLocalMcpServersUseStoreCommands = {
      expr = builtins.all (server: lib.hasPrefix "/nix/store/" server.command) (
        builtins.attrValues localMcpServers
      );
      expected = true;
    };
    testSharedAgentInstructions = {
      expr =
        map
          (config: {
            codexContext = builtins.readFile config.programs.codex.context;
            codexOutput = builtins.readFile config.home.file.".codex/AGENTS.md".source;
          })
          [
            homeConfig
            wslHomeConfig
          ];
      expected =
        map
          (_: {
            codexContext = expectedAgentInstructions;
            codexOutput = expectedAgentInstructions;
          })
          [
            1
            2
          ];
    };
    testNiriResumeUsesNativeCommand = {
      expr = lib.hasInfix "after_sleep_cmd = niri msg action power-on-monitors" hypridleConfig;
      expected = true;
    };
    testNiriPhysicalOutputIsHostOwned = {
      expr =
        homeConfig.internal.niri.outputConfig != ""
        && lib.hasInfix homeConfig.internal.niri.outputConfig niriConfig;
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

      touch "$out"
    ''
else
  throw "Configuration tests failed: ${builtins.toJSON testResults}"
