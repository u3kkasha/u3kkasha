{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib.internal)
    username
    homeStateVersion
    scanPaths
    ;
in
{
  imports = scanPaths ./.;

  options.internal.gui = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable GUI-related configurations.";
    };
  };

  config = {
    internal = {
      bash.enable = lib.mkDefault true;
      cli.enable = lib.mkDefault true;
      direnv.enable = lib.mkDefault true;
      antigravity.enable = lib.mkDefault true;
      ghostty.enable = lib.mkDefault config.internal.gui.enable;
      herdr.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      helix.enable = lib.mkDefault true;
      nushell.enable = lib.mkDefault true;
      opencode.enable = lib.mkDefault true;
      plasma.enable = lib.mkDefault config.internal.gui.enable;
      utils.enable = lib.mkDefault true;
      wsl.enable = lib.mkDefault false;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault true;
    };

    dconf.settings = lib.mkForce { };

    home.username = username;
    home.homeDirectory = "/home/${username}";

    home.sessionVariables = {
      NH_FLAKE = "${config.home.homeDirectory}/.dotfiles/nix";
      EDITOR = lib.internal.defaultEditor;
      VISUAL = lib.internal.defaultEditor;
    };

    nix.package = lib.mkDefault pkgs.lix;

    home.stateVersion = homeStateVersion;

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
    };
  };
}
