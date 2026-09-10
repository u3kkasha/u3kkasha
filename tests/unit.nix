{
  pkgs,
  lib,
}:
let
  inherit (lib) internal;
  discoveredPaths =
    root:
    lib.sort builtins.lessThan (
      map (path: lib.removePrefix "${toString root}/" (toString path)) (internal.scanPaths root)
    );
  testResults = lib.runTests {
    testHomeScanPathsDiscoversModules = {
      expr = discoveredPaths ../modules/home;
      expected = [
        "bash.nix"
        "cli.nix"
        "codegraph.nix"
        "codex.nix"
        "direnv.nix"
        "ghostty.nix"
        "git.nix"
        "helix.nix"
        "mcp.nix"
        "niri.nix"
        "nixd.nix"
        "nushell.nix"
        "opencode.nix"
        "snip.nix"
        "spec-kit.nix"
        "utils.nix"
        "wlsunset.nix"
        "wsl.nix"
        "yazi.nix"
        "zellij.nix"
      ];
    };
    testNixosScanPathsDiscoversModules = {
      expr = discoveredPaths ../modules/nixos;
      expected = [
        "desktop"
        "docker"
        "gaming"
        "system"
      ];
    };
    testSharedGitIdentityIsAbsent = {
      expr = {
        hasName = internal ? name;
        hasEmail = internal ? email;
      };
      expected = {
        hasName = false;
        hasEmail = false;
      };
    };
    testUnfreePolicyIsExact = {
      expr = {
        allowed = map internal.allowUnfreePredicate [
          { name = "steam-1"; }
          { name = "steam-original-1"; }
          { name = "steam-unwrapped-1"; }
        ];
        rejected = internal.allowUnfreePredicate { name = "unrelated-unfree-1"; };
      };
      expected = {
        allowed = [
          true
          true
          true
        ];
        rejected = false;
      };
    };
    testSharedNiriHasNoPhysicalOutput = {
      expr = lib.hasInfix ''output "eDP-1"'' (builtins.readFile ../modules/home/niri.nix);
      expected = false;
    };
    testNixdAvoidsUnsafeStringContextDiscard = {
      expr = lib.hasInfix "unsafeDiscardStringContext" (builtins.readFile ../modules/home/nixd.nix);
      expected = false;
    };
    testVmTestsUseCanonicalUsername = {
      expr =
        builtins.all
          (
            path:
            let
              source = builtins.readFile path;
            in
            lib.hasInfix "lib.internal.username" source && !(lib.hasInfix "ukasha" source)
          )
          [
            ../tests/vm-nixos.nix
            ../tests/vm-wsl-mock.nix
          ];
      expected = true;
    };
  };
in
if testResults == [ ] then
  pkgs.runCommand "unit-tests" { } ''
    touch "$out"
  ''
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
