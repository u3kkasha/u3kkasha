---
description: "CI supply-chain hardening implementation tasks"
---

# Tasks: CI Supply-Chain Hardening

**Input**: `spec.md` and `plan.md` from `specs/007-ci-supply-chain/`

**Organization**: Tasks are grouped by independently verifiable configuration outcome.

## Phase 1: Guardrails and Baseline

**Purpose**: Preserve evidence of current workflow and live-setting weaknesses.

- [x] T001 Record workflow syntax, run-history, ruleset, Actions-permission, Dependabot-security, and CodeQL baseline observations in `specs/007-ci-supply-chain/research.md`
- [x] T002 Validate the complete requirement-to-task mapping across `specs/007-ci-supply-chain/spec.md`, `plan.md`, and `tasks.md`

**Checkpoint**: Every observed gap has a requirement and an implementation task.

## Phase 2: User Story 1 - Prevent Unverified Merges (Priority: P1)

**Goal**: Make the complete required workflow graph resolve into one mandatory stable result.

**Independent Test**: Validate workflow syntax, inspect the aggregate result predicates, and query
ruleset `17533543` for the `CI Gate` required status context.

- [x] T003 [US1] Add a failure-aware aggregate `CI Gate` job to `.github/workflows/verify.yml`
- [x] T004 [US1] Add `CI Gate` as a required status check in live GitHub ruleset `17533543`
- [x] T005 [US1] Verify FR-001 and FR-002 with local workflow inspection and `gh api repos/u3kkasha/u3kkasha/rulesets/17533543`

**Checkpoint**: Failed or cancelled required jobs cannot yield a successful merge gate.

## Phase 3: User Story 2 - Minimize CI Credential and Supply-Chain Risk (Priority: P1)

**Goal**: Keep PR verification read-only and constrain workflow dependencies to approved immutable Actions.

**Independent Test**: Inspect event conditions and query GitHub Actions/security settings.

- [x] T006 [US2] Separate unauthenticated PR Cachix use from trusted publishing and disable persisted checkout credentials in `.github/workflows/verify.yml`
- [x] T007 [US2] Enforce full-SHA Action references and allow only GitHub-owned, Determinate Systems, Cachix, and Gitleaks Actions in live repository settings
- [x] T008 [US2] Enable Dependabot security updates and CodeQL default setup for detected supported languages in live repository settings
- [x] T009 [US2] Verify FR-003, FR-004, FR-009, FR-010, SEC-001, and retained secret-scanning protections through workflow inspection and GitHub API queries

**Checkpoint**: PR builds have no write credential and live supply-chain settings match policy.

## Phase 4: User Story 3 - Make Automation Bounded and Reviewable (Priority: P2)

**Goal**: Bound executions, avoid updater contention, periodically prove cache independence, and
show package-level impact for lock updates.

**Independent Test**: Validate both workflows and inspect trigger, concurrency, timeout, cache, and
summary behavior.

- [x] T010 [P] [US3] Add updater concurrency and a finite job timeout in `.github/workflows/update-flake.yml`
- [x] T011 [US3] Add appropriate timeouts and monthly schedule routing to `.github/workflows/verify.yml`
- [x] T012 [US3] Add an automated lock-update `nvd` closure-diff summary to the bare-metal build leg in `.github/workflows/verify.yml`
- [x] T013 [US3] Verify FR-005 through FR-008 and the no-duplicate-scheduled-build edge case with workflow validation and inspection
- [x] T014 [US3] Add pinned `actionlint` tooling, a flake check for root workflows, and pre-commit enforcement in `flake.nix`
- [x] T015 [US3] Verify FR-011 with `nix build .#checks.x86_64-linux.actionlint --no-link` and inspect the generated pre-commit hook

**Checkpoint**: Automation is bounded, scheduled work is non-duplicative, and lock updates are reviewable.

## Final Phase: Cross-Target Verification and Memory

- [x] T016 Run `actionlint` against `.github/workflows/*.yml`
- [x] T017 Run `nix fmt -- --ci` and `nix flake check .`
- [x] T018 Confirm `git diff` contains no host, state-version, or deployment change and preserves all required build targets
- [x] T019 Reconcile `.specify/memory/current-system.md` through the mandatory `speckit.system-memory.sync` hook
- [x] T020 Run `.specify/scripts/bash/validate-project.sh`
- [x] T021 Run `$speckit-converge` and resolve any appended implementation tasks

## Dependencies and Execution

- T001–T002 precede implementation.
- T003 precedes T004 because the intended gate definition must be fixed before ruleset mutation.
- T006 precedes T007 so the checked-in workflow is compatible before the publisher allowlist is narrowed.
- T010 is independent of T003/T006/T011/T012 because it edits the updater workflow.
- T011 precedes T012 because both edit the verification workflow.
- Live-setting verification follows all live-setting mutations.
- Current-system reconciliation occurs after implementation evidence and before convergence.

## Completion Rules

- All requirements, invariants, and acceptance scenarios map to at least one task.
- Every completed task is marked `[X]`.
- No placeholder or sample task remains.
- `$speckit-analyze` reports no unresolved critical inconsistency before implementation.
- `$speckit-converge` reports no remaining implementation gap before review.
