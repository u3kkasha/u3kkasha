{ username, config, ... }:

{
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/.dotfiles/nix";
  };

  home.shellAliases = {
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  imports = [
    ./modules/home/helix.nix
    ./modules/home/zellij.nix
    ./modules/home/git.nix
    ./modules/home/bash.nix
    ./modules/home/nushell.nix
    ./modules/home/yazi.nix
    ./modules/home/utils.nix
    ./modules/home/gemini.nix
    ./modules/home/cli.nix
  ];

  home.stateVersion = "25.11";
}
