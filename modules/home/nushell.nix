{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.nushell;
in
{
  options.internal.nushell = {
    enable = mkEnableOption "Nushell configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."nushell/autoload/devenv-hook.nu".source = pkgs.runCommand "devenv-hook.nu" { } ''
      ${pkgs.devenv}/bin/devenv hook nu > "$out"
    '';

    programs.nushell = {
      enable = true;
      environmentVariables = config.home.sessionVariables;
      settings = {
        show_banner = false;
        edit_mode = "vi";
        history = {
          file_format = "sqlite";
        };
      };
    };
  };
}
