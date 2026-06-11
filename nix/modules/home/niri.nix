{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.niri;
in
{
  options.internal.niri = {
    enable = mkEnableOption "Niri configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."niri/config.kdl".text = ''
      input {
          keyboard {
              xkb {
                  layout "us,ara"
                  options "grp:win_space_toggle"
              }
          }
          touchpad {
              tap
              dwt
              natural-scroll
              scroll-factor 0.5
          }
      }

      output "eDP-1" {
          mode "1920x1080@60.000"
          scale 1.0
      }

      layout {
          gaps 16
          center-focused-column "never"
          default-column-width { proportion 0.5; }
      }

      spawn-at-startup "noctalia-shell"
      spawn-at-startup "nm-applet"
      spawn-at-startup "hypridle"
      spawn-at-startup "wlsunset" "-l" "23.8" "-L" "90.4"

      binds {
          Super+T { spawn "ghostty"; }
          Super+D { spawn "noctalia-shell" "--launcher"; }
          Super+Q { close-window; }
          Super+Shift+E { quit; }
          Super+L { spawn "hyprlock"; }

          XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
          XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
          XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

          XF86AudioPlay { spawn "playerctl" "play-pause"; }
          XF86AudioNext { spawn "playerctl" "next"; }
          XF86AudioPrev { spawn "playerctl" "previous"; }

          XF86MonBrightnessUp { spawn "brightnessctl" "set" "5%+"; }
          XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

          Print { spawn "grim" "-g" "$(slurp)" "- | wl-copy"; }

          Super+Left  { focus-column-left; }
          Super+Right { focus-column-right; }
          Super+Up    { focus-window-or-monitor-up; }
          Super+Down  { focus-window-or-monitor-down; }

          Super+Shift+Left  { move-column-left; }
          Super+Shift+Right { move-column-right; }

          Super+F { maximize-column; }
          Super+Shift+F { fullscreen-window; }
          Super+C { center-column; }

          Super+Minus { set-column-width "-10%"; }
          Super+Equal { set-column-width "+10%"; }
      }
    '';

    xdg.configFile."hypr/hypridle.conf".text = ''
      general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
      timeout = 300
      on-timeout = loginctl lock-session
      }

      listener {
      timeout = 330
      on-timeout = niri msg action power-off-monitors
      on-resume = niri msg action power-on-monitors
      }
    '';

    xdg.userDirs.enable = true;
  };
}
