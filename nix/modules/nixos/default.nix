{ config, lib, ... }:
{
  imports = lib.internal.scanPaths ./.;

  assertions = [
    {
      assertion = !(config.internal.docker.enable && config.internal.podman.enable);
      message = "internal.docker.enable and internal.podman.enable are mutually exclusive";
    }
  ];
}
