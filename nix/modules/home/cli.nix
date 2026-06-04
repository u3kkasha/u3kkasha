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
        add_newline = true;
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$nix_shell"
          "$fill"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        nix_shell = {
          symbol = "❄️ ";
          format = "via [$symbol$state( \\($name\\))]($style) ";
          style = "bold blue";
          impure_msg = "impure";
          pure_msg = "pure";
        };

        fill = {
          symbol = " ";
        };

        directory = {
          read_only = " 󰌾";
        };

        git_branch = {
          symbol = " ";
        };
      };
    };
  };
}
