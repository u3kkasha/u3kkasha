{
  description = "Multi-System Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1H2rnfjkW8Vgi8M96u6Vny89Y460GqT8m2R27Yrg="
    ];
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "internal";
      };

      channels-config = {
        allowUnfree = true;
      };

      overlays = [
        inputs.devshell.overlays.default
      ];

      systems.modules.nixos = [
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
      ];

      homes.modules = [
        inputs.catppuccin.homeModules.catppuccin
        inputs.nix-index-database.homeModules.nix-index
      ];

      outputs-builder =
        channels:
        let
          pkgs = channels.nixpkgs;
          treefmtConfig = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          formatter = treefmtConfig.config.build.wrapper;

          checks = {
            formatting = treefmtConfig.config.build.check inputs.self;
            gitleaks =
              pkgs.runCommand "gitleaks"
                {
                  nativeBuildInputs = [ pkgs.gitleaks ];
                }
                ''
                  gitleaks detect --source ${inputs.self} --verbose --no-git
                  touch $out
                '';
          };
        };
    };
}
