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

    # Check if Podman is available with Docker-compatible CLI support.
    machine.succeed("podman --version")
    machine.succeed("docker --version")

    # Docker Engine is not enabled.
    machine.fail("systemctl is-enabled docker.service")

    # Check if desktop services are configured
    machine.wait_for_unit("display-manager.service")
    machine.succeed("systemctl status display-manager.service")
  '';
}
