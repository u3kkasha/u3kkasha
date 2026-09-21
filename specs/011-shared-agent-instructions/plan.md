# Implementation Plan: Shared Agent Instructions

**Feature Directory**: `011-shared-agent-instructions` | **Date**: 2026-09-21 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/011-shared-agent-instructions/spec.md`

## Summary

Add one automatically discovered shared Home Manager module containing a single
instruction string and export it to the global Codex and Gemini paths. Extend exact
module-discovery and generated-configuration assertions for both hosts.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both

**Affected layers**: shared Home Manager, unit tests, configuration tests, system memory

**Inputs/packages/options**: `home.file.<name>.text`; no new input or package

**State or migration impact**: Existing mutable files may be handled by the configured Home Manager backup behavior; no state-version change

**Security impact**: N/A

**Rollback**: Revert the module and assertions, then activate the previous system generation; backed-up mutable files remain subject to existing backup limitations

**Constraints**: One payload must serve both destinations and both hosts; runtime Antigravity state remains unmanaged

## Constitution Check

| Principle                           | Evidence of compliance                                       | Status |
| ----------------------------------- | ------------------------------------------------------------ | ------ |
| Declarative, reproducible ownership | `modules/home/agent-instructions.nix` owns both outputs      | PASS   |
| Shared modules and host boundaries  | Host-neutral content belongs in the shared Home Manager tree | PASS   |
| State compatibility                 | No state-version or format migration                         | PASS   |
| Explicit security boundaries        | No security boundary changes                                 | PASS   |
| Verification follows impact         | Exact discovery, both-host evaluation, and both host builds  | PASS   |
| Current-system memory               | Agent-tooling ownership claim will be reconciled             | PASS   |
| Smallest coherent design            | One module and one shared string avoid duplication           | PASS   |

Post-design check: all principles remain satisfied; no complexity exception is required.

## Current and Target Design

### Current

Home Manager enables Codex and Antigravity and generates their MCP configuration, but
the global instruction files are mutable regular files outside flake ownership and their
text differs. The Antigravity runtime directory contains no `GEMINI.md`.

### Target

An auto-discovered shared Home Manager module defines one instruction payload and maps it
to `.codex/AGENTS.md` and `.gemini/GEMINI.md`. Both host evaluations inherit it.

### Decision Rationale

A standalone shared module keeps cross-agent policy separate from package-specific
configuration while reusing the existing deterministic discovery boundary. Duplicating
text in `codex.nix` and `utils.nix` was rejected because it permits drift.

## Repository Touchpoints

```text
modules/home/agent-instructions.nix
tests/unit.nix
tests/configuration.nix
.specify/memory/current-system.md
specs/011-shared-agent-instructions/
```

## Verification Matrix

| Requirement/story      | Target                    | Verification command or observation                   | Local/CI |
| ---------------------- | ------------------------- | ----------------------------------------------------- | -------- |
| FR-001–FR-005 / US1    | both Home Manager configs | `nix build .#configuration-tests --no-link`           | Local    |
| INV-002                | module discovery          | `nix build .#unit-tests --no-link`                    | Local    |
| Formatting             | changed Nix files         | `nix fmt -- --fail-on-change`                         | Local    |
| Cross-host composition | both hosts                | `nix build .#nixos-build .#nixos-wsl-build --no-link` | Local    |
| Runtime replacement    | activated host            | Inspect both files after the next `nh os switch .`    | Operator |

## Delivery and Recovery

1. Add failing assertions for discovered and generated files.
2. Add the shared module and pass unit/configuration verification.
3. Build both host configurations and activate normally when desired.
4. Roll back to the previous NixOS generation or revert the module if recovery is needed.

## Current-System Reconciliation

After implementation, state that shared Home Manager declaratively owns identical global
Codex and Gemini instructions in addition to the existing agent integrations.

The mandatory `speckit.system-memory.sync` hook performs this reconciliation and records
the result in the feature tasks.

## Complexity Tracking

No constitution violations or deliberately retained complexity.
