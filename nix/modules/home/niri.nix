{
  lib,
  pkgs,
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
    home.packages = with pkgs; [
      hyprpicker
      cliphist
      wofi
    ];

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

      spawn-at-startup "noctalia"
      spawn-at-startup "nm-applet"
      spawn-at-startup "hypridle"
      spawn-at-startup "wlsunset" "-l" "23.8" "-L" "90.4"

      binds {
          // ═══════════════════════════════════════════════
          // Windows Key - Run / Launcher
          // ═══════════════════════════════════════════════
          // Win+R - Run dialog (like Windows Run)
          Super+R { spawn "noctalia" "msg" "panel-toggle" "launcher"; }

          // ═══════════════════════════════════════════════
          // Windows Common Shortcuts
          // ═══════════════════════════════════════════════
          Super+E { spawn "yazi"; }                           // Win+E - File Explorer
          Super+L { spawn "hyprlock"; }                       // Win+L - Lock screen
          Super+D { focus-workspace-previous; }               // Win+D - Show Desktop (toggle)
          Super+Tab { toggle-overview; }                      // Win+Tab - Task View
          Super+S { screenshot; }                             // Win+S - Snipping Tool

          // ═══════════════════════════════════════════════
          // App Launching
          // ═══════════════════════════════════════════════
          Super+T { spawn "ghostty"; }                        // Win+T - Terminal

          // ═══════════════════════════════════════════════
          // Window Management - Focus / Navigate
          // ═══════════════════════════════════════════════
          Super+Left  { focus-column-left; }                  // Win+Left  - Focus column left
          Super+Right { focus-column-right; }                 // Win+Right - Focus column right
          Super+Up    { focus-window-or-monitor-up; }         // Win+Up    - Focus window above
          Super+Down  { focus-window-or-monitor-down; }       // Win+Down  - Focus window below

          // ═══════════════════════════════════════════════
          // Window Management - Move
          // ═══════════════════════════════════════════════
          Super+Shift+Left  { move-column-left; }             // Move column left
          Super+Shift+Right { move-column-right; }            // Move column right
          Super+Shift+Up    { move-column-to-workspace-up; }  // Send column to workspace above
          Super+Shift+Down  { move-column-to-workspace-down; }// Send column to workspace below

          // ═══════════════════════════════════════════════
          // Virtual Desktop Switching (Win+Ctrl+Arrow)
          // ═══════════════════════════════════════════════
          Super+Ctrl+Left  { focus-workspace-down; }          // Prev workspace
          Super+Ctrl+Right { focus-workspace-up; }            // Next workspace

          // ═══════════════════════════════════════════════
          // Workspace Quick-Switch (Win+Number)
          // ═══════════════════════════════════════════════
          Super+1 { focus-workspace 1; }
          Super+2 { focus-workspace 2; }
          Super+3 { focus-workspace 3; }
          Super+4 { focus-workspace 4; }
          Super+5 { focus-workspace 5; }
          Super+6 { focus-workspace 6; }
          Super+7 { focus-workspace 7; }
          Super+8 { focus-workspace 8; }
          Super+9 { focus-workspace 9; }

          // ═══════════════════════════════════════════════
          // Move Window to Workspace (Win+Shift+Ctrl+N)
          // ═══════════════════════════════════════════════
          Super+Shift+Ctrl+1 { move-column-to-workspace 1; }
          Super+Shift+Ctrl+2 { move-column-to-workspace 2; }
          Super+Shift+Ctrl+3 { move-column-to-workspace 3; }
          Super+Shift+Ctrl+4 { move-column-to-workspace 4; }
          Super+Shift+Ctrl+5 { move-column-to-workspace 5; }
          Super+Shift+Ctrl+6 { move-column-to-workspace 6; }
          Super+Shift+Ctrl+7 { move-column-to-workspace 7; }
          Super+Shift+Ctrl+8 { move-column-to-workspace 8; }
          Super+Shift+Ctrl+9 { move-column-to-workspace 9; }

          // ═══════════════════════════════════════════════
          // Standard Window Operations (Windows classics)
          // ═══════════════════════════════════════════════
          Alt+F4 { close-window; }                            // Alt+F4 - Close (classic)
          Super+Q { close-window; }                           // Win+Q  - Close (alt)
          Alt+Tab { switch-focus-between-floating-and-tiling; } // Alt+Tab - Switch windows
          Super+Shift+Q { quit; }                             // Win+Shift+Q - Quit niri

          // ═══════════════════════════════════════════════
          // PowerToys-inspired Shortcuts
          // ═══════════════════════════════════════════════
          Alt+Space { spawn "noctalia" "msg" "panel-toggle" "launcher"; }  // Alt+Space - PowerToys Run

          // Win+Shift+C - Color Picker (PowerToys)
          Super+Shift+C { spawn "hyprpicker" "-a"; }

          // Win+V - Clipboard History (PowerToys)
          Super+V { spawn-sh "cliphist list | wofi --dmenu --prompt 'Clipboard' | cliphist decode | wl-copy"; }

          // ═══════════════════════════════════════════════
          // Window Layout Fine-Tuning
          // ═══════════════════════════════════════════════
          Super+F { maximize-column; }                        // Win+F - Maximize column
          Super+Shift+F { fullscreen-window; }                // Win+Shift+F - Fullscreen
          Super+C { center-column; }                          // Win+C - Center column
          Super+Minus { set-column-width "-10%"; }            // Win+- - Narrow column
          Super+Equal { set-column-width "+10%"; }            // Win+= - Widen column

          // ═══════════════════════════════════════════════
          // Media Keys
          // ═══════════════════════════════════════════════
          XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
          XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
          XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

          XF86AudioPlay { spawn "playerctl" "play-pause"; }
          XF86AudioNext { spawn "playerctl" "next"; }
          XF86AudioPrev { spawn "playerctl" "previous"; }

          // ═══════════════════════════════════════════════
          // Brightness Keys
          // ═══════════════════════════════════════════════
          XF86MonBrightnessUp { spawn "brightnessctl" "set" "5%+"; }
          XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

          // ═══════════════════════════════════════════════
          // Screenshots
          // ═══════════════════════════════════════════════
          Print { screenshot; }                               // Print Screen - Full screen
          Ctrl+Print { screenshot-screen; }                   // Ctrl+Print - Current screen
          Alt+Print { screenshot-window; }                    // Alt+Print - Current window
          Super+Shift+S { screenshot; }                       // Win+Shift+S - Snipping Tool
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
