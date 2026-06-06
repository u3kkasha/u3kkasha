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
        mcpServers = lib.internal.mcp.antigravityMcp;
      };
      force = true;
    };
  };
}
