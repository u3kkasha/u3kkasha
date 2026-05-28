{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.cli;
in
{
  options.internal.cli = {
    enable = mkEnableOption "CLI tools configuration";
  };

  config = mkIf cfg.enable {
    programs.carapace.enable = true;
    programs.television.enable = true;
    programs.oh-my-posh = {
      enable = true;
      useTheme = "catppuccin_${lib.internal.themeFlavor}";
    };
  };
}
