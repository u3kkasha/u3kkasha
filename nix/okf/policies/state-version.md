---
type: Policy
title: State Version Policy
description: Compatibility state versions are intentionally stable and should not be updated as routine version bumps.
resource: ../../lib/internal/default.nix
tags: [policy, state-version, nixos, home-manager]
timestamp: 2026-06-18T00:00:00+06:00
---

# State Version Policy

The repository defines `systemStateVersion` and `homeStateVersion` in [/architecture/internal-library](/architecture/internal-library.md). Both are currently set to `26.05`.

These values are compatibility shims for stateful data and service defaults. They should not be updated monthly or treated as the configuration's current release number.

Only update these values during a deliberate major migration after reviewing relevant NixOS and Home Manager release notes and accounting for required manual data migrations.

# Citations

[1] [lib/internal/default.nix](../../lib/internal/default.nix)
[2] [AGENTS.md](../../AGENTS.md)
[3] [README.md](../../README.md)
