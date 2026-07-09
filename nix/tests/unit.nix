{
  pkgs,
  lib,
  nixosConfigurations,
}:
let
  inherit (lib) internal;
  inherit (nixosConfigurations) nixos nixos-wsl;
  homeConfig = nixos.config.home-manager.users.${internal.username};
  mcpServers = homeConfig.programs.mcp.servers;

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
    testMcpRegistry = {
      expr = builtins.attrNames mcpServers;
      expected = [
        "context7"
        "dotnet-debugger"
        "gh-grep"
        "github"
        "microsoft-learn"
        "nixos"
        "nuget"
        "nushell"
        "nuxt"
        "nuxt-ui"
        "playwright"
        "semble"
        "serena"
        "skylos"
      ];
    };
    testPackagedMcpServers = {
      expr = builtins.all (name: lib.hasPrefix "/nix/store/" mcpServers.${name}.command) [
        "github"
        "nixos"
        "playwright"
        "semble"
        "serena"
      ];
      expected = true;
    };
    testAgentPackages = {
      expr = {
        antigravity = homeConfig.programs.antigravity-cli.package.pname;
        codex = homeConfig.programs.codex.package.pname;
        opencode = homeConfig.programs.opencode.package.pname;
      };
      expected = {
        antigravity = "antigravity-cli";
        codex = "codex";
        opencode = "opencode";
      };
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
