{ config, ... }:

{
  programs.mcp = {
    enable = true;
    servers = {
      dotnet-debugger = {
        command = "dnx";
        args = [
          "-y"
          "debug-mcp"
        ];
      };

      context7 = {
        url = "https://mcp.context7.com/mcp";
        headers = {
          "Accept" = "application/json, text/event-stream";
        };
      };

      gh-grep = {
        url = "https://mcp.grep.app";
      };

      github = {
        command = "podman";
        args = [
          "run"
          "-i"
          "--rm"
          "-e"
          "GITHUB_PERSONAL_ACCESS_TOKEN"
          "ghcr.io/github/github-mcp-server"
        ];
        env = {
          "GITHUB_PERSONAL_ACCESS_TOKEN" = {
            file = "${config.home.homeDirectory}/.config/github/token";
          };
        };
      };

      microsoft-learn = {
        url = "https://learn.microsoft.com/api/mcp";
      };

      nixos = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };

      semble = {
        command = "uvx";
        args = [
          "--from"
          "semble[mcp]"
          "semble"
        ];
      };

      nuget = {
        command = "podman";
        args = [
          "run"
          "-i"
          "--rm"
          "ghcr.io/dimonsmart/nugetmcpserver:latest"
        ];
      };

      nushell = {
        command = "nu";
        args = [ "--mcp" ];
      };

      nuxt = {
        url = "https://nuxt.com/mcp";
      };

      nuxt-ui = {
        url = "https://ui.nuxt.com/mcp";
      };

      playwright = {
        command = "podman";
        args = [
          "run"
          "-i"
          "--rm"
          "--init"
          "--pull=always"
          "--network=host"
          "mcr.microsoft.com/playwright/mcp"
          "--allow-unrestricted-file-access"
        ];
      };

      serena = {
        command = "nix";
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
      };
    };
  };
}
