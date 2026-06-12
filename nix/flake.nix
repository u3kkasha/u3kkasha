{
  description = "Multi-System Nix Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
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
    catppuccin.url = "github:catppuccin/nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    noctalia-shell.url = "github:noctalia-dev/noctalia-shell";
    noctalia-shell.inputs.nixpkgs.follows = "nixpkgs";
  };
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1H2rnfjkW8Vgi8M96u6Vny89Y460GqT8m2R27Yrg="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
  outputs =
    inputs:
    let
      internalLib = import ./lib/internal/default.nix { inherit (inputs.nixpkgs) lib; };
      extendedLib = inputs.nixpkgs.lib.extend (
        _final: _prev: {
          internal = internalLib;
          inherit (inputs.home-manager.lib) hm;
        }
      );
      specialArgs = {
        inherit (inputs) self;
        inherit inputs;
        namespace = "internal";
        lib = extendedLib;
      };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      flake =
        let
          sharedHomeModules = [
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-index-database.homeModules.nix-index
          ];
          sharedNixosModules = [
            ./modules/nixos/default.nix
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = sharedHomeModules;
            }
          ];
        in
        {
          nixosModules = {
            core = {
              imports = sharedNixosModules;
            };
          };
          nixosConfigurations = {
            nixos = inputs.nixpkgs.lib.nixosSystem {
              inherit specialArgs;
              modules = [
                inputs.self.nixosModules.core
                ./systems/x86_64-linux/nixos/default.nix
                {
                  home-manager.users.${extendedLib.internal.username} = {
                    imports = [
                      inputs.noctalia-shell.homeModules.default
                      ./modules/home/noctalia/config.nix
                    ];
                  };
                }
                { nixpkgs.config.allowUnfree = true; }
              ];
            };
            nixos-wsl = inputs.nixpkgs.lib.nixosSystem {
              inherit specialArgs;
              modules = [
                inputs.self.nixosModules.core
                ./systems/x86_64-linux/nixos-wsl/default.nix
                { nixpkgs.config.allowUnfree = true; }
              ];
            };
          };
        };
      perSystem =
        { pkgs, system, ... }:
        let
          treefmt = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./..;
            hooks = {
              nix-flake-check = {
                enable = true;
                name = "nix flake check";
                entry = "nix flake check ./nix --impure";
                pass_filenames = false;
                stages = [ "pre-push" ];
              };
            };
          };
        in
        {
          formatter = treefmt.config.build.wrapper;
          devShells.default = inputs.devshell.legacyPackages.${system}.mkShell {
            imports = [
              "${inputs.devshell}/extra/git/hooks.nix"
            ];
            name = "nix-config";
            motd = "";
            env = [
              {
                name = "NH_FLAKE";
                eval = "$PRJ_ROOT";
              }
            ];
            git.hooks = {
              enable = true;
              pre-push.text = ''
                nix flake check ./nix --impure
              '';
            };
            packages = [
              pkgs.nh
              pkgs.nvd
              pkgs.gitleaks
            ];
          };
          packages = {
            nixos-build = inputs.self.nixosConfigurations.nixos.config.system.build.toplevel;
            nixos-wsl-build = inputs.self.nixosConfigurations.nixos-wsl.config.system.build.toplevel;
            # Integration Tests (Heavy - CI Only)
            vm-test-nixos = import ./tests/vm-nixos.nix { inherit pkgs inputs specialArgs; };
            vm-test-wsl-mock = import ./tests/vm-wsl-mock.nix { inherit pkgs inputs specialArgs; };
            unit-tests = import ./tests/unit.nix {
              inherit pkgs;
              lib = extendedLib;
            };
          };
          checks = {
            pre-push = pre-commit-check;
            formatting = treefmt.config.build.check inputs.self;
            unit-tests = import ./tests/unit.nix {
              inherit pkgs;
              lib = extendedLib;
            };
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
