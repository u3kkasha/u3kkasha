{ namespace, internal, ... }:

{
  imports = [ ./wsl.nix ];

  ${namespace} = {
    system.enable = true;
    docker.enable = true;
    wsl.enable = true;
  };

  home-manager.users.${internal.username}.internal = {
    gui.enable = false;
    wsl.enable = true;
  };

  networking.hostName = "nixos-wsl";
}
