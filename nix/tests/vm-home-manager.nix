{
  pkgs,
  inputs,
  specialArgs,
}:

pkgs.testers.runNixOSTest {
  name = "home-manager-standalone-test";

  node.specialArgs = specialArgs;

  nodes.machine =
    { ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-index-database.nixosModules.nix-index
      ];

      # NO custom system modules imported here to prove HM independence

      users.users.ukasha = {
        isNormalUser = true;
        home = "/home/ukasha";
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ukasha = import ../modules/home/default.nix;
        extraSpecialArgs = specialArgs;
        sharedModules = [
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.catppuccin.homeModules.catppuccin
        ];
      };

      fileSystems."/" = {
        device = "/dev/vda1";
        fsType = "ext4";
      };
      boot.loader.grub.device = "/dev/vda";
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Wait for HM activation (check for a file HM manages)
    machine.wait_for_file("/home/ukasha/.config/git/config")

    # Check if HM packages are in the PATH for the user
    machine.succeed("su - ukasha -c 'git --version'")

    # Verify nushell is configured
    machine.succeed("su - ukasha -c 'nu -c \"echo hello\"'")
  '';
}
