{
  lib,
  internal,
  config,
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
      shellAliases = { };
      sessionVariables = {
        EDITOR = internal.defaultEditor;
      };
    };
  };
}
