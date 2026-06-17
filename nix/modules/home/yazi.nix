{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.yazi;
in
{
  options.internal.yazi = {
    enable = mkEnableOption "Yazi terminal file manager configuration";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      shellWrapperName = "y";
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "mtime";
          sort_reverse = true;
        };
      };
    };

    home.packages = with pkgs; [
      ffmpeg
      p7zip
      poppler-utils
      resvg
      imagemagick
    ];
  };
}
