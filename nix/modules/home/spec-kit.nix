{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.specKit;
  package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.spec-kit;
in
{
  options.internal.specKit = {
    enable = mkEnableOption "GitHub Spec Kit CLI configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ package ];
  };
}
