{ username, nix-index-database, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = { inherit username nix-index-database; };
  home-manager.users.${username} = {
    imports = [
      ../home-manager.nix
      nix-index-database.hmModules.nix-index
    ];
  };
}
