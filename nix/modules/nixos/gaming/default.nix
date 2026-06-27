{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.internal.gaming;
in
{
  options.internal.gaming = {
    enable = lib.mkEnableOption "Gaming configuration and tools";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        steam = prev.steam.override {
          extraArgs = "-cef-disable-gpu-compositing";
        };
      })
    ];

    # Enable Steam client and configure firewall rules
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # Enable Gamemode to optimize system scheduling and priorities during gameplay
    programs.gamemode.enable = true;

    # Enable Gamescope micro-compositor for isolated resolution and scaling control
    programs.gamescope.enable = true;

    # Install user-facing gaming overlays and compatibility utilities
    environment.systemPackages = with pkgs; [
      mangohud # HUD overlay for FPS, temperatures, CPU/GPU usage
      protonup-qt # Graphical utility to install and manage community Proton GE versions
    ];
  };
}
