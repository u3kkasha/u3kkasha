{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11";

  environment.systemPackages = with pkgs; [
    gemini-cli
    helix
    uv
    nushell
    mdr
  ];

  environment.shells = with pkgs; [ nushell ];

  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.nushell;
  };

  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;
}
