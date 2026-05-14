{ nix-index-database, ... }:

{
  imports = [
    ../../home-manager.nix
    nix-index-database.homeModules.nix-index
  ];
}
