---
description: "Persist Headroom savings implementation tasks"
---

# Tasks: Persist Headroom Savings

**Input**: `spec.md` and `plan.md` from `specs/010-persist-headroom-savings/`

**Organization**: Tasks are grouped by independently verifiable configuration outcome.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Safe to execute concurrently because files and dependencies do not overlap.
- **[US#]**: Traceability to the specification's configuration outcome.
- Every task names exact repository paths or verification commands.

## Phase 1: Guardrails and Baseline

**Purpose**: Establish current behavior and add checks that distinguish persistent savings
from temporary wrapper state.

- [x] T001 Record baseline results for `nix build .#checks.x86_64-linux.formatting --no-link`, `nix build .#configuration-tests --no-link`, and `nix build .#headroom-tests --no-link` in `specs/010-persist-headroom-savings/tasks.md` (all passed before implementation on 2026-09-09)
- [x] T002 Add generated-configuration assertions for the shared savings path on both hosts and the launcher state split in `tests/configuration.nix`
- [x] T003 [P] Add an offline savings-ledger persistence and aggregation scenario in `tests/headroom.nix`

**Checkpoint**: Existing checks pass at baseline and the new assertions encode the requested
state boundary.

## Phase 2: User Story 1 - Review Wrapped Codex Savings (Priority: P1)

**Goal**: Wrapped Codex savings persist in the shared user-scoped Headroom history and are
visible through the standard reporting command.

**Independent Test**: `nix build .#configuration-tests .#headroom-tests --no-link` proves the
launcher selects the shared ledger and Headroom reports an event after temporary state is
removed.

- [x] T004 [US1] Define the shared XDG savings ledger path and expose it as the dedicated Headroom session variable in `modules/home/headroom.nix`
- [x] T005 [US1] Explicitly export the shared savings ledger path in the `codex-headroom` launcher in `modules/home/headroom.nix`
- [x] T006 [US1] Verify persistent recording and reporting with `nix build .#configuration-tests .#headroom-tests --no-link`

**Checkpoint**: User Story 1 is independently satisfied and two producers can use the same
Headroom-owned ledger.

## Phase 3: User Story 2 - Preserve Session Isolation (Priority: P2)

**Goal**: Only savings accounting persists; proxy memory, logs, caches, configuration, and
process lifetime remain session-isolated.

**Independent Test**: `nix build .#configuration-tests --no-link` proves the launcher retains
temporary roots, cleanup, loopback routing, and telemetry/subscription controls alongside
the single persistent ledger override.

- [x] T007 [US2] Confirm and, if needed, refine launcher isolation assertions in `tests/configuration.nix`
- [x] T008 [US2] Verify both host configurations preserve routing and isolation invariants with `nix build .#configuration-tests --no-link`

**Checkpoint**: User Story 2 is independently satisfied.

## Final Phase: Cross-Target Verification and Memory

- [x] T009 Run `nix build .#checks.x86_64-linux.formatting --no-link`, `nix build .#configuration-tests --no-link`, and `nix build .#headroom-tests --no-link`
- [x] T010 Delegate `nix build .#nixos-build .#nixos-wsl-build --no-link` to CI as specified in `specs/010-persist-headroom-savings/plan.md`
- [x] T011 Confirm state, security, reset, rollback, and unaffected-routing invariants from `specs/010-persist-headroom-savings/spec.md`
- [x] T012 Reconcile `.specify/memory/current-system.md` through the mandatory `speckit.system-memory.sync` hook and record the result here (Updated "Home Manager and Agent Tooling" to document HEADROOM_SAVINGS_EVENTS_PATH session variable and launcher export preserving only the shared savings ledger while all other temporary proxy state is removed on exit)
- [x] T013 Run `.specify/scripts/bash/validate-project.sh`
- [x] T014 Run `speckit-converge` and append any remaining work to `specs/010-persist-headroom-savings/tasks.md` (Converged: zero remaining gaps)

## Dependencies and Execution

- T001 precedes test and implementation changes.
- T002 and T003 may proceed in parallel because they touch different test files.
- T004 precedes T005 because both touch `modules/home/headroom.nix` and share one path value.
- User Story 1 precedes User Story 2 because isolation is validated against the completed
  persistent-ledger behavior.
- T009–T014 follow both user stories.
- Shared-module changes are not complete until both host evaluations covered by
  `configuration-tests` pass; full host builds remain delegated to CI per the plan.

## Parallel Example: User Story 1 Guardrails

```text
T002: Assert generated Home Manager/launcher configuration in tests/configuration.nix
T003: Exercise the pinned Headroom ledger in tests/headroom.nix
```

## Implementation Strategy

1. Establish the green baseline and introduce focused assertions.
2. Deliver the P1 savings path and prove persistence/reporting.
3. Re-check P2 session-isolation invariants.
4. Run the local verification matrix, memory sync, project validation, and convergence.

The MVP is User Story 1: persist and report wrapped-session savings through the unified
ledger. User Story 2 is mandatory before completion because it protects the wrapper's
privacy and lifecycle boundary.
