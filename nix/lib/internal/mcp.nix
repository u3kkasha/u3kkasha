{ lib }:
let
  # The central repository of MCP server configurations.
  # Values use:
  # - `{env:VAR_NAME}` for environment variables
  # - `{PWD}` for the working directory placeholder (which resolves to `.` in Antigravity and `{env:PWD}` in OpenCode)
  servers = {
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
        "{PWD}:/data:Z"
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

  # Helper to transform `{env:VAR}` placeholders into `$VAR`
  replaceEnvVars =
    s:
    let
      parts = builtins.split "[{]env:([a-zA-Z0-9_]+)[}]" s;
      process = part: if builtins.isList part then "$" + (builtins.head part) else part;
    in
    lib.concatStrings (map process parts);

  # Helper to transform configurations for OpenCode
  toOpenCode =
    let
      replacer = s: builtins.replaceStrings [ "{PWD}" ] [ "{env:PWD}" ] s;
    in
    lib.mapAttrs (
      _name: server:
      if server.type == "remote" then
        {
          type = "remote";
          inherit (server) url;
        }
        // (lib.optionalAttrs (server ? headers) {
          headers = lib.mapAttrs (_hName: replacer) server.headers;
        })
      else if server.type == "local" then
        {
          type = "local";
          command = map replacer server.command;
        }
      else
        throw "Unknown server type: ${server.type}"
    );

  # Helper to transform configurations for Antigravity
  toAntigravity =
    let
      replacer =
        s:
        let
          s' = builtins.replaceStrings [ "{PWD}" ] [ "." ] s;
        in
        replaceEnvVars s';
    in
    lib.mapAttrs (
      _name: server:
      if server.type == "remote" then
        {
          serverUrl = server.url;
        }
        // (lib.optionalAttrs (server ? headers) {
          headers = lib.mapAttrs (_hName: replacer) server.headers;
        })
      else if server.type == "local" then
        {
          command = replacer (builtins.head server.command);
          args = map replacer (builtins.tail server.command);
        }
      else
        throw "Unknown server type: ${server.type}"
    );
in
{
  inherit servers;
  openCodeMcp = toOpenCode servers;
  antigravityMcp = toAntigravity servers;
}
