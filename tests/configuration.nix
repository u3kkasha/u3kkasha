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
  codexUpstreamConfig = homeConfig.home.file.".codex/config.toml";

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
