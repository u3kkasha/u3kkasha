{ namespace, ... }:

{
  imports = [
    # Import the main home module which includes all others
    # Since this file is in homes/x86_64-linux/ukasha/default.nix,
    # the path to modules/home/default.nix is ../../../modules/home/default.nix
    ../../../modules/home/default.nix
  ];
}
