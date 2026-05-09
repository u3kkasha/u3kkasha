_:

{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ($env.HOME + '/.dotfiles/nix#nixos')";
    };
  };
}
