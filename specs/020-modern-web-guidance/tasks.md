# Tasks: Modern Web Guidance Skill

**Input**: Design documents from `specs/020-modern-web-guidance/`

## Phase 1: Setup

**Purpose**: No separate setup is needed; the existing Home Manager defaults own shared agent tooling.

## Phase 2: User Story 1 - Use modern web guidance in coding agents (Priority: P1)

**Goal**: Install the official skill source through shared Home Manager configuration.

**Independent Test**: Evaluate both hosts and confirm both skill paths point at the fixed-hash source archive.

- [x] T001 [US1] Pin the modern-web-guidance v1.0.1 GitHub source archive in modules/home/default.nix.
- [x] T002 [US1] Expose the skill source to Codex and OpenCode in modules/home/default.nix.

## Phase 3: User Story 2 - Understand skill ownership (Priority: P2)

**Goal**: Document current global and project-level skill management.

**Independent Test**: Confirm current-system.md explains Nix-managed skills and project-level discovery.

- [x] T003 [US2] Update skill ownership, source, and update path in .specify/memory/current-system.md.

## Phase 4: Polish

**Purpose**: Format and evaluate the resulting shared configuration.

- [x] T004 Reconcile delivered behavior in .specify/memory/current-system.md with the system-memory sync hook.
- [x] T005 Run Nix formatting and evaluate both supported host configurations.

## Dependencies & Execution Order

- T001 precedes T002 because it defines the skill source.
- T003 can proceed independently of the Nix implementation.
- T004 follows implementation and documentation tasks; T005 follows all other work.

## Parallel Opportunities

- T003 is independent of T001-T002.

## Implementation Strategy

Deliver the shared agent capability first, update canonical system memory, then format and evaluate both host configurations.
