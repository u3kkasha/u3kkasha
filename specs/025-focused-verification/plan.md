# Implementation Plan: Focused Verification

**Feature Directory**: `025-focused-verification` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/025-focused-verification/spec.md`

## Summary

Trim configuration assertions that only echo directly declared settings, retain checks
for security and reproducibility policies, and remove the evaluator-level nixd JSON
inspection that triggers the store-path context error. Keep the nixd module and its
reference-bearing generated output unchanged; host builds remain the validation path for
that generated configuration.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: Both hosts are evaluated by the affected check; no host definitions change.

**Affected layers**: Flake checks, configuration assertions, current-system verification notes.

**Inputs/packages/options**: Existing Nixpkgs `lib.runTests`, NixOS/Home Manager
configuration outputs, and the nixd module's generated JSON.

**State or migration impact**: None.

**Security impact**: None; retain checks for exact unfree allowance, trusted users, caches,
and local MCP store commands.

**Rollback**: Revert the focused test and documentation changes; no state migration is involved.

**Constraints**: Do not change host behavior. Do not force generated nixd JSON into a Nix
evaluation assertion. Keep exact module-discovery tests required by Constitution II.

## Constitution Check

| Principle                           | Evidence of compliance                                                                          | Status |
| ----------------------------------- | ----------------------------------------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | No configuration ownership changes; nixd module remains the owner of its generated output.      | PASS   |
| Shared modules and host boundaries  | Both hosts retain current composition; VM tests remain host-specific.                           | PASS   |
| State compatibility                 | No state-version or migration changes.                                                          | PASS   |
| Explicit security boundaries        | Keep the exact unfree, trusted-user, cache, and MCP command policy checks.                      | PASS   |
| Verification follows impact         | Keep policy assertions and Docker runtime checks; remove weak direct-value assertions.          | PASS   |
| Current-system memory               | Update verification claims after the implemented check set is reviewed.                         | PASS   |
| Smallest coherent design            | Remove brittle assertion rather than introduce another abstraction or serialization workaround. | PASS   |

## Current and Target Design

### Current

`tests/configuration.nix` evaluates both host configurations, includes a broad set of
assertions, reads generated nixd JSON into the Nix evaluator, and uses a derivation for the
Codex merge behavior. `flake.nix` exposes this same derivation as both a package and a
flake check. CI runs `nix flake check .`, which evaluates the check and encounters the
nixd store-path context error.

### Target

Retain assertions that guard explicit policy and generated behavior. Remove tautological
option equality, basic package-presence, fixed host-name, trivial enabled-state, and weak
string-contains checks. Remove nixd JSON parsing from `tests/configuration.nix`; keep
`modules/home/nixd.nix` unchanged and rely on supported host configuration builds for
generated nixd output. Keep Codex merge behavior validation and both Docker VM checks.

### Decision Rationale

The nixd test asserts the serialization layout of a generated implementation detail and
forces store paths into evaluator-level values. The generated config is already owned by
the nixd Home Manager module and included in system outputs. A source-string assertion
adds coupling without proving nixd works; preserving the module and using host builds as
the output validation path is the smaller, more reliable design.

## Repository Touchpoints

```text
tests/configuration.nix                 Remove low-signal and nixd serialization assertions.
tests/unit.nix                          Keep explicit policy and module discovery checks.
tests/vm-nixos.nix                       Keep Docker and Compose checks under the configured user; remove redundant smoke assertions.
tests/vm-wsl-mock.nix                    Keep Docker and Compose checks under the configured user; remove redundant smoke assertions.
.specify/memory/current-system.md        Update verification description.
specs/025-focused-verification/*         Record intent, design, tasks, and validation guide.
```

## Verification Matrix

| Requirement/story          | Target              | Verification command or observation                             | Local/CI            |
| -------------------------- | ------------------- | --------------------------------------------------------------- | ------------------- |
| FR-001 / INV-001 / INV-002 | Shared checks       | `nix build .#unit-tests .#configuration-tests --no-link`        | CI / targeted local |
| FR-002 / SC-001            | Configuration check | `nix flake check .` completes without the nixd store-path error | CI                  |
| FR-003                     | Both hosts          | `nix build .#nixos-build .#nixos-wsl-build --no-link`           | CI                  |
| FR-005 / SC-003            | Runtime             | `nix build .#vm-test-nixos .#vm-test-wsl-mock`                  | CI                  |
| Formatting                 | Repository          | `nix fmt -- --check` or the configured formatting check         | Local / CI          |

## Delivery and Recovery

1. Remove the weak and nixd serialization assertions while retaining policy, generated
   Codex behavior, and runtime Docker coverage.
2. Update the verification description in current-system memory and mark the memory-sync
   task complete after inspecting the final source.
3. Roll back by reverting this change; host configuration and persistent state are untouched.

## Current-System Reconciliation

Update the verification ladder description so it identifies configuration checks as
policy/generated-behavior assertions, not broad tests of every option or nixd JSON string
layout. Keep the host build and VM verification claims.

## Complexity Tracking

No additional complexity introduced.
