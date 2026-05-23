_:

{
  programs.nushell = {
    enable = true;
    environmentVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
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
}
