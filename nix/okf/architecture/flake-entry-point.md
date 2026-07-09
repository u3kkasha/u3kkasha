---
type: Repository Architecture
title: Flake Entry Point
description: Flake-parts based entry point that defines inputs, NixOS configurations, dev shell, packages, and checks.
resource: ../../flake.nix
tags: [nix, flakes, flake-parts, architecture]
timestamp: 2026-06-18T00:00:00+06:00
---

# Flake Entry Point

`flake.nix` is the repository entry point. It uses `flake-parts` to define the `x86_64-linux` system, shared arguments, NixOS module composition, development shell, package outputs, formatter, and checks.

The flake exposes two NixOS configurations:

- `nixos`, which imports [/systems/nixos](/systems/nixos.md) and enables the shared graphical Home Manager configuration.
- `nixos-wsl`, which imports [/systems/nixos-wsl](/systems/nixos-wsl.md) and configures the WSL-oriented host.

Shared NixOS modules are grouped into `nixosModules.core`, which includes the repository's [/modules/nixos](/modules/nixos.md) layer along with upstream NixOS-WSL, Home Manager, and nix-index modules.

Shared Home Manager modules include the `mcp-servers-nix` bridge. Agent packages are read from the independently pinned `llm-agents.nix` input, whose public Numtide binary cache is configured in `nixConfig`.

The per-system outputs define the repository formatter, dev shell, build packages, VM test packages, and checks described in [/workflows/verification](/workflows/verification.md).

# Citations

[1] [flake.nix](../../flake.nix)
[2] [CONTEXT.md](../../CONTEXT.md)
