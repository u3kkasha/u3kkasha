# NixOS Dotfiles

## Architecture

This project uses a modular NixOS configuration based on Flakes and Home Manager.

### Structure

- `nix/flake.nix`: Entry point for the Nix configuration.
- `nix/configuration.nix`: Main system configuration entry point.
- `nix/home-manager.nix`: Main Home Manager configuration entry point.
- `nix/modules/`: System-level modules (WSL, System, Home Manager integration).
- `nix/modules/home/`: User-level Home Manager modules (Helix, Zellij, Git).

## Workflows

### Applying Changes

To apply the configuration, run:
```bash
sudo nixos-rebuild switch --flake .#nixos
```
