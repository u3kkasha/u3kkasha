{
  pkgs,
  lib,
  config,
  self,
  inputs,
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
    nixpkgs.overlays = lib.mkDefault [
      (_final: prev: {
        nushell = prev.nushell.override {
          additionalFeatures = f: f ++ [ "mcp" ];
        };
      })
      (
        _final: prev:
        let
          agentPkgs = inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system} or { };
        in
        {
          antigravity-cli = agentPkgs.antigravity-cli or prev.antigravity-cli;
          inherit (prev) codex;
          opencode = agentPkgs.opencode or prev.opencode;
        }
      )
    ];

    nix.package = pkgs.lix;
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
    };

    system.stateVersion = systemStateVersion;
    system.nixos.versionSuffix = ".${self.shortRev or self.dirtyShortRev or "dirty"}";

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
        "docker"
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
