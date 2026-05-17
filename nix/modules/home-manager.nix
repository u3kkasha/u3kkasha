{
  username,
  inputs,
  systemStateVersion,
  homeStateVersion,
  ...
}:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = {
    inherit
      username
      inputs
      systemStateVersion
      homeStateVersion
      ;
  };
  home-manager.users.${username} = {
    imports = [
      ./home/default.nix
    ];
  };
}
