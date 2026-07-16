{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.antigravity;
  package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli;
in
{
  options.internal.antigravity = {
    enable = mkEnableOption "Antigravity CLI configuration";
  };

  config = mkIf cfg.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = true;
      inherit package;
    };
  };
}
