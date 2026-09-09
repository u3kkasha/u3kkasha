{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.nixd;
  lockedInputs = pkgs.linkFarm "nixd-locked-inputs" [
    {
      name = "flake";
      path = inputs.self;
    }
    {
      name = "nixpkgs";
      path = inputs.nixpkgs;
    }
  ];
  lockedInputsPath = "${lockedInputs}";
  nixdConfigText = builtins.toJSON {
    nixd = {
      nixpkgs = {
        expr = "import ${lockedInputsPath}/nixpkgs { }";
      };
      options = {
        nixos = {
          expr = "(builtins.getFlake \"${lockedInputsPath}/flake\").nixosConfigurations.${config.internal.hostName}.options";
        };
        home-manager = {
          expr = "(builtins.getFlake \"${lockedInputsPath}/flake\").nixosConfigurations.${config.internal.hostName}.options.home-manager.users.type.getSubOptions [ ]";
        };
      };
    };
  };
  nixdConfig = pkgs.runCommand "nixd-config.json" { } ''
    printf '%s' '${nixdConfigText}' > "$out"
  '';
in
{
  options.internal.nixd = {
    enable = mkEnableOption "nixd language server configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nixd ];

    xdg.configFile."nixd/config.json".source = nixdConfig;
    xdg.dataFile."nixd/locked-inputs".source = lockedInputs;
  };
}
