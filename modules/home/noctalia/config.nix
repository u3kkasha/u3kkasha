_: {
  programs.noctalia = {
    enable = true;
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
    };
  };
}
