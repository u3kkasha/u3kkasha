# Architecture

Key files and directories:

- `flake.nix`: flake entry point structured with `flake-parts`.
- `systems/`: host-specific configurations for WSL and NixOS.
- `modules/`: shared system-level NixOS modules.
- `modules/home/`: shared Home Manager modules.
- `packages/`: custom package definitions.
- `lib/internal/`: core helper logic and variables, including username, email, state versions, and `scanPaths`.
- `okf/`: Open Knowledge Format bundle for agent-readable repo documentation.

Modules are imported hierarchically. `lib.internal.scanPaths` auto-discovers `.nix` files except `default.nix`, plus directories containing a `default.nix`; this is used by `modules/nixos/default.nix` and `modules/home/default.nix`.
