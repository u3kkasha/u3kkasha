{
  username,
  inputs,
  ...
}:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = {
    inherit username inputs;
  };
  home-manager.users.${username} = {
    imports = [
      ../home-manager.nix
      inputs.nix-index-database.homeModules.nix-index
      inputs.catppuccin.homeModules.catppuccin
    ];
  };
}
