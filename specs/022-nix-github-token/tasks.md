# Tasks: Pass GitHub CLI Credentials to Nix

**Input**: Design documents from `/specs/022-nix-github-token/`

## Phase 1: User Story 1 - Authenticated GitHub fetches (P1)

**Goal**: Supply the runtime GitHub CLI token to Nix commands in both managed shells.

**Independent Test**: Verify generated Bash and Nushell wrappers preserve existing NIX_CONFIG, pass a token only when available, and fall back cleanly.

- [x] T001 [US1] Add runtime token injection to Bash Nix invocations in modules/home/bash.nix
- [x] T002 [US1] Add runtime token injection to Nushell Nix invocations in modules/home/nushell.nix
- [x] T003 [US1] Reconcile runtime credential behavior in .specify/memory/current-system.md

## Dependencies & Execution Order

- T001 and T002 are independent shell implementations; T003 follows both.

## Implementation Strategy

Deliver the single user story across both configured shells, then update canonical system memory.
