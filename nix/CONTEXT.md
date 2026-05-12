# CONTEXT.md

## Project Overview

This repository contains a modular NixOS and Home Manager configuration specifically tailored for a WSL environment.

## Current State

- **NixOS Configuration**: Located in `nix/configuration.nix`, manages system-level settings and modules.
- **Home Manager**: Integrated as a NixOS module, configured via `nix/home-manager.nix`.
- **Direnv Support**: Enabled globally via `nix/modules/home/direnv.nix` with `nix-direnv` for optimized performance and GC protection.
- **Shells**: Supports Bash and Nushell with proper integrations for all tools.
- **Maintenance**: Task management is centralized via `go-task` (`Taskfile.yml`). A `task clean` command is provided for garbage collection, consolidating previous Bash aliases and Nushell functions into a single, shell-agnostic interface.
- **Binary Caching**: Cachix is integrated to speed up builds. The `u3kkasha` cache is used both locally and in CI.

## Key Decisions

- **Global Direnv**: `direnv` is managed at the user level through Home Manager rather than per-project `devShells` to ensure consistent availability across the system.
- **Modularity**: Configuration is split into system-level (`nix/modules/`) and user-level (`nix/modules/home/`) modules for better maintainability.
- **Nushell Functions**: Multi-step maintenance commands in Nushell are defined as `def` functions instead of aliases to prevent accidental execution during shell initialization.
- **WSL Path Isolation**: Windows paths are explicitly excluded from the Linux `PATH` to ensure environment isolation and prevent Windows binaries from shadowing Nix-installed tools.
- **Cachix Trusted Users**: The system user is added to `nix.settings.trusted-users` to allow managing Cachix caches without `sudo`.
