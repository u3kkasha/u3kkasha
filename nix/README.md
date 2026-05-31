# Nix Configuration

This directory contains the modular NixOS and Home Manager configurations for the `u3kkasha` dotfiles.

[![Verification](https://github.com/u3kkasha/u3kkasha/actions/workflows/verify.yml/badge.svg)](https://github.com/u3kkasha/u3kkasha/actions/workflows/verify.yml)
[![Update Flake](https://github.com/u3kkasha/u3kkasha/actions/workflows/update-flake.yml/badge.svg)](https://github.com/u3kkasha/u3kkasha/actions/workflows/update-flake.yml)

## Architecture

The configuration is modularized into logical units for both system-level and user-level settings:

- **`systems/`**: Host-specific entry points.
  - `nixos-wsl/`: NixOS configuration optimized for WSL.
  - `nixos/`: Bare-metal NixOS configuration.
- **`modules/`**: Shared system-level NixOS modules (system, podman, etc.).
- **`modules/home/`**: Shared user-level Home Manager modules (shells, git, helix, zellij, etc.).
- **`packages/`**: Custom package definitions.

## Configuration Policy

- **State Version**: This project maintains a stable `stateVersion` (currently `26.05`). This value is **not** updated automatically or monthly, as it serves as a compatibility shim for stateful data. See [AGENTS.md](AGENTS.md) for details.

## Maintenance Workflows

This project uses `nh` (nix-helper) for maintenance tasks. Enter the development shell (`nix develop`) to access these commands.

| Command            | Description                                         |
| ------------------ | --------------------------------------------------- |
| `nh os switch .`   | **Apply**: Rebuilds the system configuration.       |
| `nh home switch .` | **Apply**: Rebuilds the Home Manager configuration. |
| `nh clean all`     | **Clean**: Garbage collects old generations.        |
| `nix fmt`          | **Format**: Formats the repository.                 |
| `nix flake check`  | **Check**: Verifies configuration integrity.        |

See [AGENTS.md](AGENTS.md) for full details on the workflow.

## CI & Binary Caching
