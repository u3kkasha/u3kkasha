{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.wsl;
in
{
  options.internal.wsl = {
    enable = mkEnableOption "WSL-specific home configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wsl-open
    ];

    # Optional: Alias xdg-open to wsl-open for better integration
    home.shellAliases = {
      open = "wsl-open";
    };
  };
}
