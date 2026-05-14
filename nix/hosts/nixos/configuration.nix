{ ... }:

{
  imports = [
    ../../modules/system.nix
    ../../modules/podman.nix
    ../../modules/home-manager.nix
  ];

  # Bare-metal specific configuration could go here
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
