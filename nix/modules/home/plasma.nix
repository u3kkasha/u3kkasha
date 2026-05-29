{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.internal.plasma;
in
{
  options.internal.plasma = {
    enable = lib.mkEnableOption "KDE Plasma configuration via plasma-manager";
  };

  config = lib.mkIf cfg.enable {
    programs.plasma = {
      enable = true;

      workspace = {
        clickItemTo = "select"; # Double click to open
        lookAndFeel = "org.kde.breezedark.desktop";
        cursor.theme = "Bibata-Modern-Ice";
        iconTheme = "Papirus-Dark";
      };

      configFile.kdeglobals.General.terminalApplication = "ghostty";

      hotkeys.commands."launch-ghostty" = {
        name = "Launch Ghostty";
        key = "Meta+Return";
        command = "ghostty";
      };

      shortcuts = {
        "services/org.kde.krunner.desktop"."_launch" = [
          "Alt+Space"
          "Meta+Space"
        ];
        "kwin" = {
          "Window Maximize" = "Meta+Up";
          "Window Minimize" = "Meta+Down";
          "Window Close" = "Meta+Q";
          "Window One Desktop to the Left" = "Meta+Ctrl+Left";
          "Window One Desktop to the Right" = "Meta+Ctrl+Right";
        };
      };

      panels = [
        # Main top panel
        {
          location = "top";
          height = 36;
          floating = true;
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General.icon = "nix-snowflake-white";
              };
            }
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.systemtray"
          ];
        }
        # Centered bottom dock-like taskbar
        {
          location = "bottom";
          height = 48;
          lengthMode = "fit";
          floating = true;
          alignment = "center";
          widgets = [
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General.launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:ghostty.desktop"
                  "applications:firefox.desktop"
                ];
              };
            }
          ];
        }
      ];

      window-rules = [
        {
          description = "Ghostty opacity";
          match = {
            window-class = {
              value = "com.mitchellh.ghostty";
              type = "substring";
            };
          };
          apply = {
            opacityactive = 90;
            opacityinactive = 80;
          };
        }
      ];
    };

    home.packages = with pkgs; [
      papirus-icon-theme
      bibata-cursors
    ];
  };
}
