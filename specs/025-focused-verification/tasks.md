---
description: "Nix configuration implementation tasks"
---

# Tasks: Focused Verification

**Input**: `spec.md`, `plan.md`, `research.md`, and `quickstart.md` from
`specs/025-focused-verification/`

## Phase 1: Verification cleanup

**Purpose**: Keep assertions that protect policies or observable generated behavior and
remove checks that only echo directly assigned values.

- [x] T001 [US1] Remove evaluator-level nixd JSON reads and `testNixdConfigUsesLockedInputPaths` from `tests/configuration.nix` while leaving `modules/home/nixd.nix` intact.
- [x] T002 [US2] Remove low-signal direct-value, package-presence, and weak string-layout assertions from `tests/configuration.nix` while retaining documented policy and generated Codex merge checks.
- [x] T003 [US2] Confirm the module-discovery and exact unfree-policy assertions remain in `tests/unit.nix` and leave them unchanged.
- [x] T004 [US2] Simplify both VM tests to check Docker and Compose as the configured user, removing redundant command-presence and status assertions from `tests/vm-nixos.nix` and `tests/vm-wsl-mock.nix`.

## Phase 2: Verification documentation

- [x] T005 [US1] Record the final review and any unrun verification commands in `specs/025-focused-verification/quickstart.md`.
- [x] T006 Reconcile `.specify/memory/current-system.md` through `speckit.system-memory.sync` and mark this task complete.
- [x] T007 Run `.specify/scripts/bash/validate-project.sh` and resolve any artifact-format issues.

## Completion Rules

- No host configuration or nixd module behavior changes.
- Retained checks map to a documented invariant, security/reproducibility policy, generated
  behavior, or runtime behavior.
- Every completed task is marked `[X]`; unavailable CI-only validation is documented.
