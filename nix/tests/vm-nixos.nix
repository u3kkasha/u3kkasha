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
        inputs.self.nixosModules.core
      ];

      internal.system.enable = true;
      internal.podman.enable = true;
      internal.desktop.enable = true;
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Check if the user was created correctly with the right shell
    machine.succeed("getent passwd ukasha | grep /bin/nu")

    # Check if podman is available
    machine.succeed("podman --version")

    # The selected container runtime is exclusive.
    machine.fail("systemctl is-enabled docker.service")

    # Check if desktop services are configured
    machine.wait_for_unit("display-manager.service")
    machine.succeed("systemctl status display-manager.service")
  '';
}
