{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.zellij;
in
{
  options.internal.zellij = {
    enable = mkEnableOption "Zellij terminal multiplexer configuration";
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        default_layout = "compact";
        pane_frames = false;
        default_shell = "${pkgs.nushell}/bin/nu";
      };
    };
  };
}
