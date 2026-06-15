{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.opencode;
in
{
  options.internal.opencode = {
    enable = mkEnableOption "OpenCode configuration";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
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
