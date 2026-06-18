---
type: Repository Architecture
title: Internal Library
description: Central project constants and helper functions used across system and Home Manager configuration.
resource: ../../lib/internal/default.nix
tags: [nix, library, constants]
timestamp: 2026-06-18T00:00:00+06:00
---

# Internal Library

`lib/internal/default.nix` defines shared repository constants and helpers. The flake imports this file, extends `nixpkgs.lib` with `internal`, and passes the extended library through `specialArgs`.

The internal library currently defines the configured username, display name, email, default editor, default terminal, theme flavor, system state version, Home Manager state version, and the `scanPaths` helper used by [/architecture/module-auto-discovery](/architecture/module-auto-discovery.md).

The state version values are part of [/policies/state-version](/policies/state-version.md) and should not be treated as ordinary rolling version numbers.

# Citations

[1] [lib/internal/default.nix](../../lib/internal/default.nix)
[2] [flake.nix](../../flake.nix)
[3] [AGENTS.md](../../AGENTS.md)
