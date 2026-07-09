{
  pkgs,
  lib,
  nixosConfigurations,
}:
let
  inherit (lib) internal;
  inherit (nixosConfigurations) nixos nixos-wsl;

  testResults = lib.runTests {
    testScanPathsDiscoversModules = {
      expr = map (path: lib.removePrefix "${toString ../modules/home}/" (toString path)) (
        internal.scanPaths ../modules/home
      );
      expected = [
        "antigravity.nix"
        "bash.nix"
        "cli.nix"
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
        "utils.nix"
        "wlsunset.nix"
        "wsl.nix"
        "yazi.nix"
        "zellij.nix"
      ];
    };
    testEmailFormat = {
      expr = builtins.match "[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+" internal.email != null;
      expected = true;
    };
    testNixosHostName = {
      expr = nixos.config.networking.hostName;
      expected = "nixos";
    };
    testNixosStateVersion = {
      expr = nixos.config.system.stateVersion;
      expected = internal.systemStateVersion;
    };
    testWslHostName = {
      expr = nixos-wsl.config.networking.hostName;
      expected = "nixos-wsl";
    };
    testWslEnabled = {
      expr = nixos-wsl.config.internal.wsl.enable;
      expected = true;
    };
    testWslHomeManagerUser = {
      expr = nixos-wsl.config.home-manager.users.${internal.username}.internal.wsl.enable;
      expected = true;
    };
    testWslGuiDisabled = {
      expr = nixos-wsl.config.home-manager.users.${internal.username}.internal.gui.enable;
      expected = false;
    };
  };
in
if testResults == [ ] then
  pkgs.runCommand "unit-tests" { } "touch $out"
else
  throw "Unit tests failed: ${builtins.toJSON testResults}"
