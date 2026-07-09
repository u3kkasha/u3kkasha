{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.opencode;
  package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
in
{
  options.internal.opencode = {
    enable = mkEnableOption "OpenCode configuration";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      inherit package;
      settings = {
        "$schema" = "https://opencode.ai/config.json";
        instructions = [
          "AGENTS.md"
          "CONTEXT.md"
        ];
        plugin = [
          "opencode-snip@latest"
          "@tarquinen/opencode-dcp@latest"
          "opencode-websearch-cited@1.1.1"
        ];
      };
    };
  };
}
