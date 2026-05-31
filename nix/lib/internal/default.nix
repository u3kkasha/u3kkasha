{ lib }:
{
  username = "ukasha";
  name = "Fida Waseque Choudhury";
  email = "fida.waseque@gmail.com";
  defaultEditor = "hx";
  defaultTerminal = "ghostty";
  themeFlavor = "mocha";
  systemStateVersion = "25.11";
  homeStateVersion = "25.11";

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
