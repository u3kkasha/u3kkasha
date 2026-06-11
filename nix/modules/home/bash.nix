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
        # Load Doppler secrets if logged in
        if [ -f ~/.doppler/config.yaml ]; then
          eval "$(doppler secrets download --no-file --format env)"
        fi

        # Export GitHub token from gh if available
        if command -v gh >/dev/null 2>&1; then
          export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
        fi
      '';
    };
  };
}
