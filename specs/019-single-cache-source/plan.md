# Implementation Plan: Single Cache Source

**Branch**: `019-single-cache-source` | **Date**: 2026-10-17 | **Spec**: [spec.md](spec.md)

## Summary

Move the Niri cache into the canonical cache source, disable the Niri module's duplicate cache setting, and remove the duplicated flake bootstrap literals.

## Technical Context

**Language/Version**: Nix 2.34.8
**Primary Dependencies**: Nix flake and NixOS module system
**Storage**: N/A
**Testing**: Existing NixOS configuration assertions
**Target Platform**: x86_64-linux NixOS hosts
**Project Type**: NixOS configuration
**Constraints**: Flake `nixConfig` values are literal and cannot reuse the imported canonical source
**Scale/Scope**: Shared cache settings for two hosts

## Constitution Check

- Declarative ownership: pass; `lib/internal/cache.nix` owns the complete cache lists.
- Security boundary: pass; existing cache endpoints and keys are retained unchanged.
- Verification: run formatting and the affected host configuration assertions.
- Current-system memory: document canonical ownership and loss of bootstrap cache hints.
- Smallest coherent design: disable the Niri module cache option instead of deduplicating values after module merge.

## Project Structure

```text
flake.nix
lib/internal/cache.nix
modules/nixos/system/default.nix
tests/configuration.nix
.specify/memory/current-system.md
```

**Structure Decision**: Update existing files that own the flake metadata, host cache policy, assertions, and architecture summary.
