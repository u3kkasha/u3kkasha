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
    programs.antigravity-cli = {
      enable = true;
      package =
        (import inputs.nixpkgs-master {
          system = pkgs.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        }).antigravity-cli;

      mcpServers = lib.internal.mcp.antigravityMcp;
    };

    home.file.".gemini/antigravity-cli/mcp_config.json" = {
      text = builtins.toJSON { inherit (config.programs.antigravity-cli) mcpServers; };
      force = true;
    };

    home.file.".gemini/config/mcp_config.json".force = true;
  };
}
