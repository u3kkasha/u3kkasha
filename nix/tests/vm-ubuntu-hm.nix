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

      # 1. Setup the correct user (matching the flake config)
      vm.succeed("useradd -m -s /bin/bash ukasha")
      vm.succeed("echo 'ukasha ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ukasha")
      # Add to nix-users group to ensure access to the nix-daemon
      vm.succeed("groupadd -r nix-users || true")
      vm.succeed("usermod -aG nix-users ukasha")

      # 2. Ensure Nix is functional with flakes enabled
      vm.succeed("mkdir -p /etc/nix")
      vm.succeed("echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf")
      vm.succeed("systemctl restart nix-daemon || true")

      # 3. Run Home Manager activation from the shared flake
      # We use the absolute path to nix or ensure it's in the PATH
      # We use the 'nixos-wsl' config as it is designed for headless/lean environments
      vm.succeed(
        "sudo -i -u ukasha env PATH=\"$PATH:/nix/var/nix/profiles/default/bin\" nix run 'github:nix-community/home-manager' -- \
          switch --flake /repo/nix#ukasha@nixos-wsl --impure --show-trace"
      )

      # 4. Verification
      # Check if nushell is available and functional (it's part of the HM config)
      vm.succeed("sudo -i -u ukasha env PATH=\"$PATH:/home/ukasha/.nix-profile/bin\" nu -c 'echo \"Home Manager works on Ubuntu!\"'")

      # Check if git is configured as per the module
      vm.succeed("sudo -i -u ukasha env PATH=\"$PATH:/home/ukasha/.nix-profile/bin\" git config --get user.name | grep 'Fida Waseque Choudhury'")

      # Ensure no KDE services leaked into Ubuntu headless VM
      vm.fail("systemctl is-active sddm")
    '';
  };
in
ubuntuTest.sandboxed
