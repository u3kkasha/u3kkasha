# Implementation Plan: Agent Commit Guidance

**Feature Directory**: `012-agent-commit-guidance` | **Date**: 2026-09-21 | **Spec**: [spec.md](spec.md)

## Summary

Extend the existing shared instruction payload with a Git commits section and assert
its required semantics in generated-configuration tests.

## Technical Context

**Configuration language**: Nix and Markdown
**Flake architecture**: `flake-parts`, NixOS, Home Manager
**Affected hosts**: both
**Affected layers**: shared Home Manager source and configuration tests
**Inputs/packages/options**: Existing `home.file` mappings; no new dependency
**State or migration impact**: N/A
**Security impact**: N/A
**Rollback**: Revert the instruction and assertion
**Constraints**: Both generated destinations must remain byte-identical

## Constitution Check

| Principle             | Evidence                                    | Status |
| --------------------- | ------------------------------------------- | ------ |
| Declarative ownership | Edit the existing Home Manager-owned source | PASS   |
| Shared boundaries     | Host-neutral wording remains shared         | PASS   |
| State compatibility   | No state change                             | PASS   |
| Security boundaries   | No security change                          | PASS   |
| Verification          | Formatting and configuration tests          | PASS   |
| Current-system memory | Existing ownership claim remains accurate   | PASS   |
| Smallest design       | Extend the existing source and assertion    | PASS   |

Post-design check: all gates pass.

## Current and Target Design

### Current

One Markdown source supplies identical global Codex and Gemini instructions.

### Target

That source additionally defines focused milestone commits and mandatory Conventional
Commits formatting.

### Decision Rationale

Keeping policy in the existing shared source preserves identical output and avoids a new module.

## Repository Touchpoints

```text
modules/home/agent-instructions.md
tests/configuration.nix
specs/012-agent-commit-guidance/
```

## Verification Matrix

| Requirement/story       | Target                   | Verification                                                    | Local/CI |
| ----------------------- | ------------------------ | --------------------------------------------------------------- | -------- |
| FR-001–FR-003 / US1     | Both host configurations | `nix build path:.#configuration-tests --no-link`                | Local    |
| Formatting              | Repository               | `nix fmt -- --fail-on-change`                                   | Local    |
| Shared host composition | Both hosts               | Existing generated-configuration evaluation plus CI host builds | Local/CI |

## Delivery and Recovery

1. Add the semantic assertion.
2. Extend the shared instruction source.
3. Run formatting and configuration verification.
4. Revert both edits to roll back.

## Current-System Reconciliation

No prose claim changes: the canonical memory already states that one host-neutral source
generates identical global instructions.

## Complexity Tracking

No exceptions.
