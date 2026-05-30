{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.plasma;
in
{
  options.internal.plasma = {
    enable = mkEnableOption "KDE Plasma configuration via plasma-manager";
  };

  config = mkIf cfg.enable {
    programs.plasma = {
      enable = true;

      # Appearance
      workspace.lookAndFeel = "org.kde.breezedark.desktop";
      workspace.colorScheme = "BreezeDark";
      workspace.iconTheme = "breeze-dark";

      # Taskbar & Panels
      panels = [
        {
          location = "bottom";
          widgets = [
            "org.kde.plasma.kickoff"
            "org.kde.plasma.pager"
            "org.kde.plasma.icontasks"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.showdesktop"
          ];
        }
      ];

      # Taskbar configuration
      kwin.effects.blur.enable = true;
      kwin.effects.translucency.enable = true;

      shortcuts = {
        "services/org.kde.konsole.desktop" = {
          "_launch" = "none";
        };
        "services/com.mitchellh.ghostty.desktop" = {
          "_launch" = "Ctrl+Alt+T";
        };
      };
    };
  };
}
