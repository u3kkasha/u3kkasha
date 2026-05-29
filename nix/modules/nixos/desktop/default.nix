{
  lib,
  config,
  ...
}:

let
  cfg = config.internal.desktop;
in
{
  options.internal.desktop = {
    enable = lib.mkEnableOption "Desktop environment (KDE Plasma)";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Basic sound and bluetooth for laptop
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
