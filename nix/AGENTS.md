# AGENTS.md

This repository contains NixOS and Home Manager configuration files.

## Architecture

This project uses a modular NixOS configuration based on Flakes and Home Manager.

### Structure

- `flake.nix`: Entry point for the Nix configuration.
- `home-manager.nix`: Shared Home Manager configuration.
- `hosts/`: Host-specific configurations (WSL, NixOS, VM, Linux).
- `modules/`: Shared system-level modules.
- `modules/home/`: Shared user-level Home Manager modules.
- `pkgs/`: Custom package definitions.
- `AGENTS.md`: This file.
- `CONTEXT.md`: Project context and key decisions.

## Binary Caching

- **Cachix**: Used for binary caching to speed up CI builds. The cache is named `u3kkasha`. CI builds push to this cache automatically. Local configuration is avoided to keep the system lean.

## Configuration Management

- **Read-Only Files**: Most configuration files in `.config` (e.g., `lazygit/config.yml`) are managed by Home Manager and are symlinked to the Nix store. These files are **read-only**.
- **Modifying Config**: Do not attempt to modify these files directly or allow applications to "auto-migrate" them. All changes must be made in the corresponding Nix module (e.g., `modules/home/git.nix`) and applied via `nix run .#apply`.

## Workflow Commands

This project uses **Nix Flake Apps** to manage maintenance tasks. This ensures tasks are hermetic and don't require external task runners to be installed globally.

### Core Tasks

- `nix fmt`: Format the entire repository.
- `nix flake check`: Check for formatting and linting issues.
- `nix run .#apply`: Apply the configuration (rebuild).
- `nix run .#clean`: Perform garbage collection and cleanup.
- `nix run .#test-actions`: Test GitHub Actions locally.

### Legacy Commands (Manual)

To apply the configuration manually:

#### WSL

```bash
sudo nixos-rebuild switch --flake .#nixos-wsl
```

#### Bare-metal NixOS

```bash
sudo nixos-rebuild switch --flake .#nixos
```

#### Standalone Linux (e.g. Kali)

```bash
home-manager switch --flake .#ukasha@linux
```

## Code Style

- Use Nix flakes for dependency management.
- Modularize configuration into logical units under `nix/modules`.
- Use `home-manager` for user-level configuration.
- Follow the existing commit message style: `type(scope): description`.
- **Nushell Multi-command logic**: Prefer `def` functions over `alias` for multi-step commands to avoid immediate execution on shell startup.
