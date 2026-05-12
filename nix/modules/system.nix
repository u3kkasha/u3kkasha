{ pkgs, username, ... }:

let
  aspire-cli = pkgs.callPackage ../pkgs/aspire-cli.nix { };
in
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
    gemini-cli
    helix
    uv
    nushell
    mdr
    dotnet-sdk_10
    aspire-cli
    nh
    nix-index
    comma
    devenv
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
