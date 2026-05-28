{ namespace, ... }:

{
  ${namespace} = {
    system.enable = true;
    podman.enable = true;
    wsl.enable = true;
  };

  networking.hostName = "nixos-wsl";
}
