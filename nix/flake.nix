{
  description = "Multi-System Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      treefmt-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "ukasha";
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtConfig = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      specialArgs = {
        inherit inputs username;
      };
    in
    {
      nixosConfigurations = {
        # NixOS WSL
        nixos-wsl = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            ./hosts/wsl/configuration.nix
          ];
        };
        # Bare-metal NixOS
        nixos = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/nixos/configuration.nix
          ];
        };
        # VM configuration
        vm = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/vm/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        # Standalone Home Manager for standard Linux (e.g. Kali)
        "${username}@linux" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = specialArgs;
          modules = [ ./hosts/linux/home.nix ];
        };
      };

      # Use 'nix fmt' to format the whole repository
      formatter.${system} = treefmtConfig.config.build.wrapper;
      # Use 'nix flake check' to verify formatting
      checks.${system}.formatting = treefmtConfig.config.build.check self;

      # Custom packages
      packages.${system} = rec {
        aspire-cli = pkgs.callPackage ./pkgs/aspire-cli.nix { };

        # Maintenance scripts
        apply = pkgs.writeShellApplication {
          name = "apply";
          runtimeInputs = [ pkgs.nh ];
          text = ''
            HOST=$(hostname)
            echo "Applying configuration for host: $HOST"
            nh os switch --diff always . -H "$HOST" "$@"
          '';
        };

        clean = pkgs.writeShellApplication {
          name = "clean";
          runtimeInputs = [ pkgs.nh ];
          text = ''
            echo "Cleaning up Nix store and generations..."
            nh clean all
            nix-collect-garbage -d
            sudo nix-collect-garbage -d
          '';
        };

        test-actions = pkgs.writeShellApplication {
          name = "test-actions";
          runtimeInputs = [ pkgs.act ];
          text = ''
            export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
            echo "Testing GitHub Actions locally..."
            act -W .. -j verify --remote-name origin --container-options "--privileged --userns=host" "$@"
          '';
        };
      };

      # Flake apps for easy execution
      apps.${system} = {
        apply = {
          type = "app";
          program = "${self.packages.${system}.apply}/bin/apply";
        };
        clean = {
          type = "app";
          program = "${self.packages.${system}.clean}/bin/clean";
        };
        test-actions = {
          type = "app";
          program = "${self.packages.${system}.test-actions}/bin/test-actions";
        };
      };

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
