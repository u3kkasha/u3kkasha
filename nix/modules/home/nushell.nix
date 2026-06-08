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
      };
      extraConfig = ''
        # Load Doppler secrets if logged in
        try {
          if ("~/.doppler/config.yaml" | path exists) {
            load-env (doppler secrets download --format json | from json)
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
