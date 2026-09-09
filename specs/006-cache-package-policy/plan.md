# Implementation Plan: Cache and Package Policy

**Feature Directory**: `006-cache-package-policy` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary

Store cache literals in a small internal data file consumed by `lib.internal` and both host daemon
settings. Remove duplicate flake metadata, and put the exact Steam-family unfree allowlist and
predicate in `lib.internal` for host and VM package imports.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both

**Affected layers**: internal library, flake, shared NixOS, test package imports

**Inputs/packages/options**: `nix.settings.substituters`, `nix.settings.trusted-public-keys`,
`nixpkgs.config.allowUnfreePredicate`, `lib.getName`

**State or migration impact**: N/A

**Security impact**: cache trust values are unchanged; unfree permission narrows to exact Steam names

**Rollback**: restore previous declarations; no persistent state changes

**Constraints**: flake `nixConfig` rejects imported/thunked cache values and is removed to avoid duplication

## Constitution Check

| Principle                           | Evidence of compliance                               | Status |
| ----------------------------------- | ---------------------------------------------------- | ------ |
| Declarative, reproducible ownership | Internal library owns cache and unfree values        | PASS   |
| Shared modules and host boundaries  | Cross-host policy remains shared                     | PASS   |
| State compatibility                 | No state-version change                              | PASS   |
| Explicit security boundaries        | Exact cache trust and unfree names documented/tested | PASS   |
| Verification follows impact         | focused assertions, both builds, VM evaluations      | PASS   |
| Current-system memory               | cache and package policy claims reconciled           | PASS   |
| Smallest coherent design            | Extend existing internal values, no new subsystem    | PASS   |

## Current and Target Design

### Current

`flake.nix` and `modules/nixos/system/default.nix` repeat three cache URLs and keys. Four
package-set declarations broadly set `allowUnfree = true`.

### Target

`lib/internal/cache.nix` is the sole cache literal source and `lib.internal` projects its values
as `cacheSubstituters` and `cachePublicKeys`. It also exports `unfreePackageNames` and a shared
exact-name predicate. Both hosts refer to those values. The allowlist is
`steam`, `steam-original`, and `steam-unwrapped`, derived from supported gaming evaluation.

### Decision Rationale

Flake syntax requires `nixConfig` values to be literals and rejects importing a canonical data
file, so duplicate flake metadata is removed. The installed daemon remains the operational cache
consumer. Exact names permit Steam without authorizing unrelated unfree packages.

## Repository Touchpoints

```text
lib/internal/default.nix
lib/internal/cache.nix
flake.nix
modules/nixos/system/default.nix
tests/unit.nix
tests/configuration.nix
.specify/memory/current-system.md
```

## Verification Matrix

| Requirement/story    | Target          | Verification command or observation          | Local/CI |
| -------------------- | --------------- | -------------------------------------------- | -------- |
| FR-001..FR-002 / US1 | both hosts      | exact equality assertions and literal search | Local    |
| FR-003..FR-004 / US2 | host/VM pkgs    | predicate tests, both builds, VM evaluation  | Local/CI |
| INV-001              | cache consumers | exact-list assertions                        | Local    |
| INV-002..INV-003     | all hosts/tests | host builds, VM eval, state assertions       | Local/CI |

## Delivery and Recovery

1. Add canonical internal values and predicate assertions.
2. Replace duplicated cache lists and broad allowUnfree declarations.
3. Build the focused checks, both hosts, and evaluate VM derivations.
4. Revert the source changes if a required package exposes an additional exact name; add a name only with evaluation evidence.

## Current-System Reconciliation

- Document internal ownership of cache metadata and the exact Steam-family unfree policy.
- Remove cache duplication and broad-unfree limitations.

## Complexity Tracking

No constitution violation or retained complexity.
