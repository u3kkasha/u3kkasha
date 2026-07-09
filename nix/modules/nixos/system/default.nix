{
  pkgs,
  lib,
  config,
  self,
  ...
}:

let
  inherit (lib.internal) username systemStateVersion;
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
    nix.package = pkgs.lix;
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.numtide.com"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
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
      ++ lib.optional config.internal.podman.enable "podman"
      ++ lib.optional config.internal.docker.enable "docker";
    };

    programs.nix-ld.enable = true;
    zramSwap.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.${username} = import ../../home/default.nix;
    };
  };
}
