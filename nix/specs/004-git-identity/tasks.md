# Tasks: Repository-Local Git Identity

**Input**: `spec.md` and `plan.md` from `specs/004-git-identity/`

## Phase 1: Guardrails and Baseline

- [x] T001 Record current internal name/email declarations and generated Git identity absence from `lib/internal/default.nix` and `tests/configuration.nix`
- [x] T002 [US1] Replace the email-format assertion with shared/global identity absence assertions in `tests/unit.nix` and `tests/configuration.nix`

## Phase 2: User Story 1 - Choose Identity Per Repository

- [x] T003 [US1] Remove `name` and `email` from `lib/internal/default.nix`
- [x] T004 [US1] Verify both generated Git configurations remain identity-free using `nix build .#unit-tests .#configuration-tests --no-link`

## Final Phase: Cross-Target Verification and Memory

- [x] T005 Run `nix fmt` and `nix flake check --no-build`
- [x] T006 Confirm non-identity Git programs/settings and both state versions remain unchanged
- [x] T007 Reconcile internal-value and Git ownership claims in `.specify/memory/current-system.md`
- [x] T008 Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- T001-T002 precede T003; T004-T008 follow implementation.

## Completion Rules

- All requirements and invariants map to tasks with exact paths or commands.
