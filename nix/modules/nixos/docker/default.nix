{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.internal.docker;
in
{
  options.internal.docker = {
    enable = lib.mkEnableOption "Docker container management";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = "overlay2";
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      daemon.settings = {
        live-restore = true;
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
