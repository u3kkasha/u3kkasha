# Tasks: Agent Commit Guidance

## Phase 1: Guardrails

- [x] T001 Add commit-guidance assertions to `tests/configuration.nix`

## Phase 2: User Story 1 - Frequent Conventional Commits

- [x] T002 [US1] Add milestone, focus, and Conventional Commits guidance to `modules/home/agent-instructions.md`
- [x] T003 [US1] Run `nix build path:.#configuration-tests --no-link`

## Final Phase: Verification and Memory

- [x] T004 Run `nix fmt -- --fail-on-change`
- [x] T005 Confirm `.specify/memory/current-system.md` needs no factual change
- [x] T006 Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- T001 precedes T002; verification follows implementation.

## Completion Rules

- All tasks are checked and convergence finds no remaining work.
