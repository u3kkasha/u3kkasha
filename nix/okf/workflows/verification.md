---
type: Workflow
title: Verification Workflow
description: Local and CI verification checks for formatting, unit tests, secret scanning, and VM builds.
resource: ../../flake.nix
tags: [workflow, tests, ci]
timestamp: 2026-06-18T00:00:00+06:00
---

# Verification Workflow

The flake defines checks for pre-push validation, formatting, unit tests, and gitleaks secret scanning. It also exposes build packages for the main NixOS configurations and VM integration tests.

The unit tests validate the username, default editor, email format, both dynamic-import trees, locked nixd expressions, container-runtime exclusivity and group membership, WSL GUI package exclusion, packaged MCP commands, Home Manager's generated Codex MCP section, and the writable Codex merge behavior.

# Examples

```bash
nix build .#unit-tests
nix build .#vm-test-nixos
nix build .#vm-test-wsl-mock
nix flake check
```

The VM integration tests are intended for CI because they are resource-intensive. The pre-push hook runs `nix flake check ./nix` and builds both system configurations using pure evaluation.

Markdown changes trigger CI. CI also validates the OKF bundle and builds important outputs with flake-configured extra caches disabled.

# Citations

[1] [flake.nix](../../flake.nix)
[2] [tests/unit.nix](../../tests/unit.nix)
[3] [AGENTS.md](../../AGENTS.md)
[4] [CONTEXT.md](../../CONTEXT.md)
