---
description: "Nix configuration implementation tasks"
---

# Tasks: [FEATURE NAME]

**Input**: `spec.md` and `plan.md` from `specs/[###-feature-name]/`

**Organization**: Tasks are grouped by independently verifiable configuration outcome.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Safe to execute concurrently because files and dependencies do not overlap.
- **[US#]**: Traceability to the specification's configuration outcome.
- Every task names exact repository paths or verification commands.

## Phase 1: Guardrails and Baseline

**Purpose**: Establish current behavior and the checks that must remain green.

- [ ] T001 Record relevant baseline results using the verification matrix in `plan.md`
- [ ] T002 Add or adjust failing assertions required to prove the specified outcome

**Checkpoint**: The baseline is understood and new assertions fail for the intended reason.

## Phase 2: User Story 1 - [Primary Configuration Outcome] (Priority: P1)

**Goal**: [Outcome from spec]

**Independent Test**: [Exact proof from spec/plan]

- [ ] T003 [US1] Implement [specific change] in [exact path]
- [ ] T004 [US1] Verify [requirement] with [exact command or observation]

**Checkpoint**: User Story 1 is independently satisfied.

## Phase 3: Additional Outcomes

Add one phase per remaining user story. Preserve dependency order, mark genuinely
independent work `[P]`, and omit this phase when there is only one outcome.

- [ ] T005 [US2] Implement [specific change] in [exact path]
- [ ] T006 [US2] Verify [requirement] with [exact command or observation]

## Final Phase: Cross-Target Verification and Memory

- [ ] TXXX Run formatting and the least expensive relevant flake/unit checks
- [ ] TXXX Run or delegate every host build and VM test required by `plan.md`
- [ ] TXXX Confirm security, state, rollback, and unaffected-host invariants from `spec.md`
- [ ] TXXX Reconcile `.specify/memory/current-system.md` through the mandatory
      `speckit.system-memory.sync` hook; record `no current-system change` only with an
      evidence-based reason
- [ ] TXXX Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- Baseline and guardrail tasks precede implementation.
- Tasks touching the same Nix module or expected-list assertion run sequentially.
- Shared-module changes are not complete until both host evaluations/builds required by
  the verification matrix have passed.
- Runtime integration and VM checks may be delegated to CI only when `plan.md` states so.
- Current-system reconciliation occurs after implementation evidence exists and before
  convergence.

## Completion Rules

- All requirements, invariants, and acceptance scenarios map to at least one task.
- Every completed task is marked `[X]`.
- No placeholder or sample task remains.
- `$speckit-analyze` reports no unresolved critical inconsistency before implementation.
- `$speckit-converge` reports no remaining implementation gap before review.
