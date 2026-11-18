{
  pkgs,
  inputs,
  specialArgs,
}:

let
  username = specialArgs.internal.username;
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

    # Verify Docker and Compose are usable by the configured user.
    machine.wait_for_unit("docker.service")
    machine.succeed("su - ${username} -c 'docker info'")
    machine.succeed("su - ${username} -c 'docker compose version'")

    # Check if desktop services are configured
    machine.wait_for_unit("display-manager.service")
  '';
}
