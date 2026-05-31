{ pkgs, lib }:
let
  internalLib = import ../lib/internal/default.nix;

  # Simple pure-Nix unit tests using lib.runTests
  testResults = lib.runTests {
    testUsername = {
      expr = internalLib.username;
      expected = "ukasha";
    };
    testDefaultEditor = {
      expr = internalLib.defaultEditor;
      expected = "hx";
    };
    testEmailFormat = {
      expr = lib.strings.isString internalLib.email;
      expected = true;
    };
  };
in
if testResults == [ ] then
  pkgs.runCommand "unit-tests" { } "touch $out"
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
