{ lib }:
{
  username = "ukasha";
  name = "Fida Waseque Choudhury";
  email = "fida.waseque@gmail.com";
  defaultEditor = "hx";
  defaultTerminal = "ghostty";
  themeFlavor = "mocha";
  systemStateVersion = "26.05";
  homeStateVersion = "26.05";

  # Helper to import all .nix files and directories containing default.nix in a path
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.filterAttrs (
          name: type:
          (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
          || (type == "directory" && builtins.pathExists (path + "/${name}/default.nix"))
        ) (builtins.readDir path)
      )
    );
}
