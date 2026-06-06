{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.antigravity;
in
{
  options.internal.antigravity = {
    enable = mkEnableOption "Antigravity CLI configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (import inputs.nixpkgs-master {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }).antigravity-cli
    ];

    home.file.".gemini/antigravity-cli/mcp_config.json" = {
      text = builtins.toJSON {
        mcpServers = {
          context7 = {
            serverUrl = "https://mcp.context7.com/mcp";
            headers = {
              "CONTEXT7_API_KEY" = "$CONTEXT7_API_KEY";
              "Accept" = "application/json, text/event-stream";
            };
          };
          github = {
            serverUrl = "https://api.githubcopilot.com/mcp/";
            headers = {
              "Authorization" = "Bearer $GITHUB_TOKEN";
            };
          };
          "microsoft learn" = {
            serverUrl = "https://learn.microsoft.com/api/mcp";
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
            serverUrl = "https://ui.nuxt.com/mcp";
          };
          playwright = {
            args = [
              "run"
              "-i"
              "--rm"
              "--init"
              "-v"
              ".:/data:Z"
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
      };
      force = true;
    };
  };
}
