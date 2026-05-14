{ pkgs, username, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";

  environment.systemPackages = with pkgs; [
    nushell
  ];

  environment.shells = with pkgs; [ nushell ];

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "podman" ];
  };

  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;
}
