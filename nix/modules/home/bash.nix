{
  lib,
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
        EDITOR = lib.internal.defaultEditor;
      };
      bashrcExtra = ''
        # Export GitHub token from gh if available
        if command -v gh >/dev/null 2>&1; then
          export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
        fi
      '';
    };
  };
}
