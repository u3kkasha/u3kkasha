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
    home.file.".config/opencode/opencode.json" = {
      text = builtins.toJSON {
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
        mcp = lib.internal.mcp.openCodeMcp;
      };
      force = true;
    };
  };
}
