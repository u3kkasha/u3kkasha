{
  lib,
  internal,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.bash;
in
{
  options.internal.bash = {
    enable = mkEnableOption "Bash configuration";
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        eval "$(${pkgs.devenv}/bin/devenv hook bash)"
        nix() {
          local token nix_config
          token="$(gh auth token 2>/dev/null)" || token=""
          if [[ -z "$token" ]]; then
            command nix "$@"
            return $?
          fi
          nix_config="''${NIX_CONFIG-}"
          if [[ -n "$nix_config" ]]; then
            nix_config+=$'\n'
          fi
          NIX_CONFIG="''${nix_config}access-tokens = github.com=$token" command nix "$@"
        }
      '';
      shellAliases = { };
      sessionVariables = {
        EDITOR = internal.defaultEditor;
      };
    };
  };
}
