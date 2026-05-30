# Suggested Commands

## System & Home Maintenance

- `nh os switch .`: Rebuild and switch to the NixOS system configuration.
- `nh home switch .`: Rebuild and switch to the Home Manager configuration.
- `nh clean all`: Garbage collection and generation cleanup.
- `nix run .#apply`: (Implicitly used by `nh` commands) Apply configuration.

## Development & Quality

- `nix fmt`: Format all files using `treefmt`.
- `nix flake check`: Run all flake checks (formatting, linting, etc.).
- `nix develop`: Enter the project development shell.

## Shell Utilities

- `hx <file>`: Open file in Helix.
- `nu`: Start Nushell.
- `zj`: Start Zellij.
