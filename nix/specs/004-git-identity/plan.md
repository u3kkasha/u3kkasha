# Implementation Plan: Repository-Local Git Identity

**Feature Directory**: `004-git-identity` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary

Remove unused personal name/email values from `lib.internal` and replace the existing email
format test with assertions that shared values and generated global Git settings contain no identity.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both

**Affected layers**: internal library, generated Home Manager tests

**Inputs/packages/options**: Home Manager `programs.git.settings`

**State or migration impact**: no managed repository-local state is changed

**Security impact**: removes unused personal data from shared configuration

**Rollback**: restore prior declarations; repository-local identity remains untouched

**Constraints**: preserve every non-identity Git setting and both state versions

## Constitution Check

| Principle                           | Evidence of compliance                                | Status |
| ----------------------------------- | ----------------------------------------------------- | ------ |
| Declarative, reproducible ownership | Policy is expressed by absence in internal/HM sources | PASS   |
| Shared modules and host boundaries  | Shared identity policy applies equally to both hosts  | PASS   |
| State compatibility                 | No state-version or repository-local mutation         | PASS   |
| Explicit security boundaries        | Personal data exposure is reduced                     | PASS   |
| Verification follows impact         | Focused evaluation assertions                         | PASS   |
| Current-system memory               | Internal-value and Git policy claims reconciled       | PASS   |
| Smallest coherent design            | Remove two unused fields and replace one test         | PASS   |

## Current and Target Design

### Current

`lib/internal/default.nix` declares `name` and `email`; `modules/home/git.nix` does not apply
them, and `tests/unit.nix` only checks email syntax.

### Target

The internal values and generated global Git settings contain no identity. All other Git-related
Home Manager programs and settings remain unchanged.

### Decision Rationale

The operator explicitly chose repository-local configuration. Applying the values globally would
contradict that policy; retaining unused personal data has no value.

## Repository Touchpoints

```text
lib/internal/default.nix
tests/unit.nix
.specify/memory/current-system.md
```

## Verification Matrix

| Requirement/story    | Target           | Verification command or observation        | Local/CI |
| -------------------- | ---------------- | ------------------------------------------ | -------- |
| FR-001..FR-002 / US1 | internal/both HM | generated-configuration assertions         | Local    |
| FR-003 / INV-001     | both HM          | existing Git program assertions/evaluation | Local    |
| INV-002              | both hosts       | state-version assertions                   | Local    |

## Delivery and Recovery

1. Replace the email-format test with absence assertions.
2. Remove the two unused internal values.
3. Evaluate both hosts; no activation migration is required.

## Current-System Reconciliation

- Remove name/email from the internal-values claim and document repository-local Git identity.
- Remove the unused Git identity limitation.

## Complexity Tracking

No constitution violation or retained complexity.
