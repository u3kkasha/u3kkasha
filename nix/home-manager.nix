{ config, pkgs, ... }:

{
  imports = [
    ./modules/home/helix.nix
    ./modules/home/zellij.nix
    ./modules/home/git.nix
    ./modules/home/direnv.nix
    ./modules/home/oh-my-posh.nix
    ./modules/home/bash.nix
    ./modules/home/carapace.nix
  ];

  home.stateVersion = "25.11";
}
