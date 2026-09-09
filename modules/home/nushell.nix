{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.nushell;
  package = pkgs.nushell.override {
    additionalFeatures = features: features ++ [ "mcp" ];
  };
in
{
  options.internal.nushell = {
    enable = mkEnableOption "Nushell configuration";
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      inherit package;
      environmentVariables = config.home.sessionVariables;
      settings = {
        show_banner = false;
        edit_mode = "vi";
        history = {
          file_format = "sqlite";
        };
      };
    };
  };
}
