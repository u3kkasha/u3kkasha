{
  pkgs,
  lib,
  config,
  namespace,
  ...
}:

let
  inherit (lib.${namespace}) username systemStateVersion;
  cfg = config.${namespace}.system;
in
{
  options.${namespace}.system = {
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
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    system.stateVersion = systemStateVersion;

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
    nixpkgs.config.allowUnfree = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
  };
}
