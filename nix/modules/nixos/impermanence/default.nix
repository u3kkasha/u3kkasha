{
  lib,
  config,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.internal.impermanence;
in
{
  options.internal.impermanence = {
    enable = mkEnableOption "Impermanence persistence configuration";
    persistPath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Directory where persistent data is stored";
    };
  };

  config = mkIf cfg.enable {
    # FUSE is required for home-manager's user-level persistence to bind-mount directories
    programs.fuse.userAllowOther = true;

    environment.persistence."${cfg.persistPath}" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/docker"
        "/var/lib/containers" # For podman
        "/var/db/sudo/lectured"
        "/etc/ssh" # Persist SSH host keys
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
