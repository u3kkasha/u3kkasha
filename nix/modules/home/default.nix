{
  pkgs,
  config,
  lib,
  osConfig ? null,
  ...
}:

let
  inherit (lib.internal)
    username
    homeStateVersion
    scanPaths
    ;
  geminiSettings = builtins.toJSON {
    mcpServers = lib.internal.mcp.geminiMcp;
  };
  geminiSettingsFile = pkgs.writeText "gemini-settings.json" geminiSettings;
in
{
  imports = scanPaths ./.;

  options.internal = {
    gemini-cli.enable = lib.mkEnableOption "Gemini CLI configuration";

    hostName = lib.mkOption {
      type = lib.types.str;
      default =
        if osConfig != null then
          osConfig.networking.hostName
        else
          throw "internal.hostName must be explicitly set for standalone Home Manager configurations";
      description = "The target hostname/system configuration name.";
    };

    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable GUI-related configurations.";
      };
    };
  };

  config = {
    internal = {
      bash.enable = lib.mkDefault true;
      cli.enable = lib.mkDefault true;
      direnv.enable = lib.mkDefault true;
      antigravity.enable = lib.mkDefault true;
      gemini-cli.enable = lib.mkDefault true;
      ghostty.enable = lib.mkDefault config.internal.gui.enable;
      herdr.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      helix.enable = lib.mkDefault true;
      nushell.enable = lib.mkDefault true;
      opencode.enable = lib.mkDefault true;
      gnome.enable = lib.mkDefault config.internal.gui.enable;
      utils.enable = lib.mkDefault true;
      snip.enable = lib.mkDefault true;
      wsl.enable = lib.mkDefault false;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault true;
    };

    dconf.settings = lib.mkForce { };

    home.username = username;
    home.homeDirectory = "/home/${username}";

    home.sessionVariables = {
      EDITOR = lib.internal.defaultEditor;
      VISUAL = lib.internal.defaultEditor;
    };

    home.packages = lib.mkIf config.internal.gemini-cli.enable [ pkgs.gemini-cli ];

    home.activation.geminiCliSettings = lib.mkIf config.internal.gemini-cli.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        target="$HOME/.gemini/settings.json"
        if [ -L "$target" ]; then
          $DRY_RUN_CMD rm "$target"
          $DRY_RUN_CMD install -Dm600 ${geminiSettingsFile} "$target"
        elif [ ! -e "$target" ]; then
          $DRY_RUN_CMD install -Dm600 ${geminiSettingsFile} "$target"
        fi
      ''
    );

    nix.package = lib.mkDefault pkgs.lix;

    home.stateVersion = homeStateVersion;

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      gemini-cli.enable = false;
    };
  };
}
