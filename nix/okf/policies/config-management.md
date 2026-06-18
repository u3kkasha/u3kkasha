---
type: Policy
title: Configuration Management Policy
description: Home Manager-managed runtime configuration files should be changed through Nix modules.
tags: [policy, home-manager, configuration]
timestamp: 2026-06-18T00:00:00+06:00
---

# Configuration Management Policy

Most runtime configuration files under `.config` are managed by Home Manager and symlinked to the Nix store. They should be treated as read-only outputs.

When a tool's configuration needs to change, edit the corresponding Nix module under `modules/home/` and apply the change with [/workflows/maintenance](/workflows/maintenance.md). Do not modify generated runtime config files directly or allow applications to auto-migrate them in place.

# Citations

[1] [AGENTS.md](../../AGENTS.md)
[2] [README.md](../../README.md)
