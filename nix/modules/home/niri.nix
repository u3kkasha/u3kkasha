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

    xdg.configFile."niri/config.kdl" = {
      text = ''
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
            preset-column-widths {
                proportion 0.33333
                proportion 0.5
                proportion 0.66667
            }
            focus-ring {
                width 4
                active-color "#7fc8ff"
                inactive-color "#505050"
            }
            border {
                off
                width 4
                active-color "#ffc87f"
                inactive-color "#505050"
                urgent-color "#9b0000"
            }
            shadow {
                off
                softness 30
                spread 5
                offset x=0 y=5
                color "#00000070"
            }
        }

        prefer-no-csd

        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

        animations {
        }

        window-rule {
            match app-id=r#"^org\.wezfurlong\.wezterm$"#
            default-column-width {}
        }
        window-rule {
            match app-id=r#"firefox$"# title="^Picture-in-Picture$"
            open-floating true
        }
        window-rule {
            geometry-corner-radius 12
            clip-to-geometry true
        }

        spawn-at-startup "noctalia"
        spawn-at-startup "nm-applet"
        spawn-at-startup "hypridle"
        spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"
        spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"

        binds {
            // ──────────────────────────────────────────────
            // Help & Launchers
            // ──────────────────────────────────────────────
            Mod+Shift+Slash { show-hotkey-overlay; }
            Mod+D { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
            Mod+T { spawn "ghostty"; }
            Super+Alt+L { spawn "hyprlock"; }

            // ──────────────────────────────────────────────
            // Overview & Close
            // ──────────────────────────────────────────────
            Mod+O { toggle-overview; }
            Mod+Q { close-window; }

            // ──────────────────────────────────────────────
            // Focus — Vim-style (primary) + Arrows
            // ──────────────────────────────────────────────
            Mod+H     { focus-column-left; }
            Mod+J     { focus-window-down; }
            Mod+K     { focus-window-up; }
            Mod+L     { focus-column-right; }
            Mod+Left  { focus-column-left; }
            Mod+Down  { focus-window-down; }
            Mod+Up    { focus-window-up; }
            Mod+Right { focus-column-right; }

            // ──────────────────────────────────────────────
            // Move Windows/Columns
            // ──────────────────────────────────────────────
            Mod+Ctrl+H     { move-column-left; }
            Mod+Ctrl+J     { move-window-down; }
            Mod+Ctrl+K     { move-window-up; }
            Mod+Ctrl+L     { move-column-right; }
            Mod+Ctrl+Left  { move-column-left; }
            Mod+Ctrl+Down  { move-window-down; }
            Mod+Ctrl+Up    { move-window-up; }
            Mod+Ctrl+Right { move-column-right; }

            // ──────────────────────────────────────────────
            // Monitor Focus
            // ──────────────────────────────────────────────
            Mod+Shift+H     { focus-monitor-left; }
            Mod+Shift+J     { focus-monitor-down; }
            Mod+Shift+K     { focus-monitor-up; }
            Mod+Shift+L     { focus-monitor-right; }
            Mod+Shift+Left  { focus-monitor-left; }
            Mod+Shift+Down  { focus-monitor-down; }
            Mod+Shift+Up    { focus-monitor-up; }
            Mod+Shift+Right { focus-monitor-right; }

            // ──────────────────────────────────────────────
            // Move Column to Monitor
            // ──────────────────────────────────────────────
            Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
            Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }
            Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
            Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }

            // ──────────────────────────────────────────────
            // First / Last Column
            // ──────────────────────────────────────────────
            Mod+Home { focus-column-first; }
            Mod+End  { focus-column-last; }
            Mod+Ctrl+Home { move-column-to-first; }
            Mod+Ctrl+End  { move-column-to-last; }

            // ──────────────────────────────────────────────
            // Workspace Navigation
            // ──────────────────────────────────────────────
            Mod+Page_Down { focus-workspace-down; }
            Mod+Page_Up   { focus-workspace-up; }
            Mod+U         { focus-workspace-down; }
            Mod+I         { focus-workspace-up; }

            // ──────────────────────────────────────────────
            // Move Column to Workspace
            // ──────────────────────────────────────────────
            Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
            Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
            Mod+Ctrl+U         { move-column-to-workspace-down; }
            Mod+Ctrl+I         { move-column-to-workspace-up; }

            // ──────────────────────────────────────────────
            // Reorder Workspaces
            // ──────────────────────────────────────────────
            Mod+Shift+Page_Down { move-workspace-down; }
            Mod+Shift+Page_Up   { move-workspace-up; }
            Mod+Shift+U         { move-workspace-down; }
            Mod+Shift+I         { move-workspace-up; }

            // ──────────────────────────────────────────────
            // Workspace Quick-Switch (Mod+Number)
            // ──────────────────────────────────────────────
            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }

            // ──────────────────────────────────────────────
            // Move Column to Workspace by Number
            // ──────────────────────────────────────────────
            Mod+Ctrl+1 { move-column-to-workspace 1; }
            Mod+Ctrl+2 { move-column-to-workspace 2; }
            Mod+Ctrl+3 { move-column-to-workspace 3; }
            Mod+Ctrl+4 { move-column-to-workspace 4; }
            Mod+Ctrl+5 { move-column-to-workspace 5; }
            Mod+Ctrl+6 { move-column-to-workspace 6; }
            Mod+Ctrl+7 { move-column-to-workspace 7; }
            Mod+Ctrl+8 { move-column-to-workspace 8; }
            Mod+Ctrl+9 { move-column-to-workspace 9; }

            // ──────────────────────────────────────────────
            // Consume / Expel Windows
            // ──────────────────────────────────────────────
            Mod+BracketLeft  { consume-or-expel-window-left; }
            Mod+BracketRight { consume-or-expel-window-right; }
            Mod+Comma  { consume-window-into-column; }
            Mod+Period { expel-window-from-column; }

            // ──────────────────────────────────────────────
            // Column Width & Layout
            // ──────────────────────────────────────────────
            Mod+R { switch-preset-column-width; }
            Mod+Shift+R { switch-preset-column-width-back; }
            Mod+F { maximize-column; }
            Mod+Shift+F { fullscreen-window; }
            Mod+C { center-column; }
            Mod+Minus { set-column-width "-10%"; }
            Mod+Equal { set-column-width "+10%"; }

            // ──────────────────────────────────────────────
            // Floating & Tabbed
            // ──────────────────────────────────────────────
            Mod+V       { toggle-window-floating; }
            Mod+Shift+V { switch-focus-between-floating-and-tiling; }
            Mod+W       { toggle-column-tabbed-display; }

            // ──────────────────────────────────────────────
            // Mouse / Scroll Wheel
            // ──────────────────────────────────────────────
            Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
            Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }
            Mod+WheelScrollRight      { focus-column-right; }
            Mod+WheelScrollLeft       { focus-column-left; }
            Mod+Ctrl+WheelScrollRight { move-column-right; }
            Mod+Ctrl+WheelScrollLeft  { move-column-left; }
            Mod+Shift+WheelScrollDown      { focus-column-right; }
            Mod+Shift+WheelScrollUp        { focus-column-left; }
            Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
            Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

            // ──────────────────────────────────────────────
            // Screenshots
            // ──────────────────────────────────────────────
            Print { screenshot; }
            Ctrl+Print { screenshot-screen; }
            Alt+Print { screenshot-window; }

            // ──────────────────────────────────────────────
            // Utilities
            // ──────────────────────────────────────────────
            Super+Shift+C { spawn "hyprpicker" "-a"; }
            Mod+Shift+B { spawn-sh "cliphist list | wofi --dmenu --prompt 'Clipboard' | cliphist decode | wl-copy"; }

            // ──────────────────────────────────────────────
            // System
            // ──────────────────────────────────────────────
            Mod+Escape { toggle-keyboard-shortcuts-inhibit; }
            Mod+Shift+E { quit; }
            Ctrl+Alt+Delete { quit; }
            Mod+Shift+P { power-off-monitors; }

            // ──────────────────────────────────────────────
            // Media Keys
            // ──────────────────────────────────────────────
            XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
            XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

            XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
            XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
            XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }

            // ──────────────────────────────────────────────
            // Brightness Keys
            // ──────────────────────────────────────────────
            XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
        }
      '';
      force = true;
    };

    xdg.configFile."hypr/hypridle.conf" = {
      text = ''
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
      force = true;
    };

    xdg.userDirs.enable = true;
  };
}
