{
  pkgs,
  lib,
  namespace,
  ...
}:

let
  inherit (lib.${namespace}) username;
in
pkgs.writeShellApplication {
  name = "apply";
  runtimeInputs = [
    pkgs.nh
    pkgs.nvd
    pkgs.hostname
    pkgs.jq
    pkgs.nix
  ];
  text = ''
    HOST=$(hostname)

    # Ensure we are in the flake directory or use NH_FLAKE
    FLAKE_DIR=''${NH_FLAKE:-$(pwd)}
    if [ ! -f "$FLAKE_DIR/flake.nix" ]; then
      echo "Error: Could not find flake.nix in $FLAKE_DIR"
      echo "Please run from the dotfiles directory or set NH_FLAKE"
      exit 1
    fi

    echo "Formatting and checking configuration..."
    nix fmt "$FLAKE_DIR" > /dev/null

    echo "Applying configuration for host: $HOST"
    if [ -e /etc/NIXOS ]; then
      # NixOS system
      CURRENT_GEN=$(readlink -f /run/current-system)
      nh os switch --diff always "$FLAKE_DIR" -H "$HOST" "$@"
      nvd diff "$CURRENT_GEN" /run/current-system
    else
      # Standalone Home Manager
      CONF_NAME="${username}@$HOST"
      # Fallback to username@system if specific host config doesn't exist
      if ! nix flake show "$FLAKE_DIR" --json | jq -e ".homeConfigurations.\"$CONF_NAME\"" > /dev/null; then
        SYSTEM=$(nix eval --raw --impure --expr builtins.currentSystem)
        CONF_NAME="${username}@$SYSTEM"
      fi
      
      CURRENT_GEN=$(readlink -f ~/.local/state/nix/profiles/home-manager)
      nh home switch --diff always "$FLAKE_DIR" -H "$CONF_NAME" "$@"
      nvd diff "$CURRENT_GEN" ~/.local/state/nix/profiles/home-manager
    fi
  '';
}
