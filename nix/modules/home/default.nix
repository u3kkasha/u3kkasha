{
  config,
  lib,
  namespace,
  ...
}:

let
  inherit (lib.${namespace}) username homeStateVersion;
in
{
  imports = [
    ./bash.nix
    ./cli.nix
    ./direnv.nix
    ./gemini.nix
    ./git.nix
    ./helix.nix
    ./nushell.nix
    ./utils.nix
    ./yazi.nix
    ./zellij.nix
  ];

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/.dotfiles/nix";
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  home.stateVersion = homeStateVersion;
}
