{
  lib,
  osConfig ? null,
  inputs ? null,
  ...
}:

let
  enablePersistence = osConfig != null && osConfig.internal.impermanence.enable;
  persistPath = if osConfig != null then osConfig.internal.impermanence.persistPath else "/persist";
in
{
  # Standalone Home Manager: manually import the module and bypass the NixOS-only check
  imports = lib.optional (
    osConfig == null && inputs ? impermanence
  ) inputs.impermanence.nixosModules.home-manager.impermanence;

  config = lib.mkMerge [
    (lib.mkIf (osConfig == null) {
      home._nixosModuleImported = true;
    })

    (lib.mkIf enablePersistence {
      home.persistence."${persistPath}" = {
        directories = [
          # Development and personal files
          "code"
          "Downloads"
          "Documents"
          "Pictures"
          "Music"
          "Videos"

          # Security and credentials
          ".ssh"
          ".gnupg"
          ".doppler"
          ".serena"
          ".local/share/keyrings"

          # Application configurations and tokens
          ".config/gh"
          ".config/opencode"
          ".config/antigravity"
          ".gemini"

          # Application state/data
          ".local/share/zoxide"
          ".local/share/direnv"
          ".local/share/opencode"
          ".local/share/containers" # For podman
          ".local/share/nushell"

          # Flox & devenv
          ".config/flox"
          ".local/share/flox"
          ".local/share/devenv"

          # Language runtime toolchains and package manager caches
          ".cache/nix"
          ".bun"
          ".npm"
          ".cargo"
          ".rustup"
          ".local/share/pnpm"

          # Browsers
          ".mozilla"
          ".config/google-chrome"
          ".config/chromium"
          ".config/BraveSoftware"
        ];
        files = [
          ".bash_history"
          ".config/nushell/history.txt"
          ".config/nushell/history.sqlite3"
        ];
      };
    })
  ];
}
