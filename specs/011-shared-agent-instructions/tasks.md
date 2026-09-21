---
description: "Nix configuration implementation tasks"
---

# Tasks: Shared Agent Instructions

**Input**: `spec.md` and `plan.md` from `specs/011-shared-agent-instructions/`

**Organization**: Tasks are grouped by independently verifiable configuration outcome.

## Phase 1: Guardrails and Baseline

- [x] T001 Record current file ownership and content differences in `specs/011-shared-agent-instructions/research.md`
- [x] T002 Add shared-file assertions for both hosts in `tests/configuration.nix` and the module path in `tests/unit.nix`

## Phase 2: User Story 1 - Consistent Global Instructions (Priority: P1)

**Goal**: Both supported hosts export identical host-neutral global instructions.

**Independent Test**: `nix build .#configuration-tests --no-link`

- [x] T003 [US1] Define one payload and both destinations in `modules/home/agent-instructions.nix`
- [x] T004 [US1] Verify deterministic module discovery with `nix build .#unit-tests --no-link`
- [x] T005 [US1] Verify both host file outputs with `nix build .#configuration-tests --no-link`

## Final Phase: Cross-Target Verification and Memory

- [x] T006 Run formatting with `nix fmt -- --fail-on-change`
- [ ] T007 Build both hosts with `nix build .#nixos-build .#nixos-wsl-build --no-link`
- [x] T008 Confirm no security, state-version, or existing agent-integration regression using `spec.md` and test results
- [x] T009 Reconcile `.specify/memory/current-system.md` through the mandatory `speckit.system-memory.sync` hook
- [x] T010 Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- T001 precedes the test and implementation changes.
- T002 precedes T003 so the desired outputs are asserted first.
- T003 precedes all verification tasks.
- T009 follows implementation evidence and precedes T010.

## Completion Rules

- All requirements and acceptance scenarios map to T002–T008.
- Every completed task is marked `[X]`.
- `$speckit-analyze` reports no unresolved critical inconsistency.
- `$speckit-converge` reports no remaining implementation gap.
