{
  pkgs,
  lib,
  config,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.podman;
in
{
  options.${namespace}.podman = {
    enable = lib.mkEnableOption "Podman container management";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = with pkgs; [
      podman-compose
      podman-tui
    ];
  };
}
