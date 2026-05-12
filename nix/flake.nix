{
  description = "NixOS WSL Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      nix-index-database,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "nixos";
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtConfig = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit username nix-index-database;
        };
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./configuration.nix
        ];
      };

      # Use 'nix fmt' to format the whole repository
      formatter.${system} = treefmtConfig.config.build.wrapper;
      # Use 'nix flake check' to verify formatting
      checks.${system}.formatting = treefmtConfig.config.build.check self;

      # Development shell with formatting and linting tools
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          treefmtConfig.config.build.wrapper
          pkgs.statix
          pkgs.deadnix
          pkgs.prettier
          pkgs.gitleaks
          pkgs.act
        ];
      };
    };
}
