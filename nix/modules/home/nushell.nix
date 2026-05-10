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

      def cleanup [] {
        nh clean all
        nix-collect-garbage -d
        sudo nix-collect-garbage -d
      }
    '';
  };
}
