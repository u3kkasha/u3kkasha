# AGENTS.md

This repository contains NixOS and Home Manager configuration files.

## Architecture

This project uses a modular NixOS configuration based on Flakes and Home Manager.

### Structure

- `nix/flake.nix`: Entry point for the Nix configuration.
- `nix/configuration.nix`: Main system configuration entry point.
- `nix/home-manager.nix`: Main Home Manager configuration entry point.
- `nix/modules/`: System-level modules (WSL, System, Home Manager integration).
- `nix/modules/home/`: User-level Home Manager modules (Helix, Zellij, Git).
- `nix/pkgs/`: Custom package definitions (e.g., `aspire-cli`).
- `nix/AGENTS.md`: This file.
- `nix/CONTEXT.md`: Project context and key decisions.

## Binary Caching

- **Cachix**: Used for binary caching to speed up CI builds. The cache is named `u3kkasha`. CI builds push to this cache automatically. Local configuration is avoided to keep the system lean.

## Configuration Management

- **Read-Only Files**: Most configuration files in `.config` (e.g., `lazygit/config.yml`) are managed by Home Manager and are symlinked to the Nix store. These files are **read-only**.
- **Modifying Config**: Do not attempt to modify these files directly or allow applications to "auto-migrate" them. All changes must be made in the corresponding Nix module (e.g., `nix/modules/home/git.nix`) and applied via `rebuild`.

## Workflow Commands

This project uses `go-task` (Taskfile) to manage maintenance tasks.

### Core Tasks

- `task fmt`: Format the entire repository.
- `task check`: Check for formatting and linting issues.
- `task apply`: Apply the configuration (rebuild).
- `task clean`: Perform garbage collection and cleanup.

### Legacy Commands (Manual)

To apply the configuration manually:

```bash
sudo nixos-rebuild switch --flake ./nix#nixos
```

Or use the `rebuild` alias in the shell.

## Code Style

- Use Nix flakes for dependency management.
- Modularize configuration into logical units under `nix/modules`.
- Use `home-manager` for user-level configuration.
- Follow the existing commit message style: `type(scope): description`.
- **Nushell Multi-command logic**: Prefer `def` functions over `alias` for multi-step commands to avoid immediate execution on shell startup.
