{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.gnome;
in
{
  options.internal.gnome = {
    enable = mkEnableOption "GNOME configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-tweaks
      dconf-editor
      gnome-extension-manager

      # Extensions
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.dash-to-dock
      gnomeExtensions.caffeine
    ];

    # Basic GNOME configuration via dconf
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        show-battery-percentage = true;
        clock-show-weekday = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      "org/gnome/mutter" = {
        edge-tiling = true;
        center-new-windows = true;
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "blur-my-shell@aunetx"
          "just-perfection-desktop@just-perfection"
          "dash-to-dock@micxgx.gmail.com"
          "caffeine@patapon.info"
        ];
      };

      # Custom shortcuts
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Control><Alt>t";
        command = "ghostty";
        name = "Ghostty";
      };
    };
  };
}
