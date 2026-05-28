{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "clean";
  runtimeInputs = [ pkgs.nh ];
  text = ''
    echo "Cleaning up Nix store and generations..."
    nh clean all "$@"
  '';
}
