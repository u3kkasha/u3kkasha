{
  pkgs,
  inputs,
  specialArgs,
}:

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
    machine.succeed("getent passwd ukasha | grep /bin/nu")
    machine.succeed("test -e /etc/profiles/per-user/ukasha/bin/nu")

    # Verify GUI packages are absent
    machine.fail("which firefox")
    machine.fail("which wl-clipboard")

    # Verify Podman is the runtime, with Docker-compatible CLI support for flakes that call docker.
    machine.succeed("podman --version")
    machine.succeed("docker --version")

    # Docker Engine is not enabled.
    machine.fail("systemctl is-enabled docker.service")
  '';
}
