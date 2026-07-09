{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.codex;
  package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  tomlFormat = pkgs.formats.toml { };
  python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.tomlkit ]);
  mergeCodexConfig = pkgs.writeShellScript "merge-codex-config" ''
    exec ${python}/bin/python3 ${./codex-merge.py} "$@"
  '';

  # Replicate the transform/merge of MCP servers from programs.codex module:
  transformedMcpServers = lib.optionalAttrs config.programs.mcp.enable (
    lib.mapAttrs (
      name: server:
      lib.hm.mcp.transformMcpServer {
        inherit server;
        exclude = [
          "headers"
          "type"
        ];
        extraTransforms = [
          (s: s // lib.optionalAttrs (s.headers or { } != { }) { http_headers = s.headers; })
          lib.hm.mcp.addType
          (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; })
        ];
      }
    ) config.programs.mcp.servers
  );

  # Base Codex config.toml settings generated from Nix
  baseConfigToml = tomlFormat.generate "codex-base-config" (
    lib.optionalAttrs (transformedMcpServers != { }) { mcp_servers = transformedMcpServers; }
  );
in
{
  options.internal.codex = {
    enable = mkEnableOption "codex AI agent configuration";
  };

  config = mkIf cfg.enable {
    programs.codex = {
      enable = true;
      inherit package;
      enableMcpIntegration = false; # We manage config.toml ourselves to keep it writable
    };

    home.activation.copyCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      configDir="$HOME/.codex"
      configFile="$configDir/config.toml"
      baseConfig="${baseConfigToml}"

      mkdir -p "$configDir"

      if [ -f "$configFile" ] && [ ! -L "$configFile" ]; then
        ${mergeCodexConfig} "$baseConfig" "$configFile"
      else
        rm -f "$configFile"
        install -m 600 "$baseConfig" "$configFile"
      fi
    '';
  };
}
