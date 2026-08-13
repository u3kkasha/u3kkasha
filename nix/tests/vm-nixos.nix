{
  pkgs,
  inputs,
  specialArgs,
}:

let
  username = specialArgs.lib.internal.username;
in
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
      internal.docker.enable = true;
      internal.desktop.enable = true;
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Check if the user was created correctly with the right shell
    machine.succeed("getent passwd ${username} | grep /bin/nu")

    # Verify conventional Docker Engine and Compose are available without Podman.
    machine.succeed("docker --version")
    machine.succeed("docker compose version")
    machine.wait_for_unit("docker.service")
    machine.succeed("systemctl is-active docker.service")
    machine.succeed("su - ${username} -c 'docker info'")
    machine.fail("command -v podman")

    # Check if desktop services are configured
    machine.wait_for_unit("display-manager.service")
    machine.succeed("systemctl status display-manager.service")
    machine.succeed("test -x /run/current-system/sw/bin/niri")
  '';
}
