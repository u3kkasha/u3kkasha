{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.cli;
in
{
  options.internal.cli = {
    enable = mkEnableOption "CLI tools configuration";
  };

  config = mkIf cfg.enable {
    programs.carapace.enable = true;
    programs.television.enable = true;
    programs.nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
    programs.nix-index-database.comma.enable = true;

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      settings = {
        direnv = {
          disabled = false;
          format = "via [$symbol$loaded/$allowed]($style) ";
          symbol = "󰒋 ";
          style = "bold peach";
        };
        nix_shell = {
          disabled = true;
        };
        directory = {
          truncate_to_repo = false;
          truncation_length = 3;
          style = "bold blue";
        };
      };

    };
  };
}
