# CONTEXT.md

## Project Overview

This repository contains a modular NixOS and Home Manager configuration specifically tailored for a WSL environment.

## Current State

- **NixOS Configuration**: Located in `configuration.nix` (within host-specific directories), manages system-level settings and modules.
- **Home Manager**: Integrated as a NixOS module, configured via `home-manager.nix`.
- **Shells**: Supports Bash and Nushell with proper integrations for all tools.
- **Environment Management**: Moved from `direnv` to `devenv` for project-specific developer environments.
- **Maintenance**: Task management is centralized via `go-task` (`Taskfile.yml`). A `task clean` command is provided for garbage collection, consolidating previous Bash aliases and Nushell functions into a single, shell-agnostic interface.
- **Binary Caching**: Cachix is integrated into CI (GitHub Actions) to speed up build verification. Local builds do not push to the cache to keep the environment lean.

## Key Decisions

- **Global Shell Setup**: Common tools and shell configurations are managed at the user level through Home Manager.
- **Transition to Devenv**: `direnv` has been removed in favor of `devenv` to provide more robust and reproducible developer shells.
- **Modularity**: Configuration is split into system-level (`modules/`) and user-level (`modules/home/`) modules for better maintainability.
- **Host-Specific Entry Points**: Introduced a `hosts/` directory to support diverse environments (WSL, NixOS, VM, and standard Linux).
- **Nushell Functions**: Multi-step maintenance commands in Nushell are defined as `def` functions instead of aliases to prevent accidental execution during shell initialization.
- **WSL Path Isolation**: Windows paths are explicitly excluded from the Linux `PATH` to ensure environment isolation and prevent Windows binaries from shadowing Nix-installed tools.
- **CI-only Cachix**: Cachix is only configured for the GitHub Actions pipeline to optimize CI minutes without adding local system overhead.
