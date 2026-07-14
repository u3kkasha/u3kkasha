{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.codegraph;
  package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codegraph;
in
{
  options.internal.codegraph = {
    enable = mkEnableOption "Codegraph semantic code intelligence";
  };

  config = mkIf cfg.enable {
    home.packages = [ package ];
  };
}
