{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.herdr;
in
{
  options.internal.herdr = {
    enable = mkEnableOption "Herdr terminal multiplexer configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
