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
    outputConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-owned physical output configuration appended to the shared Niri configuration.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
      cliphist
      wofi
    ];

    xdg.configFile."niri/config.kdl".text =
      builtins.replaceStrings [ "// HOST_OUTPUT_CONFIG" ] [ cfg.outputConfig ]
        (builtins.readFile ./niri.kdl);

    xdg.configFile."hypr/hypridle.conf".text = ''
      general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = niri msg action power-on-monitors
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
