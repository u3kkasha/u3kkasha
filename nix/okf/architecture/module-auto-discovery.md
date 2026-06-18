---
type: Repository Architecture
title: Module Auto-Discovery
description: Shared scanPaths helper imports module files and default.nix-backed directories automatically.
resource: ../../lib/internal/default.nix
tags: [nix, modules, auto-discovery]
timestamp: 2026-06-18T00:00:00+06:00
---

# Module Auto-Discovery

The repository uses `lib.internal.scanPaths` to discover module imports. The helper returns all `.nix` files in a directory except `default.nix`, plus directories that contain a `default.nix`.

This discovery pattern is used by the shared NixOS module layer and the Home Manager module layer:

- [/modules/nixos](../modules/nixos.md) imports `lib.internal.scanPaths ./.`.
- [/modules/home-manager](../modules/home-manager.md) imports `scanPaths ./.`.

Adding a module file or a `default.nix`-backed module directory under those locations automatically includes it in the relevant layer.

# Examples

```nix
imports = lib.internal.scanPaths ./.;
```

```nix
imports = scanPaths ./.;
```

# Citations

[1] [lib/internal/default.nix](../../lib/internal/default.nix)
[2] [modules/nixos/default.nix](../../modules/nixos/default.nix)
[3] [modules/home/default.nix](../../modules/home/default.nix)
[4] [AGENTS.md](../../AGENTS.md)
