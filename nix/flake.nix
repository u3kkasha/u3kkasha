{
  description = "Multi-System Nix Flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

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
    catppuccin.url = "github:catppuccin/nix";
    noctalia-shell.url = "github:noctalia-dev/noctalia-shell";
    llm-agents.url = "github:numtide/llm-agents.nix";
    mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";
    mcp-servers-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
            inputs.mcp-servers-nix.homeManagerModules.default
            inputs.nix-index-database.homeModules.nix-index
            inputs.noctalia-shell.homeModules.default
          ];
          sharedNixosModules = [
            ./modules/nixos/default.nix
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
                      ./modules/home/noctalia/config.nix
                    ];
                  };
                }
                { nixpkgs.config.allowUnfree = true; }
              ];
            };
            nixos-wsl = inputs.nixpkgs.lib.nixosSystem {
              inherit specialArgs;
              system = "x86_64-linux";
              modules = [
                inputs.self.nixosModules.core
                inputs.nixos-wsl.nixosModules.default
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
              pre-commit.text = ''
                nix build ./nix#checks.${system}.formatting --no-link
                gitleaks git --staged --redact --no-banner
              '';
              pre-push.text = ''
                nix flake check ./nix
                nix build ./nix#nixos-build ./nix#nixos-wsl-build --no-link
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
            vm-test-nixos = import ./tests/vm-nixos.nix {
              pkgs = import inputs.nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
              inherit inputs specialArgs;
            };
            vm-test-wsl-mock = import ./tests/vm-wsl-mock.nix {
              pkgs = import inputs.nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
              inherit inputs specialArgs;
            };
            unit-tests = import ./tests/unit.nix {
              inherit pkgs;
              lib = extendedLib;
              inherit (inputs.self) nixosConfigurations;
            };
          };
          checks = {
            formatting = treefmt.config.build.check inputs.self;
            unit-tests = import ./tests/unit.nix {
              inherit pkgs;
              lib = extendedLib;
              inherit (inputs.self) nixosConfigurations;
            };
            gitleaks =
              pkgs.runCommand "gitleaks"
                {
                  nativeBuildInputs = [ pkgs.gitleaks ];
                }
                ''
                  gitleaks dir ${inputs.self} --verbose --no-banner
                  touch $out
                '';
          };
        };
    };
}
