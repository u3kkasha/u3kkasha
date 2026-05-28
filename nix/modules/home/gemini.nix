{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.gemini;
in
{
  options.internal.gemini = {
    enable = mkEnableOption "Gemini CLI configuration";
  };

  config = mkIf cfg.enable {
    # This module manages the gemini-cli settings and MCP servers.
    # Sensitive keys (like CONTEXT7_API_KEY) should be set via environment variables
    # or added to a local-only file.

    home.file.".gemini/settings.json" = {
      text = builtins.toJSON {
        context = {
          fileName = [
            "AGENTS.md"
            "CONTEXT.md"
            "GEMINI.md"
          ];
        };
        general = {
          preferredEditor = lib.internal.defaultEditor;
        };
        mcpServers = {
          context7 = {
            httpUrl = "https://mcp.context7.com/mcp";
            headers = {
              "CONTEXT7_API_KEY" = "$CONTEXT7_API_KEY";
              "Accept" = "application/json, text/event-stream";
            };
          };
          github = {
            httpUrl = "https://api.githubcopilot.com/mcp/";
            headers = {
              "Authorization" = "Bearer $GITHUB_TOKEN";
            };
          };
          "microsoft learn" = {
            httpUrl = "https://learn.microsoft.com/api/mcp";
          };
          nixos = {
            args = [ "mcp-nixos" ];
            command = "uvx";
          };
          nuget = {
            args = [
              "run"
              "-i"
              "--rm"
              "ghcr.io/dimonsmart/nugetmcpserver:latest"
            ];
            command = "podman";
          };
          nuxt-ui = {
            httpUrl = "https://ui.nuxt.com/mcp";
          };
          playwright = {
            args = [
              "run"
              "-i"
              "--rm"
              "--init"
              "-v"
              "$PWD:/data:Z"
              "--pull=always"
              "mcr.microsoft.com/playwright/mcp"
              "--allow-unrestricted-file-access"
            ];
            command = "podman";
          };
          serena = {
            args = [
              "run"
              "github:oraios/serena"
              "--"
              "start-mcp-server"
              "--project-from-cwd"
              "--context"
              "ide"
              "--open-web-dashboard"
              "false"
            ];
            command = "nix";
          };
        };
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
        };
      };
      # Setting force = true ensures your MCP servers are always synced from this file
      force = true;
    };
  };
}
