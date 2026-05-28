{ namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ${namespace} = {
    system.enable = true;
    podman.enable = true;
  };

  snowfallorg.users.ukasha.home.enable = true;

  networking.hostName = "nixos";
}
