{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.codex;

  tomlFormat = pkgs.formats.toml { };
  python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.tomlkit ]);

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
      package = pkgs.codex;
      enableMcpIntegration = false; # We manage config.toml ourselves to keep it writable
    };

    home.activation.copyCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      configDir="$HOME/.codex"
      configFile="$configDir/config.toml"
      baseConfig="${baseConfigToml}"

      mkdir -p "$configDir"

      if [ -f "$configFile" ] && [ ! -L "$configFile" ]; then
        ${python}/bin/python3 - "$baseConfig" "$configFile" <<'PY'
      import os
      import sys
      import tempfile

      import tomlkit

      base_file, current_file = sys.argv[1:]

      with open(base_file, encoding="utf-8") as stream:
          base = tomlkit.load(stream)

      with open(current_file, encoding="utf-8") as stream:
          current = tomlkit.load(stream)

      if "mcp_servers" in base:
          current["mcp_servers"] = base["mcp_servers"]
      else:
          current.pop("mcp_servers", None)

      file_descriptor, temporary_file = tempfile.mkstemp(
          dir=os.path.dirname(current_file),
          prefix=".config.toml.",
      )
      try:
          with os.fdopen(file_descriptor, "w", encoding="utf-8") as stream:
              tomlkit.dump(current, stream)
              stream.flush()
              os.fsync(stream.fileno())
          os.chmod(temporary_file, 0o600)
          os.replace(temporary_file, current_file)
      finally:
          if os.path.exists(temporary_file):
              os.unlink(temporary_file)
      PY
      else
        rm -f "$configFile"
        install -m 600 "$baseConfig" "$configFile"
      fi
    '';
  };
}
