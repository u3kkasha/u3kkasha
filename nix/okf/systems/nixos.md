---
type: Host Configuration
title: Bare-Metal NixOS Host
description: Host-specific configuration for the `nixos` NixOS target.
resource: ../../systems/x86_64-linux/nixos/default.nix
tags: [nixos, host, desktop]
timestamp: 2026-06-18T00:00:00+06:00
---

# Bare-Metal NixOS Host

The `nixos` host imports its hardware configuration, enables systemd-boot with EFI variable access, disables GRUB, and sets `networking.hostName` to `nixos`.

Through the project namespace, it enables the shared system layer, desktop layer, Podman, and Docker. In `flake.nix`, this host also imports the shared core module and adds the Noctalia Home Manager configuration for the configured user.

This host uses the shared [/modules/nixos](/modules/nixos.md) and [/modules/home-manager](/modules/home-manager.md) layers through the flake composition.

# Citations

[1] [systems/x86_64-linux/nixos/default.nix](../../systems/x86_64-linux/nixos/default.nix)
[2] [flake.nix](../../flake.nix)
