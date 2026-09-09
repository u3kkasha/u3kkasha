{
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
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };
}
