{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.nixd;
  nixdConfig = pkgs.writeText "nixd-config.json" (
    builtins.toJSON {
      nixd = {
        nixpkgs = {
          expr = "import <nixpkgs> { }";
        };
        options = {
          nixos = {
            expr = "(builtins.getFlake (builtins.toString ./../..)).nixosConfigurations.${config.internal.hostName}.options";
          };
          home-manager = {
            expr = "(builtins.getFlake (builtins.toString ./../..)).nixosConfigurations.${config.internal.hostName}.options.home-manager.users.type.getSubOptions [ ]";
          };
        };
      };
    }
  );
in
{
  options.internal.nixd = {
    enable = mkEnableOption "nixd language server configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nixd ];

    xdg.configFile."nixd/config.json".source = nixdConfig;
  };
}
