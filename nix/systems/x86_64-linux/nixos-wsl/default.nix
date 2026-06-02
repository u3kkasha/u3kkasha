{ namespace, lib, ... }:

{
  ${namespace} = {
    system.enable = true;
    podman.enable = true;
    wsl.enable = true;
  };

  home-manager.users.${lib.internal.username}.internal = {
    gui.enable = false;
    wsl.enable = true;
  };

  networking.hostName = "nixos-wsl";
  nixpkgs.hostPlatform = "x86_64-linux";
}
