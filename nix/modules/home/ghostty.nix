{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.ghostty;
in
{
  options.internal.ghostty = {
    enable = mkEnableOption "Ghostty terminal configuration";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableBashIntegration = config.internal.bash.enable;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 16;
        window-padding-x = 8;
        window-padding-y = 8;
        background-opacity = 0.9;
        background-blur = true;
        confirm-close-surface = false;
        mouse-hide-while-typing = true;
        cursor-style = "block";
        cursor-style-blink = true;
        shell-integration-features = "no-cursor";
      };
    };

    home.sessionVariables = {
      TERMINAL = lib.internal.defaultTerminal;
    };
  };
}
