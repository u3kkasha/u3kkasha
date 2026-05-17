{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/podman.nix
    ../../modules/home-manager.nix
  ];

  networking.hostName = "nixos";

  # Bare-metal specific configuration could go here
}
