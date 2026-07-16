{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.snip;

  # Helper to generate a standardized Nix output filter
  mkNixFilter = commandName: {
    name = commandName;
    version = 1;
    description = "Filters ${commandName} output to remove verbose copy, download, and build progress lines while keeping errors.";
    match = {
      command = commandName;
    };
    streams = [
      "stdout"
      "stderr"
    ];
    pipeline = [
      { action = "strip_ansi"; }
      {
        action = "remove_lines";
        # Matches copying, downloading, fetching paths, and lists of derivations to be built
        pattern = "(?i)^\\s*(copying path|downloading|fetching|these \\d+ paths|these \\d+ derivations|\\s{2,}/nix/store/)";
      }
      {
        action = "remove_lines";
        # Matches progress indicators like [1/2/3]
        pattern = "^\\[\\d+/\\d+/\\d+\\]";
      }
    ];
  };
in
{
  options.internal.snip = {
    enable = mkEnableOption "snip LLM token optimizer configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.snip ];

    # Deploy declarative filter files to ~/.config/snip/filters/
    home.file = {
      ".config/snip/filters/nix.yaml".text = builtins.toJSON (mkNixFilter "nix");
      ".config/snip/filters/nh.yaml".text = builtins.toJSON (mkNixFilter "nh");
      ".config/snip/filters/nixos-rebuild.yaml".text = builtins.toJSON (mkNixFilter "nixos-rebuild");
      ".config/snip/filters/home-manager.yaml".text = builtins.toJSON (mkNixFilter "home-manager");
    };
  };
}
