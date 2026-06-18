---
type: Nix Module Layer
title: Shared NixOS Modules
description: System-level module layer imported through the flake's shared core NixOS module.
resource: ../../modules/nixos/default.nix
tags: [nixos, modules]
timestamp: 2026-06-18T00:00:00+06:00
---

# Shared NixOS Modules

`modules/nixos/default.nix` imports all system-level modules discovered by [/architecture/module-auto-discovery](/architecture/module-auto-discovery.md).

The repository currently includes shared NixOS module areas for system configuration, desktop configuration, WSL support, Podman, and Docker. These modules are pulled into `nixosModules.core` in [/architecture/flake-entry-point](/architecture/flake-entry-point.md), then reused by both host configurations in [/systems](/systems/).

# Citations

[1] [modules/nixos/default.nix](../../modules/nixos/default.nix)
[2] [flake.nix](../../flake.nix)
[3] [README.md](../../README.md)
