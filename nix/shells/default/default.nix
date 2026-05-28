{
  pkgs,
  inputs,
  ...
}:

let
  treefmtConfig = inputs.treefmt-nix.lib.evalModule pkgs ./../../treefmt.nix;
in
pkgs.devshell.mkShell {
  name = "nix-dotfiles";
  packages = [
    treefmtConfig.config.build.wrapper
    pkgs.statix
    pkgs.deadnix
    pkgs.prettier
    pkgs.gitleaks
  ];
  commands = [
    {
      name = "apply";
      category = "maintenance";
      help = "Apply the NixOS/Home Manager configuration";
      command = "nix run .#apply";
    }
    {
      name = "clean";
      category = "maintenance";
      help = "Clean up Nix store and generations";
      command = "nix run .#clean";
    }
    {
      name = "fmt";
      category = "maintenance";
      help = "Format the codebase";
      command = "nix fmt";
    }
  ];
}
