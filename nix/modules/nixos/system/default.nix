{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib.internal) username systemStateVersion;
  cfg = config.internal.system;
in
{
  options.internal.system = {
    enable = lib.mkEnableOption "Standard system configuration";
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
        username
      ];
      min-free = 5 * 1024 * 1024 * 1024; # 5GB
      max-free = 10 * 1024 * 1024 * 1024; # 10GB
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/ukasha/.dotfiles/nix";
    };

    system.stateVersion = systemStateVersion;

    time.timeZone = "Asia/Dhaka";
    i18n.defaultLocale = "en_GB.UTF-8";

    environment.systemPackages = with pkgs; [
      nushell
      git # Explicitly ensure git is available at system level too
    ];

    environment.shells = with pkgs; [ nushell ];

    users.users.${username} = {
      isNormalUser = true;
      shell = pkgs.nushell;
      extraGroups = [
        "wheel"
        "podman"
      ];
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
