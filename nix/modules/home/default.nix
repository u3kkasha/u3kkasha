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
