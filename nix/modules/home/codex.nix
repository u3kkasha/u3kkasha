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
      enableMcpIntegration = false; # We manage config.toml ourselves to keep it writable
    };

    home.activation.copyCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            configDir="$HOME/.codex"
            configFile="$configDir/config.toml"
            baseConfig="${baseConfigToml}"

            mkdir -p "$configDir"

            if [ -f "$configFile" ] && [ ! -L "$configFile" ]; then
              ${pkgs.python3}/bin/python3 -c '
      import sys, re

      base_file = sys.argv[1]
      current_file = sys.argv[2]

      with open(base_file, "r") as f:
          base_content = f.read()

      with open(current_file, "r") as f:
          current_content = f.read()

      # Find the [projects] section in the current file
      projects_matches = list(re.finditer(r"^\[projects(\.|\b)", current_content, re.MULTILINE))
      if projects_matches:
          start_idx = projects_matches[0].start()
          # Find the next section header starting with [ but not [projects
          next_section = re.search(r"^\[(?!projects)[^\]]+\]", current_content[start_idx:], re.MULTILINE)
          if next_section:
              projects_section = current_content[start_idx : start_idx + next_section.start()]
          else:
              projects_section = current_content[start_idx:]

          merged = base_content.rstrip() + "\n\n" + projects_section.strip() + "\n"
      else:
          merged = base_content

      with open(current_file, "w") as f:
          f.write(merged)
      ' "$baseConfig" "$configFile"
            else
              rm -f "$configFile"
              cp "$baseConfig" "$configFile"
              chmod +w "$configFile"
            fi
    '';
  };
}
