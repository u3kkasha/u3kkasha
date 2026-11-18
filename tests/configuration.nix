{
  pkgs,
  lib,
  internal,
  nixosConfigurations,
}:
let
  inherit (nixosConfigurations) nixos nixos-wsl;
  homeConfig = nixos.config.home-manager.users.${internal.username};
  mcpServers = homeConfig.programs.mcp.servers;
  localMcpServers = lib.filterAttrs (
    _: server: server ? command && server.command != null
  ) mcpServers;

  testResults = lib.runTests {
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
      python3 ${./test_codex_merge.py} ${../modules/home/codex-merge.py}
      touch "$out"
    ''
else
  throw "Configuration tests failed: ${builtins.toJSON testResults}"
