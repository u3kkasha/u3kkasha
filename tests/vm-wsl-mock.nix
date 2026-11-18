{
  pkgs,
  inputs,
  specialArgs,
}:

let
  username = specialArgs.internal.username;
in
pkgs.testers.runNixOSTest {
  name = "wsl-host-test";

  node.specialArgs = specialArgs;

  nodes.machine =
    { lib, ... }:
    {
      imports = [
        inputs.self.nixosModules.core
        inputs.nixos-wsl.nixosModules.default
        ../systems/x86_64-linux/nixos-wsl/default.nix
      ];

      # The host's WSL boot integration cannot run inside a QEMU test VM.
      # Everything else, including the real host module and HM user, is evaluated.
      wsl.enable = lib.mkForce false;
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Verify Docker and Compose are usable by the configured user.
    machine.wait_for_unit("docker.service")
    machine.succeed("su - ${username} -c 'docker info'")
    machine.succeed("su - ${username} -c 'docker compose version'")
  '';
}
