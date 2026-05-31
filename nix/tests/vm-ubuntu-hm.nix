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

      # Repo is mounted from host and usually read-only


      # 1. Setup the correct user (matching the flake config)
      vm.succeed("useradd -m -s /bin/bash ukasha")
      vm.succeed("echo 'ukasha ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ukasha")

      # 2. Setup Nix and ensure it's available in the shell
      # We source /etc/profile.d/nix.sh which is standard for multi-user Nix
      vm.succeed("mkdir -p /etc/nix")
      vm.succeed("echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf")
      # Restarting nix-daemon is good practice if it exists
      vm.execute("systemctl restart nix-daemon")

      # 3. Run Home Manager activation
      # We explicitly source the Nix profile to be 100% sure
      vm.succeed(
        "sudo -i -u ukasha bash -c \"source /etc/profile.d/nix.sh && nix run 'github:nix-community/home-manager' -- \
          switch --flake /repo/nix#ukasha@nixos-wsl --impure --show-trace\""
      )

      # 4. Verification
      vm.succeed("sudo -i -u ukasha bash -c \"source /etc/profile.d/nix.sh && source \\$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh && nu -c 'echo \\\"Home Manager works on Ubuntu!\\\"'\"")
      vm.succeed("sudo -i -u ukasha bash -c \"source /etc/profile.d/nix.sh && git config --get user.name | grep 'Fida Waseque Choudhury'\"")

      # Ensure no KDE services leaked into Ubuntu headless VM
      vm.fail("systemctl is-active sddm")
    '';
  };
in
ubuntuTest.sandboxed
