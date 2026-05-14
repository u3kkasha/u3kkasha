{ ... }:

{
  imports = [
    ../../modules/system.nix
    ../../modules/podman.nix
    ../../modules/home-manager.nix
  ];

  # VM specific configuration
  services.qemuGuest.enable = true;
}
