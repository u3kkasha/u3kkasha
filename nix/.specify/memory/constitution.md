# Nix Configuration Constitution

## Core Principles

### I. Declarative, Reproducible Ownership

System and user configuration MUST be expressed through the flake, NixOS modules,
or Home Manager modules. Files produced under runtime configuration directories are
generated outputs and MUST NOT be edited or auto-migrated in place. Dependencies and
agent tooling MUST come from pinned flake inputs or packaged Nix derivations; runtime
dependency resolvers are not acceptable for persistent configuration.

### II. Shared Modules and Host Boundaries

Reusable modules MUST remain independent of physical-host details. Host-specific
hardware, display, boot, WSL, or filesystem choices belong under `systems/`. The
`scanPaths` auto-discovery contract MUST remain deterministic, and every change to a
discovered module tree MUST update its exact-list unit test. WSL-only upstream modules
MUST remain scoped to the WSL host rather than the shared core.

### III. State Compatibility Is Deliberate

`systemStateVersion` and `homeStateVersion` are compatibility shims, not rolling release
numbers. They MUST change only as part of an explicit migration whose specification
identifies stateful formats, release-note requirements, rollback limits, and manual
operator steps. Routine dependency updates MUST NOT modify either value.

### IV. Security Boundaries Are Explicit

Privileges, trusted users, sockets, credentials, secret handling, and unfree-package
allowances MUST be minimized and documented. A change that grants root-equivalent or
cross-user authority MUST state that boundary in its specification and include a test or
an explicit verification procedure. Credentials MUST be scoped to the consumer that
needs them and MUST NOT be exported globally.

### V. Verification Follows Impact

Every change MUST run the least expensive checks that prove its affected behavior and
MUST identify the heavier checks delegated to CI. At minimum, Nix edits require
formatting and relevant evaluation or unit checks. Host composition changes require the
affected system build; shared behavior requires both host builds; runtime integration
changes require the relevant VM test. Tests MUST remain categorized honestly: a check
with an integration-sized closure MUST NOT be presented as a quick unit test.

### VI. Current-System Memory Is Canonical

`.specify/memory/current-system.md` is the sole prose source of truth for implemented
architecture, supported targets, operational workflows, and known limitations. Feature
specifications express intended outcomes; plans record technical decisions; completed
feature directories preserve history. Any implemented change that alters current-system
claims MUST update the current-system document in the same change. Planned behavior
MUST NOT be described as operational.

### VII. Prefer the Smallest Coherent Design

Changes SHOULD extend existing module boundaries and shared helpers before adding new
abstractions. Complexity, duplicated cache or option declarations, impure evaluation,
and discarded dependency context require explicit justification in the implementation
plan. Generated or managed files MUST be updated through their owning source.

## Specification Threshold

The full Spec Kit workflow is REQUIRED when a change:

- affects more than one host or crosses system, Home Manager, CI, or agent-tooling layers;
- changes architecture, module discovery, supported hosts, security boundaries, state,
  backup or migration behavior, caching policy, or the verification model;
- introduces a new subsystem or replaces an existing one; or
- involves meaningful alternatives whose rationale should survive in history.

Direct maintenance without a feature specification is permitted for lockfile refreshes,
format-only edits, factual current-system corrections, and isolated option or package
changes with obvious verification and no policy impact. If scope expands while working,
stop and create a specification.

## Development Workflow

Material changes follow this sequence:

1. `$speckit-specify` defines observable outcomes, invariants, scope, and acceptance.
2. `$speckit-clarify` is used when a consequential ambiguity remains.
3. `$speckit-plan` identifies affected hosts and layers, security and state impact,
   rollback, and the verification matrix.
4. `$speckit-tasks` creates traceable implementation, testing, and memory-sync tasks.
5. `$speckit-analyze` checks consistency before implementation.
6. `$speckit-implement` performs and checks off the approved work.
7. The mandatory system-memory hook reconciles implemented reality with
   `.specify/memory/current-system.md`.
8. `$speckit-converge` checks for remaining gaps before review.

Implementation MUST NOT silently widen an approved feature's scope. A discovered design
change belongs in `plan.md`; changed outcomes belong in `spec.md`; newly required work
belongs in `tasks.md`.

## Governance

This constitution is binding for Spec Kit commands and ordinary repository work.
`AGENTS.md` is only its discovery entrypoint. Source and executable checks are the
evidence for current behavior; when prose conflicts with them, correct the prose or the
implementation before declaring the change complete.

Amendments require a rationale, a semantic version increment, and synchronized changes
to affected templates and current-system policy. MAJOR removes or redefines a principle,
MINOR adds or materially expands one, and PATCH clarifies wording without changing its
meaning.

**Version**: 1.0.0 | **Ratified**: 2026-08-13 | **Last Amended**: 2026-08-13
