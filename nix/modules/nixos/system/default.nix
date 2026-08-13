{
  pkgs,
  lib,
  config,
  self,
  ...
}:

let
  inherit (lib.internal)
    username
    systemStateVersion
    cacheSubstituters
    cachePublicKeys
    ;
  cfg = config.internal.system;
  nushell = pkgs.nushell.override {
    additionalFeatures = features: features ++ [ "mcp" ];
  };
in
{
  options.internal.system = {
    enable = lib.mkEnableOption "Standard system configuration";
  };

  config = lib.mkIf cfg.enable {
    nix.package = pkgs.nix;
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
      ];
      substituters = cacheSubstituters;
      trusted-public-keys = cachePublicKeys;
      min-free = 5 * 1024 * 1024 * 1024; # 5GB
      max-free = 10 * 1024 * 1024 * 1024; # 10GB
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };

    system.stateVersion = systemStateVersion;
    system.nixos.versionSuffix = ".${self.shortRev or self.dirtyShortRev or "dirty"}";

    time.timeZone = "Asia/Dhaka";
    i18n.defaultLocale = "en_GB.UTF-8";

    environment.systemPackages = [
      nushell
      pkgs.git # Explicitly ensure git is available at system level too
    ];

    environment.shells = [ nushell ];

    users.users.${username} = {
      isNormalUser = true;
      shell = nushell;
      extraGroups = [
        "wheel"
      ]
      ++ lib.optional config.internal.docker.enable "docker";
    };

    programs.nix-ld.enable = true;
    zramSwap.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupCommand = "bash -c 'rm -rf \"$1.backup\" && mv \"$1\" \"$1.backup\"' --";
      users.${username} = import ../../home/default.nix;
    };
  };
}
