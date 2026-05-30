{ namespace, ... }:

{
  ${namespace} = {
    system.enable = true;
    podman.enable = true;
    wsl.enable = true;
  };

  home-manager.users.${lib.internal.username}.internal.gui.enable = false;

  snowfallorg.users.ukasha.home.enable = true;

  networking.hostName = "nixos-wsl";
}
