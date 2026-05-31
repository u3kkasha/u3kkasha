{
  pkgs,
  inputs,
  specialArgs,
}:

pkgs.testers.runNixOSTest {
  name = "nixos-system-test";

  node.specialArgs = specialArgs;

  nodes.machine =
    { ... }:
    {
      imports = [
        ../modules/nixos/system/default.nix
        ../modules/nixos/desktop/default.nix
        ../modules/nixos/podman/default.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-index-database.nixosModules.nix-index
      ];

      internal.system.enable = true;
      internal.podman.enable = true;
      internal.desktop.enable = true;

      # Set home-manager options for the test
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.catppuccin.homeModules.catppuccin
        ];
      };
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Check if the user was created correctly with the right shell
    machine.succeed("getent passwd ukasha | grep /bin/nu")

    # Check if podman is available
    machine.succeed("podman --version")

    # Check if desktop services are enabled (KDE Plasma/SDDM)
    machine.succeed("systemctl is-enabled sddm.service")
    machine.succeed("systemctl is-active display-manager.service")
  '';
}
