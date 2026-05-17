{ inputs, ... }:

{
  imports = [
    ../../home-manager.nix
    inputs.nix-index-database.homeModules.nix-index
    inputs.catppuccin.homeModules.catppuccin
  ];
}
