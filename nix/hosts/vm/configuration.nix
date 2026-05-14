{ ... }:

{
  imports = [
    ../../modules/system.nix
    ../../modules/podman.nix
    ../../modules/home-manager.nix
  ];

  # VM specific configuration
  services.qemuGuest.enable = true;

  # Dummy file system to satisfy 'nix flake check'
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
}
