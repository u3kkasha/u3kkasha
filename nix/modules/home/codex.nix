{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.codex;
in
{
  options.internal.codex = {
    enable = mkEnableOption "codex AI agent configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.codex ];
  };
}
