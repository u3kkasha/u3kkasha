{
  pkgs,
  inputs,
}:

let
  # Use Numtide's nix-vm-test to target Ubuntu
  # The library is nested under the system attribute (e.g., x86_64-linux)
  ubuntuTest = inputs.nix-vm-test.lib.${pkgs.system}.ubuntu."24_04" {
    # Increase disk size for Nix operations
    sharedDirs = {
      repo = {
        source = inputs.self;
        target = "/repo";
      };
    };

    # Increase disk size for Nix operations
    diskSize = "+4G";

    testScript = ''
      # Wait for the Ubuntu system to boot
      vm.wait_for_unit("multi-user.target")

      # 1. Setup a test user
      vm.succeed("useradd -m -s /bin/bash testuser")
      vm.succeed("echo 'testuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/testuser")

      # 2. Ensure Nix is functional with flakes enabled
      # (nix-vm-test images usually have Nix, but we ensure flakes are enabled)
      vm.succeed("mkdir -p /etc/nix")
      vm.succeed("echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf")
      vm.succeed("systemctl restart nix-daemon || true")

      # 3. Run Home Manager activation from the shared flake
      # We use one of the existing configurations that is relatively minimal
      # Note: We use '--impure' because the shared directory might have untracked changes
      vm.succeed(
        "sudo -i -u testuser nix run 'github:nix-community/home-manager' -- \
          switch --flake /repo/nix#ukasha@nixos-wsl --impure --show-trace"
      )

      # 4. Verification
      # Check if nushell is available and functional (it's part of the HM config)
      vm.succeed("sudo -i -u testuser nu -c 'echo \"Home Manager works on Ubuntu!\"'")

      # Check if git is configured as per the module
      vm.succeed("sudo -i -u testuser git config --get user.name | grep 'Fida Waseque Choudhury'")

      # Ensure no KDE services leaked into Ubuntu headless VM
      vm.fail("systemctl is-active sddm")
    '';
  };
in
ubuntuTest.sandboxed
