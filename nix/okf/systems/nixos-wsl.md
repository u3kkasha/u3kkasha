---
type: Host Configuration
title: WSL NixOS Host
description: Host-specific configuration for the `nixos-wsl` target with WSL and GUI-disabled Home Manager settings.
resource: ../../systems/x86_64-linux/nixos-wsl/default.nix
tags: [nixos, wsl, host]
timestamp: 2026-06-18T00:00:00+06:00
---

# WSL NixOS Host

The `nixos-wsl` host enables the shared system layer, Podman, Docker, and the repository's WSL module. It sets `networking.hostName` to `nixos-wsl` and `nixpkgs.hostPlatform` to `x86_64-linux`.

For Home Manager, this host disables GUI configuration and enables WSL-specific user configuration for the configured username from [/architecture/internal-library](/architecture/internal-library.md).

This host is the WSL-oriented entry point described in the repository context.

# Citations

[1] [systems/x86_64-linux/nixos-wsl/default.nix](../../systems/x86_64-linux/nixos-wsl/default.nix)
[2] [CONTEXT.md](../../CONTEXT.md)
