{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) getExe getExe';
  semble = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.semble;
in
{
  # Packaged MCP servers. mcp-servers-nix evaluates these modules and merges
  # their generated commands into Home Manager's shared programs.mcp registry.
  mcp-servers.programs = {
    github = {
      enable = true;
      passwordCommand.GITHUB_PERSONAL_ACCESS_TOKEN = [
        (getExe config.programs.gh.package)
        "auth"
        "token"
      ];
    };

    nixos.enable = true;

    playwright.enable = true;

    serena = {
      enable = true;
      context = "ide-assistant";
      enableWebDashboard = false;
      extraPackages = [
        pkgs.nixd
      ];
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      # Hosted MCP servers remain remote: there is no local runtime to pin.
      context7 = {
        url = "https://mcp.context7.com/mcp";
        headers.Accept = "application/json, text/event-stream";
      };

      gh-grep.url = "https://mcp.grep.app";

      microsoft-learn.url = "https://learn.microsoft.com/api/mcp";

      nuxt.url = "https://nuxt.com/mcp";
      nuxt-ui.url = "https://ui.nuxt.com/mcp";

      # Semble is packaged by llm-agents.nix and exposes a dedicated MCP entry
      # point, so it needs no Python environment or runtime dependency resolver.
      semble.command = getExe' semble "semble-mcp";

      # These MCP servers are not packaged by either integrated flake. Pin their
      # ecosystem package versions so upgrades remain explicit and reviewable.
      dotnet-debugger = {
        command = getExe' pkgs.dotnet-sdk_10 "dnx";
        args = [
          "debug-mcp@0.19.0"
          "--yes"
        ];
      };

      nuget = {
        command = getExe' pkgs.dotnet-sdk_10 "dnx";
        args = [
          "NuGet.Mcp.Server@1.4.16"
          "--yes"
        ];
      };

      skylos = {
        command = getExe' pkgs.uv "uvx";
        args = [
          "--from"
          "skylos==4.28.0"
          "python"
          "-m"
          "skylos_mcp.server"
        ];
      };

      nushell = {
        command = getExe config.programs.nushell.package;
        args = [ "--mcp" ];
      };
    };
  };
}
