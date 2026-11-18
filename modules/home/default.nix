{
  pkgs,
  config,
  lib,
  internal,
  osConfig ? null,
  ...
}:

let
  inherit (internal)
    username
    homeStateVersion
    scanPaths
    themeFlavor
    ;
  modernWebGuidance = pkgs.fetchFromGitHub {
    owner = "GoogleChrome";
    repo = "modern-web-guidance";
    rev = "v1.0.1";
    hash = "sha256-6AKPHsrv7uP0clLZaezrCP8lHXY5EB0hJwQ3gnk4+UI=";
  };
in
{
  imports = scanPaths ./.;

  options.internal = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default =
        if osConfig != null then
          osConfig.networking.hostName
        else
          throw "internal.hostName must be explicitly set for standalone Home Manager configurations";
      description = "The target hostname/system configuration name.";
    };

    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable GUI-related configurations.";
      };
    };
  };

  config = {
    programs.codex.skills.modern-web-guidance = "${modernWebGuidance}/skills/modern-web-guidance";
    programs.opencode.skills.modern-web-guidance = "${modernWebGuidance}/skills/modern-web-guidance";

    programs.nix-skills = {
      enable = true;
      agents = [
        "codex"
        "opencode"
      ];
      skills = [
        "nix-language"
        "nix-workflow"
        "nixpkgs-development"
        "nixos-operations"
        "home-manager"
        "devenv-project"
      ];
    };

    internal = {
      bash.enable = lib.mkDefault true;
      cli.enable = lib.mkDefault true;
      direnv.enable = lib.mkDefault true;
      devtools.enable = lib.mkDefault true;
      codex.enable = lib.mkDefault true;
      codegraph.enable = lib.mkDefault true;
      ghostty.enable = lib.mkDefault config.internal.gui.enable;
      helix.enable = lib.mkDefault true;
      nushell.enable = lib.mkDefault true;
      opencode.enable = lib.mkDefault true;
      nixd.enable = lib.mkDefault true;
      niri.enable = lib.mkDefault config.internal.gui.enable;
      wlsunset.enable = lib.mkDefault config.internal.gui.enable;
      utils.enable = lib.mkDefault true;
      snip.enable = lib.mkDefault true;
      specKit.enable = lib.mkDefault true;
      wsl.enable = lib.mkDefault false;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault true;
    };

    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.pointerCursor = lib.mkIf config.internal.gui.enable {
      enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    home.sessionVariables = {
      EDITOR = internal.defaultEditor;
      VISUAL = internal.defaultEditor;
    };

    nix.package = lib.mkDefault pkgs.nix;

    home.stateVersion = homeStateVersion;

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = themeFlavor;
    };
  };
}
