{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.opencode;
in
{
  options.internal.opencode = {
    enable = mkEnableOption "OpenCode configuration";
  };

  config = mkIf cfg.enable {
    # This module manages the OpenCode config and mirrors the Gemini MCP setup.
    # Sensitive values should be injected via environment variables at runtime.
    home.file.".config/opencode/opencode.json" = {
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        instructions = [
          "AGENTS.md"
          "CONTEXT.md"
        ];
        plugin = [
          "opencode-snip@latest"
          "@tarquinen/opencode-dcp@latest"
          "@0xsero/open-queue"
          "opencode-websearch-cited@1.1.1"
        ];
        mcp = {
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
            headers = {
              "CONTEXT7_API_KEY" = "{env:CONTEXT7_API_KEY}";
              "Accept" = "application/json, text/event-stream";
            };
          };
          github = {
            type = "remote";
            url = "https://api.githubcopilot.com/mcp/";
            headers = {
              "Authorization" = "Bearer {env:GITHUB_TOKEN}";
            };
          };
          "microsoft learn" = {
            type = "remote";
            url = "https://learn.microsoft.com/api/mcp";
          };
          nixos = {
            type = "local";
            command = [
              "uvx"
              "mcp-nixos"
            ];
          };
          nuget = {
            type = "local";
            command = [
              "podman"
              "run"
              "-i"
              "--rm"
              "ghcr.io/dimonsmart/nugetmcpserver:latest"
            ];
          };
          nuxt-ui = {
            type = "remote";
            url = "https://ui.nuxt.com/mcp";
          };
          playwright = {
            type = "local";
            command = [
              "podman"
              "run"
              "-i"
              "--rm"
              "--init"
              "-v"
              "{env:PWD}:/data:Z"
              "--pull=always"
              "mcr.microsoft.com/playwright/mcp"
              "--allow-unrestricted-file-access"
            ];
          };
          serena = {
            type = "local";
            command = [
              "nix"
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
          };
        };
      };
      force = true;
    };
  };
}
