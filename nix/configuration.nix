{ ... }:

{
  imports = [
    ./modules/wsl.nix
    ./modules/system.nix
    ./modules/podman.nix
    ./modules/home-manager.nix
  ];
}
