{
  lib,
  config,
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
    home.sessionVariables = {
      EDITOR = lib.internal.defaultEditor;
    };
    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
        edit_mode = "vi";
        history = {
          file_format = "sqlite";
        };
      };
      extraConfig = ''
        # Load Doppler secrets if logged in
        if (which doppler | is-not-empty) {
          try {
            if (doppler configure get token --plain | str trim | is-not-empty) {
              load-env (doppler secrets download --no-file --format json | from json)
            }
          }
        }

        # Export GitHub token from gh if available
        if (which gh | is-not-empty) {
            $env.GITHUB_TOKEN = (do { ^gh auth token } | complete | get -o stdout | str trim)
        }
      '';
    };
  };
}
