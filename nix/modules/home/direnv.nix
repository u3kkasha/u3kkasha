{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    stdlib = ''
      use_flox() {
        local flox_dir=".flox"
        local args=()
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --dir=*)
              flox_dir="''${1#*=}"/.flox
              args+=("$1")
              shift
              ;;
            --dir)
              if [[ $# -lt 2 ]]; then
                printf "direnv(use_flox): --dir flag requires a path argument\n" >&2
                return 1
              fi
              flox_dir="$2"/.flox
              args+=("$1" "$2")
              shift 2
              ;;
            *)
              args+=("$1")
              shift
              ;;
          esac
        done
        if [[ ! -d "$flox_dir" ]]; then
          printf "direnv(use_flox): \`.flox\` directory not found at %s\n" "$flox_dir" >&2
          printf "direnv(use_flox): Did you run \`flox init\` in this directory?\n" >&2
          return 1
        fi
        direnv_load flox activate "''${args[@]}" -- "$direnv" dump
      }
    '';
  };
}
