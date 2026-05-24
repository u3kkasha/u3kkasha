# CONTEXT.md

## Project Overview

This repository contains a modular NixOS and Home Manager configuration specifically tailored for a WSL environment.

## Current State

- **NixOS Configuration**: Located in `configuration.nix` (within host-specific directories), manages system-level settings and modules.
- **Home Manager**: Integrated as a NixOS module, configured via `home-manager.nix`.
- **Shells**: Supports Bash and Nushell with proper integrations for all tools.
- **Environment Management**: Moved from `devenv` to `direnv` with `nix-direnv` for seamless project-specific developer environments.
- **Maintenance**: Maintenance tasks are centralized as native Nix Flake Apps (e.g., `nix run .#apply`). This ensures that tools like `nh` are available hermetically and removes the need for an external task runner like `go-task`.
- **Binary Caching**: Cachix is integrated into CI (GitHub Actions) to speed up build verification. Local builds do not push to the cache to keep the environment lean.

## Key Decisions

- **Global Shell Setup**: Common tools and shell configurations are managed at the user level through Home Manager.
- **Devshell Integration**: Added `devshell` as a flake input and integrated it into the `devShells` output. This provides a rich interactive shell with built-in commands for project maintenance. Support for `direnv` auto-activation via `use flake` ensures seamless environment entry.
- **Transition to Direnv**: `devenv` has been replaced by `direnv` and `nix-direnv` to provide a more lightweight and standard way to activate developer shells.
- **Modularity**: Configuration is split into system-level (`modules/`) and user-level (`modules/home/`) modules for better maintainability.
- **Host-Specific Entry Points**: Introduced a `hosts/` directory to support diverse environments (WSL, NixOS, VM, and standard Linux).
- **Nushell Functions**: Multi-step maintenance commands in Nushell are defined as `def` functions instead of aliases to prevent accidental execution during shell initialization.
- **WSL Path Isolation**: Windows paths are explicitly excluded from the Linux `PATH` to ensure environment isolation and prevent Windows binaries from shadowing Nix-installed tools.
- **CI-only Cachix**: Cachix is only configured for the GitHub Actions pipeline to optimize CI minutes without adding local system overhead.
