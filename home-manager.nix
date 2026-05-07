{ config, pkgs, ... }:

{
  imports = [
    ./modules/home/helix.nix
    ./modules/home/zellij.nix
    ./modules/home/git.nix
    ./modules/home/direnv.nix
  ];

  home.stateVersion = "25.11";
}
