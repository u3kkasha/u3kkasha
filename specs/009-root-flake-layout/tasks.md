---
description: "Root flake layout implementation tasks"
---

# Tasks: Root Flake Layout

**Input**: `spec.md` and `plan.md` from `specs/009-root-flake-layout/`

**Organization**: Tasks are grouped by independently verifiable configuration outcome.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Safe to execute concurrently because files and dependencies do not overlap.
- **[US#]**: Traceability to the specification's configuration outcome.
- Every task names exact repository paths or verification commands.

## Phase 1: Guardrails and Baseline

**Purpose**: Establish the source-boundary failure and protect root public metadata.

- [x] T001 Record the passing Git-aware Actionlint baseline and failing pure `path:./nix#checks.x86_64-linux.actionlint` result in `specs/009-root-flake-layout/research.md`
- [x] T002 Confirm `README.md`, `LICENSE`, `.github/`, `.gitignore`, and all tracked `nix/` source paths before relocation with `git ls-files` and `git status --short`

**Checkpoint**: The Actionlint boundary defect is reproduced and the preservation set is known.

## Phase 2: Foundational Relocation

**Purpose**: Establish the root source tree that every user story depends on.

- [x] T003 Relocate all tracked source from `nix/` into the repository root while preserving `README.md`, `LICENSE`, and `.github/`
- [x] T004 Merge patterns from `nix/.gitignore` into root `.gitignore` and ensure generated `.direnv/`, `result*`, tool caches, and generated hook files remain ignored
- [x] T005 Review `git status --short --ignored` to confirm tracked moves are complete and ignored runtime artifacts were not promoted

**Checkpoint**: The root owns the complete declarative project and no tracked nested source remains.

## Phase 3: User Story 1 - Use the repository root as the flake (Priority: P1)

**Goal**: All supported developer and CI entrypoints use a pure root flake, including Actionlint.

**Independent Test**: Build the Actionlint check using both `.` and `path:.` without `--impure`.

- [x] T006 [US1] Change the Actionlint workflow source and root-level hook commands in `flake.nix`
- [x] T007 [P] [US1] Remove nested-flake paths from `.github/workflows/verify.yml`
- [x] T008 [P] [US1] Remove `path-to-flake-dir: nix` from `.github/workflows/update-flake.yml`
- [x] T009 [US1] Validate workflow syntax with `actionlint .github/workflows/*.yml`
- [x] T010 [US1] Build `.#checks.x86_64-linux.actionlint` and `path:.#checks.x86_64-linux.actionlint` without `--impure`
- [x] T011 [US1] Evaluate all root flake outputs with `nix flake check --no-build`

**Checkpoint**: User Story 1 is independently satisfied in Git-aware and explicit path modes.

## Phase 4: User Story 2 - Preserve profile and system behavior (Priority: P2)

**Goal**: Keep the public profile presentation and existing supported configurations intact.

**Independent Test**: Root public files have no content changes and both supported host outputs build.

- [x] T012 [P] [US2] Update root `AGENTS.md` and active project instructions for the relocated constitution and current-system paths
- [x] T013 [P] [US2] Update active developer and verification paths in `docs/`, `.specify/`, and `specs/009-root-flake-layout/` without rewriting completed specs `001` through `008`
- [x] T014 [US2] Confirm `README.md` and `LICENSE` remain tracked with no content diff
- [x] T015 [US2] Build `.#unit-tests` and `.#configuration-tests` from the root flake
- [x] T016 [US2] Build `.#nixos-build` and `.#nixos-wsl-build` from the root flake

**Checkpoint**: User Story 2 is satisfied and both supported targets retain their behavior.

## Final Phase: Cross-Target Verification and Memory

- [x] T017 Run `nix fmt` and `nix flake check --no-build` from the repository root
- [x] T018 Search active source, workflows, instructions, and canonical memory for stale `./nix`, `dir=nix`, or `path-to-flake-dir` references
- [x] T019 Confirm security, state, rollback, cache, trust, unfree-policy, and host-boundary invariants from `specs/009-root-flake-layout/spec.md`
- [x] T020 Reconcile `.specify/memory/current-system.md` through the mandatory `speckit.system-memory.sync` hook and record the changed root-layout claims
- [x] T021 Run `.specify/scripts/bash/validate-project.sh`
- [x] T022 Run `$speckit-converge` and append any remaining work to `specs/009-root-flake-layout/tasks.md`

## Dependencies and Execution

- T001–T002 establish the baseline before any move.
- T003–T005 are foundational and block both user stories.
- T006 blocks T009–T011; T007 and T008 may proceed in parallel after relocation.
- User Story 2 documentation tasks can proceed after relocation, but behavior verification follows
  the flake and workflow path updates.
- T017–T022 follow both user-story checkpoints.
- Tasks touching `flake.nix` or `tasks.md` run sequentially.
- VM checks remain delegated to CI because runtime composition does not change and both host builds
  provide the required local proof.

## Parallel Execution Examples

- After T006, update `.github/workflows/verify.yml` (T007) and
  `.github/workflows/update-flake.yml` (T008) independently.
- After foundational relocation, update `AGENTS.md` (T012) and active documentation (T013)
  independently of workflow edits.

## Implementation Strategy

The MVP is User Story 1: relocate the source boundary, update the flake and workflows, and prove
Actionlint works purely for both `.` and `path:.`. User Story 2 then verifies the public profile and
system invariants before final memory reconciliation and convergence.

## Completion Rules

- All requirements, invariants, and acceptance scenarios map to at least one task.
- Every completed task is marked `[X]`.
- No placeholder or sample task remains.
- `$speckit-analyze` reports no unresolved critical inconsistency before implementation.
- `$speckit-converge` reports no remaining implementation gap before review.
