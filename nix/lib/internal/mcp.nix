{ lib }:
let
  # The central repository of MCP server configurations.
  # Values use:
  # - `{env:VAR_NAME}` for environment variables
  # - `{PWD}` for the working directory placeholder (which resolves to `.` in Antigravity and `{env:PWD}` in OpenCode)
  servers = {
    "dotnet-debugger" = {
      type = "local";
      command = [
        "dnx"
        "-y"
        "debug-mcp"
      ];
    };

    context7 = {
      type = "remote";
      url = "https://mcp.context7.com/mcp";
      headers = {
        "CONTEXT7_API_KEY" = "{env:CONTEXT7_API_KEY}";
        "Accept" = "application/json, text/event-stream";
      };
    };
    gh_grep = {
      type = "remote";
      url = "https://mcp.grep.app";
    };
    github = {
      type = "local";
      command = [
        "podman"
        "run"
        "-i"
        "--rm"
        "-e"
        "GITHUB_PERSONAL_ACCESS_TOKEN"
        "ghcr.io/github/github-mcp-server"
      ];
      env = {
        "GITHUB_PERSONAL_ACCESS_TOKEN" = "{env:GITHUB_TOKEN}";
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
    nushell = {
      type = "local";
      command = [
        "nu"
        "--mcp"
      ];
    };
    nuxt = {
      type = "remote";
      url = "https://nuxt.com/mcp";
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
        "--network=host"
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
    stitch = {
      type = "remote";
      url = "https://stitch.googleapis.com/mcp";
      headers = {
        "X-Goog-Api-Key" = "{env:STITCH_API_KEY}";
      };
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
        // (lib.optionalAttrs (server ? env) {
          environment = lib.mapAttrs (_eName: replacer) server.env;
        })
      else
        throw "Unknown server type: ${server.type}"
    );

  toGemini =
    let
      replacer = s: replaceEnvVars (builtins.replaceStrings [ "{PWD}" ] [ "$PWD" ] s);
      serverName = name: builtins.replaceStrings [ "_" " " ] [ "-" "-" ] name;
    in
    lib.mapAttrs' (
      name: server:
      lib.nameValuePair (serverName name) (
        if server.type == "remote" then
          {
            httpUrl = server.url;
          }
          // (lib.optionalAttrs (server ? headers) {
            headers = lib.mapAttrs (_hName: replacer) server.headers;
          })
        else if server.type == "local" then
          {
            command = replacer (builtins.head server.command);
            args = map replacer (builtins.tail server.command);
          }
          // (lib.optionalAttrs (server ? env) {
            env = lib.mapAttrs (_eName: replacer) server.env;
          })
        else
          throw "Unknown server type: ${server.type}"
      )
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
        // (lib.optionalAttrs (server ? env) {
          env = lib.mapAttrs (_eName: replacer) server.env;
        })
      else
        throw "Unknown server type: ${server.type}"
    );
in
{
  inherit servers;
  openCodeMcp = toOpenCode servers;
  geminiMcp = toGemini servers;
  antigravityMcp = toAntigravity servers;
}
