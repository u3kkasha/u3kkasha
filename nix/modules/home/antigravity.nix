{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.antigravity;

  # Helper to transform {env:VAR} placeholders into $VAR for Antigravity CLI
  replaceEnvVars =
    s:
    let
      parts = builtins.split "[{]env:([a-zA-Z0-9_]+)[}]" s;
      process = part: if builtins.isList part then "$" + (builtins.head part) else part;
    in
    lib.concatStrings (map process parts);

  # Helper to transform the mcp servers to Antigravity's structure, bypassing HM's bug
  mapMcpServer =
    server:
    let
      isRemote = server.url != null;
    in
    if isRemote then
      {
        serverUrl = server.url;
      }
      // lib.optionalAttrs (server ? headers) {
        headers = lib.mapAttrs (_: replaceEnvVars) server.headers;
      }
    else
      {
        command = replaceEnvVars server.command;
      }
      // lib.optionalAttrs (server ? args) {
        args = map replaceEnvVars server.args;
      }
      // lib.optionalAttrs (server ? env) {
        env = lib.mapAttrs (_: replaceEnvVars) server.env;
      };
in
{
  options.internal.antigravity = {
    enable = mkEnableOption "Antigravity CLI configuration";
  };

  config = mkIf cfg.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = false; # Disable buggy upstream Home Manager integration
      mcpServers = lib.mapAttrs (_: mapMcpServer) config.programs.mcp.servers;
      package = pkgs.antigravity-cli;
    };
  };
}
