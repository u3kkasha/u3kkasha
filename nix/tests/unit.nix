{ pkgs, lib }:
let
  # Use the internal lib passed from flake.nix for consistency
  inherit (lib) internal;

  # Simple pure-Nix unit tests using lib.runTests
  testResults = lib.runTests {
    testUsername = {
      expr = internal.username;
      expected = "ukasha";
    };
    testDefaultEditor = {
      expr = internal.defaultEditor;
      expected = "hx";
    };
    testEmailFormat = {
      expr = lib.strings.isString internal.email;
      expected = true;
    };
  };
in
if testResults == [ ] then
  pkgs.runCommand "unit-tests" { } "touch $out"
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
