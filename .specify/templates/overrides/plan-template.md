# Implementation Plan: [FEATURE]

**Feature Directory**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `specs/[###-feature-name]/spec.md`

Read the specification, `.specify/memory/constitution.md`, and
`.specify/memory/current-system.md` before filling this plan.

## Summary

[Primary outcome and chosen technical approach]

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: [`nixos`, `nixos-wsl`, both, or none]

**Affected layers**: [flake, internal library, shared NixOS, Home Manager, host, tests, CI]

**Inputs/packages/options**: [Relevant locked inputs and exact option or package names]

**State or migration impact**: [Details or N/A]

**Security impact**: [Privileges, credentials, trust, secrets, sockets, unfree policy, or N/A]

**Rollback**: [Previous generation, revert, manual recovery, or limitation]

**Constraints**: [Purity, WSL isolation, closure size, compatibility, or other limits]

## Constitution Check

_GATE: Must pass before design and be re-checked after the design is complete._

| Principle                           | Evidence of compliance                         | Status    |
| ----------------------------------- | ---------------------------------------------- | --------- |
| Declarative, reproducible ownership | [Owning Nix source and pinned dependency path] | PASS/FAIL |
| Shared modules and host boundaries  | [Why placement is shared or host-scoped]       | PASS/FAIL |
| State compatibility                 | [Migration analysis or N/A]                    | PASS/FAIL |
| Explicit security boundaries        | [Privilege and credential analysis or N/A]     | PASS/FAIL |
| Verification follows impact         | [Mapped verification commands]                 | PASS/FAIL |
| Current-system memory               | [Claims that will be reconciled]               | PASS/FAIL |
| Smallest coherent design            | [Simpler alternatives considered]              | PASS/FAIL |

## Current and Target Design

### Current

[Describe only the relevant implemented path, citing source files and current-system
sections.]

### Target

[Describe the resulting path and boundaries.]

### Decision Rationale

[Alternatives, trade-offs, and why the selected design is preferred.]

## Repository Touchpoints

```text
[List concrete files and directories to add, modify, or remove. Do not include generic
src/, API, database, or frontend placeholders.]
```

## Verification Matrix _(mandatory)_

| Requirement/story | Target                  | Verification command or observation | Local/CI   |
| ----------------- | ----------------------- | ----------------------------------- | ---------- |
| [FR-001 / US1]    | [host/layer]            | [exact command]                     | [Local/CI] |
| [Invariant]       | [unaffected host/layer] | [exact command]                     | [Local/CI] |

## Delivery and Recovery

1. [Safe implementation sequence]
2. [Application or activation sequence, if applicable]
3. [Rollback or recovery procedure]

## Current-System Reconciliation

After implementation, update only the claims proven to have changed:

- [Capability status, architecture, workflow, policy, verification, or limitation]

The mandatory `speckit.system-memory.sync` hook performs this reconciliation and records
the result in the feature tasks.

## Complexity Tracking

> Fill only for justified constitution violations or deliberately retained complexity.

| Complexity | Why required | Simpler alternative rejected because |
| ---------- | ------------ | ------------------------------------ |
| [Item]     | [Reason]     | [Reason]                             |
