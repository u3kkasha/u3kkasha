{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.nushell;
in
{
  options.internal.nushell = {
    enable = mkEnableOption "Nushell configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."nushell/autoload/devenv-hook.nu".source = pkgs.runCommand "devenv-hook.nu" { } ''
      ${pkgs.devenv}/bin/devenv hook nu > "$out"
    '';

    programs.nushell = {
      enable = true;
      loadSessionVariables = true;
      environmentVariables = config.home.sessionVariables;
      extraConfig = ''
        def --wrapped nix [...args: string] {
          let token_result = (^gh auth token | complete)
          if $token_result.exit_code == 0 and not ($token_result.stdout | str trim | is-empty) {
            let existing_config = ($env.NIX_CONFIG? | default "")
            let separator = if ($existing_config | is-empty) { "" } else { "\n" }
            with-env [NIX_CONFIG $"($existing_config)($separator)access-tokens = github.com=($token_result.stdout | str trim)"] {
              ^nix ...$args
            }
          } else {
            ^nix ...$args
          }
        }
      '';
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
