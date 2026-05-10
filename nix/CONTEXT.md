# CONTEXT.md

## Project Overview

This repository contains a modular NixOS and Home Manager configuration specifically tailored for a WSL environment.

## Current State

- **NixOS Configuration**: Located in `nix/configuration.nix`, manages system-level settings and modules.
- **Home Manager**: Integrated as a NixOS module, configured via `nix/home-manager.nix`.
- **Direnv Support**: Enabled globally via `nix/modules/home/direnv.nix` with `nix-direnv` for optimized performance and GC protection.
- **Shells**: Supports Bash and Nushell with proper integrations for all tools.
- **Maintenance**: A `cleanup` command is provided for garbage collection. It is implemented as a Bash alias and a Nushell function to ensure it doesn't run automatically on shell launch.

## Key Decisions

- **Global Direnv**: `direnv` is managed at the user level through Home Manager rather than per-project `devShells` to ensure consistent availability across the system.
- **Modularity**: Configuration is split into system-level (`nix/modules/`) and user-level (`nix/modules/home/`) modules for better maintainability.
- **Nushell Functions**: Multi-step maintenance commands in Nushell are defined as `def` functions instead of aliases to prevent accidental execution during shell initialization.
