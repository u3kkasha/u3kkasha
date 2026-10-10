{ config, ... }:
{
  programs.noctalia = {
    enable = true;
    checkConfig = true;
    systemd.enable = true;
    settings = {
      theme = {
        mode = "auto";
        shell_mode = "follow";
        source = "builtin";
        builtin = "Catppuccin";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "gtk3"
            "gtk4"
          ];
        };
      };
      location = {
        latitude = 23.8;
        longitude = 90.4;
      };
      backdrop = {
        enabled = false;
      };
      wallpaper = {
        enabled = true;
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        fill_mode = "crop";
        transition_on_startup = true;
        automation = {
          enabled = false;
          interval_seconds = 1800;
          order = "random";
          recursive = true;
        };
      };
    };
  };
}
