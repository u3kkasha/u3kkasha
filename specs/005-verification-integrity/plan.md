# Implementation Plan: Verification Integrity

**Feature Directory**: `005-verification-integrity` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary

Keep `tests/unit.nix` limited to source/internal-library assertions, move evaluated Home Manager,
generated file, runtime merge, closure, and host-option assertions to `tests/configuration.nix`,
remove nixd's unsafe context discard if evaluation succeeds, and interpolate VM usernames from
`specialArgs.lib.internal.username`.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both

**Affected layers**: Home Manager, flake outputs/checks, unit/configuration tests, VM tests

**Inputs/packages/options**: Nix string context, `pkgs.linkFarm`, `pkgs.writeText`, `lib.runTests`

**State or migration impact**: N/A

**Security impact**: N/A

**Rollback**: restore prior test wiring and nixd expression; previous generations are unaffected

**Constraints**: preserve all assertion coverage; configuration test cost must be documented honestly

## Constitution Check

| Principle                           | Evidence of compliance                                     | Status |
| ----------------------------------- | ---------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | Generated nixd files remain Home Manager-owned             | PASS   |
| Shared modules and host boundaries  | No host detail moves into shared modules                   | PASS   |
| State compatibility                 | No state-version change                                    | PASS   |
| Explicit security boundaries        | No security-boundary change                                | PASS   |
| Verification follows impact         | Cheap and closure-sized targets are named separately       | PASS   |
| Current-system memory               | Verification ladder and nixd claims reconciled             | PASS   |
| Smallest coherent design            | One test split, one context removal, two VM interpolations | PASS   |

## Current and Target Design

### Current

`tests/unit.nix` consumes both complete NixOS configurations and generated Home Manager sources,
so its derivation can retain large closures. `modules/home/nixd.nix` discards string context.
Both VM scripts embed the current username literally.

### Target

`unit-tests` covers scan/discovery and context-free internal helpers. `configuration-tests` covers
evaluated host options, generated files, closures, and the Codex merge script and is documented as
medium/heavy. nixd keeps `${lockedInputs}` context. VM scripts derive the username from `specialArgs`.

### Decision Rationale

Splitting by dependency boundary gives a fast feedback target without weakening coverage. Directly
preserving the nixd string context is preferred; only a reproducible evaluation cycle can justify
retaining a workaround.

## Repository Touchpoints

```text
modules/home/nixd.nix
tests/unit.nix
tests/configuration.nix (add)
tests/vm-nixos.nix
tests/vm-wsl-mock.nix
flake.nix
.specify/memory/current-system.md
```

## Verification Matrix

| Requirement/story    | Target          | Verification command or observation                                      | Local/CI |
| -------------------- | --------------- | ------------------------------------------------------------------------ | -------- |
| FR-001 / US1         | unit            | `nix build .#unit-tests --no-link`                                       | Local    |
| FR-002..FR-003 / US1 | generated hosts | `nix build .#configuration-tests --no-link`                              | Local/CI |
| FR-004 / US2         | nixd            | configuration test plus both host builds                                 | Local    |
| FR-005 / US3         | VM definitions  | source assertion, `nix flake check --no-build`, VM derivation evaluation | Local    |
| INV-001              | both hosts      | both host builds                                                         | Local    |

## Delivery and Recovery

1. Split tests without changing expected results and expose both package/check outputs.
2. Remove unsafe nixd context discard and evaluate; if it cycles, capture exact evidence before a minimal fallback.
3. Replace VM literals and evaluate both derivations.
4. Revert the affected source files if evaluation fails; no runtime state changes.

## Current-System Reconciliation

- Document `unit-tests` as quick and `configuration-tests` as generated/closure-sized.
- Remove nixd context and VM username limitations when proven.

## Complexity Tracking

No retained complexity unless evaluation proves a nixd cycle; such evidence must be added before implementation completion.
