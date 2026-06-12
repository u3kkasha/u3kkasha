{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = config.internal.desktop;
in
{
  options.internal.desktop = {
    enable = lib.mkEnableOption "Desktop environment (Niri + Noctalia)";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    # Niri Compositor
    programs.niri.enable = true;

    # Login Manager
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
          user = "greeter";
        };
      };
    };

    # Unlock gnome-keyring on login
    security.pam.services.greetd.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;

    # Essential Desktop Utilities
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
      inputs.noctalia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
      wl-clipboard
      libnotify
      brightnessctl
      playerctl
      pavucontrol # Audio GUI
      wlsunset # Night Light
      grim # screenshots
      slurp # region selection
      hyprlock # screen locker
      hypridle # idle daemon
      nautilus # file manager (Niri works well with it)
    ];

    # Polkit for privilege escalation
    security.polkit.enable = true;
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # XDG Portals
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
      config.common.default = [ "gtk" ];
    };

    # Enable Electron Wayland support
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Enable dconf for GTK settings
    programs.dconf.enable = true;

    # Enable gvfs for file manager features (trash, mounts)
    services.gvfs.enable = true;

    # Fonts
    fonts.packages = with pkgs; [
      inter
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];

    # Basic sound and bluetooth
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
