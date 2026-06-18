---
type: Workflow
title: Maintenance Workflow
description: Developer-shell commands used to apply, format, and clean the configuration.
tags: [workflow, nh, maintenance]
timestamp: 2026-06-18T00:00:00+06:00
---

# Maintenance Workflow

The repository uses `nh` for configuration maintenance. Enter the development shell with `nix develop` before using the maintenance commands.

# Examples

```bash
nh os switch .
nh home switch .
nh clean all
nix fmt
nix flake check
```

`nh os switch .` applies the NixOS system configuration, while `nh home switch .` applies Home Manager configuration. Configuration files managed by Home Manager should be changed in the relevant Nix module, not edited directly in symlinked runtime locations; see [/policies/config-management](/policies/config-management.md).

# Citations

[1] [AGENTS.md](../../AGENTS.md)
[2] [README.md](../../README.md)
[3] [CONTEXT.md](../../CONTEXT.md)
