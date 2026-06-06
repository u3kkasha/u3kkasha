{ pkgs, lib }:
let
  # Use the internal lib passed from flake.nix for consistency
  inherit (lib) internal;

  # Simple pure-Nix unit tests using lib.runTests
  testResults = lib.runTests {
    testUsername = {
      expr = internal.username;
      expected = "ukasha";
    };
    testDefaultEditor = {
      expr = internal.defaultEditor;
      expected = "hx";
    };
    testEmailFormat = {
      expr = lib.strings.isString internal.email;
      expected = true;
    };
    testOpenCodeContext7Type = {
      expr = internal.mcp.openCodeMcp.context7.type;
      expected = "remote";
    };
    testOpenCodeContext7Url = {
      expr = internal.mcp.openCodeMcp.context7.url;
      expected = "https://mcp.context7.com/mcp";
    };
    testOpenCodeContext7HeaderKey = {
      expr = internal.mcp.openCodeMcp.context7.headers.CONTEXT7_API_KEY;
      expected = "{env:CONTEXT7_API_KEY}";
    };
    testOpenCodePlaywrightCommand = {
      expr = internal.mcp.openCodeMcp.playwright.command;
      expected = [
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
    testAntigravityContext7ServerUrl = {
      expr = internal.mcp.antigravityMcp.context7.serverUrl;
      expected = "https://mcp.context7.com/mcp";
    };
    testAntigravityContext7HeaderKey = {
      expr = internal.mcp.antigravityMcp.context7.headers.CONTEXT7_API_KEY;
      expected = "$CONTEXT7_API_KEY";
    };
    testAntigravityGithubCommand = {
      expr = internal.mcp.antigravityMcp.github.command;
      expected = "podman";
    };
    testAntigravityGithubEnvToken = {
      expr = internal.mcp.antigravityMcp.github.env.GITHUB_PERSONAL_ACCESS_TOKEN;
      expected = "$GITHUB_TOKEN";
    };
    testAntigravityPlaywrightCommand = {
      expr = internal.mcp.antigravityMcp.playwright.command;
      expected = "podman";
    };
    testAntigravityPlaywrightArgs = {
      expr = internal.mcp.antigravityMcp.playwright.args;
      expected = [
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
    };
  };
in
if testResults == [ ] then
  pkgs.runCommand "unit-tests" { } "touch $out"
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
