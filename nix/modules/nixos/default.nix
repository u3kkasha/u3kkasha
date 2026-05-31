{ lib, ... }:
{
  imports = lib.internal.scanPaths ./.;
}
