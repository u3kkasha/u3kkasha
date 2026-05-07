{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";

  environment.systemPackages = with pkgs; [
    gemini-cli
    helix
    uv
  ];

  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;
}
