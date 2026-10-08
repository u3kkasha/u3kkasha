{
  lib,
  internal,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.bash;
in
{
  options.internal.bash = {
    enable = mkEnableOption "Bash configuration";
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        eval "$(${pkgs.devenv}/bin/devenv hook bash)"
      '';
      shellAliases = { };
      sessionVariables = {
        EDITOR = internal.defaultEditor;
      };
    };
  };
}
