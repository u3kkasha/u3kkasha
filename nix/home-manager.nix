{ username, config, ... }:

let
  theme = {
    name = "mocha";
    helix = "catppuccin_mocha";
    zellij = "catppuccin-mocha";
    bat = "Catppuccin Mocha";
    yazi = "catppuccin-mocha";
    posh = "catppuccin_mocha";
    lazygit = "mocha";
  };
in
{
  _module.args.theme = theme;

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/.dotfiles/nix";
  };

  home.shellAliases = {
    rebuild = "nh os switch";
  };

  programs.nix-index.enable = true;

  imports = [
    ./modules/home/helix.nix
    ./modules/home/zellij.nix
    ./modules/home/git.nix
    ./modules/home/direnv.nix
    ./modules/home/oh-my-posh.nix
    ./modules/home/bash.nix
    ./modules/home/nushell.nix
    ./modules/home/carapace.nix
    ./modules/home/yazi.nix
    ./modules/home/television.nix
    ./modules/home/ripgrep.nix
    ./modules/home/zoxide.nix
  ];

  home.stateVersion = "25.11";
}
