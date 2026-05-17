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
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs supportedSystems f;

      username = "ukasha";
      systemStateVersion = "25.11";
      homeStateVersion = "25.11";

      specialArgs = {
        inherit
          inputs
          username
          systemStateVersion
          homeStateVersion
          ;
      };
    in
    {
      nixosConfigurations = {
        # NixOS WSL
        nixos-wsl = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            ./hosts/wsl/configuration.nix
          ];
        };
        # Bare-metal NixOS
        nixos = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            home-manager.nixosModules.home-manager
            ./hosts/nixos/configuration.nix
          ];
        };
        # VM configuration
        vm = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            home-manager.nixosModules.home-manager
            ./hosts/vm/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        # Standalone Home Manager for standard Linux (e.g. Kali)
        "${username}@linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = specialArgs;
          modules = [ ./hosts/linux/home.nix ];
        };
      };

      # Use 'nix fmt' to format the whole repository
      formatter = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          treefmtConfig = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        treefmtConfig.config.build.wrapper
      );

      # Use 'nix flake check' to verify formatting
      checks = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          treefmtConfig = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          formatting = treefmtConfig.config.build.check self;
        }
      );

      # Custom packages
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          aspire-cli = pkgs.callPackage ./pkgs/aspire-cli.nix { };

          # Maintenance scripts
          apply = pkgs.writeShellApplication {
            name = "apply";
            runtimeInputs = [
              pkgs.nh
              pkgs.nvd
              pkgs.hostname
              pkgs.jq
              pkgs.nix
            ];
            text = ''
              HOST=$(hostname)

              # Ensure we are in the flake directory or use NH_FLAKE
              FLAKE_DIR=''${NH_FLAKE:-$(pwd)}
              if [ ! -f "$FLAKE_DIR/flake.nix" ]; then
                echo "Error: Could not find flake.nix in $FLAKE_DIR"
                echo "Please run from the dotfiles directory or set NH_FLAKE"
                exit 1
              fi

              echo "Formatting and checking configuration..."
              nix fmt "$FLAKE_DIR" > /dev/null

              echo "Applying configuration for host: $HOST"
              if [ -e /etc/NIXOS ]; then
                # NixOS system
                CURRENT_GEN=$(readlink -f /run/current-system)
                nh os switch --diff always "$FLAKE_DIR" -H "$HOST" "$@"
                nvd diff "$CURRENT_GEN" /run/current-system
              else
                # Standalone Home Manager
                CONF_NAME="${username}@$HOST"
                # Fallback to username@linux if specific host config doesn't exist
                if ! nix flake show "$FLAKE_DIR" --json | jq -e ".homeConfigurations.\"$CONF_NAME\"" > /dev/null; then
                  CONF_NAME="${username}@linux"
                fi
                
                CURRENT_GEN=$(readlink -f ~/.local/state/nix/profiles/home-manager)
                nh home switch --diff always "$FLAKE_DIR" -H "$CONF_NAME" "$@"
                nvd diff "$CURRENT_GEN" ~/.local/state/nix/profiles/home-manager
              fi
            '';
          };

          clean = pkgs.writeShellApplication {
            name = "clean";
            runtimeInputs = [ pkgs.nh ];
            text = ''
              echo "Cleaning up Nix store and generations..."
              nh clean all "$@"
            '';
          };

        }
      );

      # Flake apps for easy execution
      apps = forEachSystem (system: {
        apply = {
          type = "app";
          program = "${self.packages.${system}.apply}/bin/apply";
          meta = {
            description = "Apply the NixOS/Home Manager configuration";
          };
        };
        clean = {
          type = "app";
          program = "${self.packages.${system}.clean}/bin/clean";
          meta = {
            description = "Clean up Nix store and generations";
          };
        };
      });

      # Development shell with formatting and linting tools
      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          treefmtConfig = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              treefmtConfig.config.build.wrapper
              pkgs.statix
              pkgs.deadnix
              pkgs.prettier
              pkgs.gitleaks
            ];
          };
        }
      );
    };
}
