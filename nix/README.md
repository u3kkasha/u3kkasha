# Nix Configuration

This directory contains the modular NixOS and Home Manager configurations for the `u3kkasha` dotfiles.

[![Verification](https://github.com/u3kkasha/u3kkasha/actions/workflows/verify.yml/badge.svg)](https://github.com/u3kkasha/u3kkasha/actions/workflows/verify.yml)
[![Update Flake](https://github.com/u3kkasha/u3kkasha/actions/workflows/update-flake.yml/badge.svg)](https://github.com/u3kkasha/u3kkasha/actions/workflows/update-flake.yml)

## Architecture

The configuration is modularized into logical units for both system-level and user-level settings:

- **`hosts/`**: Host-specific entry points.
  - `wsl/`: NixOS configuration optimized for WSL.
  - `nixos/`: Bare-metal NixOS configuration.
  - `vm/`: Virtual machine configuration.
  - `linux/`: Standalone Home Manager for standard Linux distributions (e.g., Kali).
- **`modules/`**: Shared system-level NixOS modules (system, podman, etc.).
- **`modules/home/`**: Shared user-level Home Manager modules (shells, git, helix, zellij, etc.).
- **`pkgs/`**: Custom package definitions (e.g., `aspire-cli`).

## Maintenance Workflows

This project uses **Nix Flake Apps** to centralize maintenance tasks, ensuring they are hermetic and don't require external task runners.

| Command           | Description                                                                            |
| ----------------- | -------------------------------------------------------------------------------------- |
| `nix run .#apply` | **Apply**: Formats code, detects the host, and rebuilds the system/home configuration. |
| `nix run .#clean` | **Clean**: Performs garbage collection and removes old Nix generations.                |
| `nix fmt`         | **Format**: Formats the entire repository using `treefmt`.                             |
| `nix flake check` | **Check**: Verifies formatting and flake integrity.                                    |

## CI & Binary Caching

- **GitHub Actions**: Automated verification and flake updates.
- **Cachix**: Binary caching via the `u3kkasha` cache to speed up builds and CI verification.

## Setup & Application

To apply the configuration manually (e.g., for initial setup):

### WSL

```bash
sudo nixos-rebuild switch --flake .#nixos-wsl
```

### Bare-metal NixOS

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Standalone Linux

```bash
home-manager switch --flake .#ukasha@linux
```

Once installed, use the flake app for daily updates:

```bash
nix run .#apply
```
