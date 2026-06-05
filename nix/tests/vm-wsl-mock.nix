{
  pkgs,
  inputs,
  specialArgs,
}:

pkgs.testers.runNixOSTest {
  name = "wsl-isolation-test";

  node.specialArgs = specialArgs;

  nodes.machine =
    { ... }:
    {
      imports = [
        ../modules/nixos/system/default.nix
        ../modules/nixos/podman/default.nix
        ../modules/nixos/docker/default.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-index-database.nixosModules.nix-index
      ];

      internal.system.enable = true;
      internal.podman.enable = true;
      internal.docker.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = specialArgs;
        sharedModules = [
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.catppuccin.homeModules.catppuccin
          inputs.nix-index-database.homeModules.nix-index
        ];
      };
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Verify the system is lean
    machine.fail("systemctl is-enabled sddm.service")
    machine.fail("systemctl is-active display-manager.service")
    machine.fail("systemctl is-active pipewire.service")

    # Verify the user and shell still work
    machine.succeed("getent passwd ukasha | grep /bin/nu")

    # Verify GUI packages are absent
    machine.fail("which firefox")
    machine.fail("which wl-clipboard")

    # Verify podman is functional in WSL
    machine.succeed("podman --version")

    # Verify docker is functional in WSL
    machine.wait_for_unit("docker.service")
    machine.succeed("docker --version")
    machine.succeed("docker-compose --version")
  '';
}
