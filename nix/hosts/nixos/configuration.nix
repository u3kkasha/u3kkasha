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

  # Dummy file system to satisfy 'nix flake check'
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader.grub.enable = false; # systemd-boot is enabled above
}
