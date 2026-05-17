_:

{
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

      def cleanup [] {
        nix run .#clean
      }
    '';
  };
}
