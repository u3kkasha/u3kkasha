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

  # The pinned Serena release uses the MCP SDK v1 FastMCP API; nixpkgs' mcp now points to v2.
  serena =
    inputs.mcp-servers-nix.packages.${pkgs.stdenv.hostPlatform.system}.serena.overridePythonAttrs
      (oldAttrs: {
        dependencies = (lib.filter (dependency: lib.getName dependency != "mcp") oldAttrs.dependencies) ++ [
          pkgs.python3Packages.mcp_1
        ];
        makeWrapperArgs = (oldAttrs.makeWrapperArgs or [ ]) ++ [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath [ pkgs.nixd ])
        ];
      });
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
      package = serena;
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
    };
  };
}
