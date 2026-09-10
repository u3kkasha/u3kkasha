{
  pkgs,
  inputs,
  specialArgs,
}:

let
  username = specialArgs.lib.internal.username;
in
pkgs.testers.runNixOSTest {
  name = "wsl-isolation-test";

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

    # Verify the system is lean
    machine.fail("systemctl is-enabled sddm.service")
    machine.fail("systemctl is-active display-manager.service")
    machine.fail("systemctl is-active pipewire.service")

    # Verify the user and shell still work
    machine.succeed("getent passwd ${username} | grep /bin/nu")
    machine.succeed("test -e /etc/profiles/per-user/${username}/bin/nu")

    # Verify GUI packages are absent
    machine.fail("which firefox")
    machine.fail("which wl-clipboard")

    # Verify conventional Docker Engine and Compose are available without Podman.
    machine.succeed("docker --version")
    machine.succeed("docker compose version")
    machine.wait_for_unit("docker.service")
    machine.succeed("su - ${username} -c 'docker info'")
    machine.fail("command -v podman")
  '';
}
