{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.codex;
  package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.tomlkit ]);
  mergeCodexConfig = pkgs.writeShellScript "merge-codex-config" ''
    exec ${python}/bin/python3 ${./codex-merge.py} "$@"
  '';
  codexConfigTarget =
    if config.home.preferXdgDirectories then
      "${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/codex/config.toml"
    else
      ".codex/config.toml";
  upstreamConfigToml = config.home.file.${codexConfigTarget}.source;
in
{
  options.internal.codex = {
    enable = mkEnableOption "codex AI agent configuration";
  };

  config = mkIf cfg.enable {
    programs.codex = {
      enable = true;
      inherit package;
      enableMcpIntegration = true;
    };

    # Keep Home Manager's canonical generated config as the merge source, but
    # do not link it over the user-owned writable file.
    home.file.${codexConfigTarget}.enable = false;

    home.activation.copyCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      configFile="$HOME/${codexConfigTarget}"
      configDir="$(dirname "$configFile")"
      baseConfig="${upstreamConfigToml}"

      mkdir -p "$configDir"

      if [ -f "$configFile" ] && [ ! -L "$configFile" ]; then
        ${mergeCodexConfig} "$baseConfig" "$configFile"
      else
        rm -f "$configFile"
        install -m 600 "$baseConfig" "$configFile"
      fi
    '';
  };
}
