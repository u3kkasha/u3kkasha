{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.internal.podman;
in
{
  options.internal.podman = {
    enable = lib.mkEnableOption "Podman container management";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    environment.systemPackages = with pkgs; [
      podman-compose
      podman-tui
    ];
  };
}
