{ config, ... }:

{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    extraConfig = ''
      load-env {
        NH_FLAKE: "${config.home.homeDirectory}/.dotfiles/nix"
      }

      # Load Doppler secrets if logged in
      try {
        if ("~/.doppler/config.yaml" | path exists) {
          load-env (doppler secrets download --format json | from json)
        }
      }

      def cleanup [] {
        nh clean all
        nix-collect-garbage -d
        sudo nix-collect-garbage -d
      }
    '';
  };
}
