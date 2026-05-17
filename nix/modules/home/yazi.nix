{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
    settings = {
      yazi = {
        manager = {
          show_hidden = true;
          sort_by = "mtime";
          sort_reverse = true;
        };
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
}
