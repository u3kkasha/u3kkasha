{
  pkgs,
  lib,
  internal,
}:
let
  discoveryFixture = ./fixtures/scan-paths;
  discoveredFixturePaths = internal.scanPaths discoveryFixture;
  discovers = name: builtins.elem (discoveryFixture + "/${name}") discoveredFixturePaths;
  testResults = lib.runTests {
    testScanPathsContract = {
      expr = {
        includesNixFile = discovers "eligible-module.nix";
        includesDirectoryWithDefault = discovers "with-default";
        excludesRootDefault = !(discovers "default.nix");
        excludesNonNixFile = !(discovers "notes.txt");
        excludesDirectoryWithoutDefault = !(discovers "without-default");
      };
      expected = {
        includesNixFile = true;
        includesDirectoryWithDefault = true;
        excludesRootDefault = true;
        excludesNonNixFile = true;
        excludesDirectoryWithoutDefault = true;
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
  };
in
if testResults == [ ] then
  pkgs.runCommand "unit-tests" { } ''
    touch "$out"
  ''
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
