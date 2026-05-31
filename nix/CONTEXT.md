# CONTEXT.md

## Project Overview

This repository contains a modular NixOS and Home Manager configuration specifically tailored for a WSL environment, now powered by `flake-parts`.

## Current State

- **NixOS Configuration**: Located in `default.nix` (within host-specific directories in `systems/`), manages system-level settings and modules.
- **Home Manager**: Integrated as a NixOS module, configured via `modules/home/default.nix`.
- **Shells**: Supports Bash and Nushell with proper integrations for all tools.
- **Environment Management**: Powered by `direnv` with `nix-direnv` for seamless project-specific developer environments.
- **Maintenance**: Maintenance tasks are centralized using `nh` (nix-helper), providing standardized commands for rebuilding the system/home configuration and performing garbage collection. This removes the need for custom wrapper scripts.
- **Binary Caching**: Cachix (`u3kkasha`) is integrated into CI (GitHub Actions) to speed up build verification.

## Key Decisions

- **Global Shell Setup**: Common tools and shell configurations are managed at the user level through Home Manager.
- **Devshell Integration**: Added `devshell` as a flake input and integrated it into the `devShells` output. This provides a rich interactive shell with built-in commands for project maintenance. Support for `direnv` auto-activation via `use flake` ensures seamless environment entry.
- **Transition to Direnv**: `devenv` has been replaced by `direnv` and `nix-direnv` to provide a more lightweight and standard way to activate developer shells.
- **Modularity (Dendritic Pattern)**: Configuration uses a custom `scanPaths` helper to automatically discover and import modules within `modules/` and `modules/home/`. This allows for a "dendritic" structure where adding a file to a directory automatically includes it in the configuration.
- **Host-Specific Entry Points**: Located in the `systems/` directory to support diverse environments (WSL, NixOS).
- **Nushell Functions**: Multi-step maintenance commands in Nushell are defined as `def` functions instead of aliases to prevent accidental execution during shell initialization.
- **WSL Path Isolation**: Windows paths are explicitly excluded from the Linux `PATH` to ensure environment isolation and prevent Windows binaries from shadowing Nix-installed tools.
- **CI-only Cachix**: Cachix is only configured for the GitHub Actions pipeline to optimize CI minutes without adding local system overhead.
