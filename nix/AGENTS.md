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
- `nix/AGENTS.md`: This file.
- `nix/CONTEXT.md`: Project context and key decisions.

## Workflow Commands

### Applying Changes

To apply the configuration, run:

```bash
sudo nixos-rebuild switch --flake ./nix#nixos
```
Or use the `rebuild` alias in the shell.

### Formatting and Linting

To format the entire repository:

```bash
nix fmt
```

To check for formatting and linting issues:

```bash
nix flake check
```

## Code Style

- Use Nix flakes for dependency management.
- Modularize configuration into logical units under `nix/modules`.
- Use `home-manager` for user-level configuration.
- Follow the existing commit message style: `type(scope): description`.
- **Nushell Multi-command logic**: Prefer `def` functions over `alias` for multi-step commands to avoid immediate execution on shell startup.
