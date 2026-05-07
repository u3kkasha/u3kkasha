{ config, pkgs, ... }:

{
  imports = [
    ./modules/home/helix.nix
    ./modules/home/zellij.nix
    ./modules/home/git.nix
  ];

  home.stateVersion = "25.11";
}
