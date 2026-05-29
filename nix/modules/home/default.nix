{
  config,
  lib,
  ...
}:

let
  inherit (lib.internal) username homeStateVersion;
in
{
  imports = [
    ./bash.nix
    ./cli.nix
    ./direnv.nix
    ./gemini.nix
    ./ghostty.nix
    ./git.nix
    ./helix.nix
    ./nushell.nix
    ./utils.nix
    ./yazi.nix
    ./zellij.nix
  ];

  internal = {
    bash.enable = lib.mkDefault true;
    cli.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;
    gemini.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    nushell.enable = lib.mkDefault true;
    utils.enable = lib.mkDefault true;
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

  programs.nix-index.enable = true;

  home.stateVersion = homeStateVersion;
}
