{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.internal.desktop;
in
{
  options.internal.desktop = {
    enable = lib.mkEnableOption "Desktop environment (GNOME)";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Enable Flatpak
    services.flatpak.enable = true;
    services.flatpak.update.auto.enable = true;
    services.flatpak.packages = [
      "dev.vencord.Vesktop"
      "com.spotify.Client"
      "md.obsidian.Obsidian"
      "io.github.marcodallasol.flatsweep"
      "io.github.flattool.Warehouse"
      "com.bitwarden.desktop"
      "app.drey.Blanket"
      "io.github.celluloid_player.Celluloid"
    ];

    # Exclude GNOME bloat
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-music
      epiphany # web browser
      geary # email reader
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ];

    # Fonts
    fonts.packages = with pkgs; [
      inter
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];

    # Basic sound and bluetooth for laptop
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
