{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.wlsunset;
in
{
  options.internal.wlsunset = {
    enable = mkEnableOption "wlsunset service";
  };

  config = mkIf cfg.enable {
    services.wlsunset = {
      enable = true;
      latitude = "23.8";
      longitude = "90.4";
    };
  };
}
