_:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nix#nixos";
    };
  };
}
