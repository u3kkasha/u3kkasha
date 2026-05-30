{
  description = "Multi-System Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
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
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake = {
        nixosConfigurations = {
          nixos = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              namespace = "internal";
              lib = inputs.nixpkgs.lib.extend (
                _final: _prev: {
                  internal = import ./lib/constants/default.nix;
                  hm = inputs.home-manager.lib.hm;
                }
              );
            };
            modules = [
              ./systems/x86_64-linux/nixos/default.nix
              ./modules/nixos/default.nix
              inputs.nixos-wsl.nixosModules.default
              inputs.home-manager.nixosModules.home-manager
              inputs.nix-index-database.nixosModules.nix-index
              {
                home-manager.sharedModules = [
                  inputs.plasma-manager.homeModules.plasma-manager
                  inputs.catppuccin.homeModules.catppuccin
                ];
              }
            ];
          };
        };
        homeConfigurations = {
          "${(import ./lib/constants/default.nix).username}@nixos" =
            inputs.home-manager.lib.homeManagerConfiguration
              {
                pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
                extraSpecialArgs = {
                  inherit inputs;
                  lib = inputs.nixpkgs.lib.extend (
                    _final: _prev: {
                      internal = import ./lib/constants/default.nix;
                      hm = inputs.home-manager.lib.hm;
                    }
                  );
                };
                modules = [
                  ./modules/home/default.nix
                  inputs.plasma-manager.homeModules.plasma-manager
                  inputs.nix-index-database.homeModules.nix-index
                  inputs.catppuccin.homeModules.catppuccin
                ];
              };
        };
      };

      perSystem =
        { pkgs, ... }:
        let
          treefmt = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          formatter = treefmt.config.build.wrapper;

          devShells.default = inputs.devshell.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mkShell {
            name = "nix-config";
            motd = "";
            packages = [
              pkgs.nh
              pkgs.nvd
              pkgs.gitleaks
            ];
          };

          checks = {
            formatting = treefmt.config.build.check inputs.self;
            gitleaks =
              pkgs.runCommand "gitleaks"
                {
                  nativeBuildInputs = [ pkgs.gitleaks ];
                }
                ''
                  gitleaks detect --source ${inputs.self} --verbose --no-git
                  touch $out
                '';
            nixos-build = inputs.self.nixosConfigurations.nixos.config.system.build.toplevel;
            home-build = inputs.self.homeConfigurations."ukasha@nixos".activationPackage;
          };
        };
    };
}
