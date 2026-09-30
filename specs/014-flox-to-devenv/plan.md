# Implementation Plan: Replace Flox with devenv

**Feature Directory**: `014-flox-to-devenv` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/014-flox-to-devenv/spec.md`

## Summary

Install `pkgs.devenv` in the shared Home Manager CLI module. The Flox commits have
already been removed from the local branch; no Flox flake input or cache configuration
remains in the resulting source. Update the profile tool list and current-system memory.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: `nixos`, `nixos-wsl`

**Affected layers**: shared Home Manager, treefmt policy, profile README, current-system memory

**Inputs/packages/options**: `pkgs.devenv` from the existing locked nixpkgs input; gated by
the existing `internal.cli.enable`

**State or migration impact**: None

**Security impact**: No new privileges, credentials, trusted keys, or substituters.
Flox-specific cache trust was removed with the three local Flox commits.

**Rollback**: Revert the focused implementation commit and activate the prior NixOS/Home
Manager generation.

**Constraints**: Keep the repository `devShells.default` based on devshell. Do not add a
second devenv flake input or a devenv-specific cache. Exclude Serena-owned files from
formatting.

## Constitution Check

| Principle                           | Evidence of compliance                                                      | Status |
| ----------------------------------- | --------------------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | `pkgs.devenv` is selected by the existing locked nixpkgs flake input.       | PASS   |
| Shared modules and host boundaries  | Package is added to a host-neutral Home Manager module used by both hosts.  | PASS   |
| State compatibility                 | No persistent format or state-version changes.                              | PASS   |
| Explicit security boundaries        | No new trust or privilege boundary is introduced.                           | PASS   |
| Verification follows impact         | Format and evaluate both host package lists.                                | PASS   |
| Current-system memory               | Update the Home Manager tooling description with devenv.                    | PASS   |
| Smallest coherent design            | Use nixpkgs package; do not add a new flake input or environment framework. | PASS   |

## Current and Target Design

### Current

After dropping the local-only Flox commits, the shared CLI module has no developer
environment manager. The profile README still lists Flox. Both host configurations consume
the same Home Manager module tree.

### Target

The shared CLI module adds `pkgs.devenv` under the existing CLI enable condition. Both
hosts receive the package. The profile README and current-system memory describe devenv.
The existing repository flake dev shell remains unchanged. Treefmt excludes `.serena/**`
to leave Serena-owned configuration untouched.

### Decision Rationale

Use the package already supplied by the pinned nixpkgs input. This avoids a redundant
flake input and extra cache trust while keeping Home Manager as the owner of user tools.

## Repository Touchpoints

```text
modules/home/cli.nix
README.md
.specify/memory/current-system.md
specs/014-flox-to-devenv/spec.md
specs/014-flox-to-devenv/plan.md
specs/014-flox-to-devenv/tasks.md
```

## Verification Matrix

| Requirement/story | Target                             | Verification command or observation                                                                                                                   | Local/CI |
| ----------------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| FR-001 / US1      | shared Home Manager on `nixos`     | `nix eval --json .#nixosConfigurations.nixos.config.home-manager.users.ukasha.home.packages --apply 'builtins.map (p: p.name)'` includes `devenv`     | Local    |
| FR-001 / US1      | shared Home Manager on `nixos-wsl` | `nix eval --json .#nixosConfigurations.nixos-wsl.config.home-manager.users.ukasha.home.packages --apply 'builtins.map (p: p.name)'` includes `devenv` | Local    |
| FR-004            | flake dev shell                    | Confirm `devShells.default` remains the existing devshell definition                                                                                  | Local    |
| Invariants        | flake, module, and formatter       | Repository formatting check plus both host configuration evaluations                                                                                  | Local    |

## Delivery and Recovery

1. Add `pkgs.devenv` to the shared CLI module, exclude `.serena/**` from formatting, and update the profile tool list.
2. Evaluate both host configurations and run the repository formatting check.
3. Revert the implementation commit and return to the prior system generation to roll back.

## Current-System Reconciliation

Update the Home Manager and Agent Tooling description to list devenv as a shared CLI tool,
and document the Serena exclusion in the Local Developer Workflow row.

## Complexity Tracking

No additional abstraction or flake input is introduced.
