{ namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  ${namespace} = {
    system.enable = true;
    desktop.enable = true;
    podman.enable = true;
    docker.enable = true;
    impermanence.enable = true;
  };

  networking.hostName = "nixos";
}
