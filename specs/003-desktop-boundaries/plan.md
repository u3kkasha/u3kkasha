# Implementation Plan: Desktop Boundaries

**Feature Directory**: `003-desktop-boundaries` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary

Gate pointer cursor configuration on `internal.gui.enable`, replace the Niri resume command,
and expose a small host-supplied Niri output fragment so the bare-metal composition owns its
physical display without competing for the generated file.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both

**Affected layers**: shared Home Manager, bare-metal host composition, generated checks, VM test

**Inputs/packages/options**: Home Manager `home.pointerCursor`; Niri and hypridle generated KDL/text

**State or migration impact**: N/A

**Security impact**: N/A

**Rollback**: previous generation

**Constraints**: one owner for `niri/config.kdl`; WSL remains GUI-disabled

## Constitution Check

| Principle                           | Evidence of compliance                                             | Status |
| ----------------------------------- | ------------------------------------------------------------------ | ------ |
| Declarative, reproducible ownership | Home Manager sources own all generated files                       | PASS   |
| Shared modules and host boundaries  | Physical display stanza moves under `systems/` composition         | PASS   |
| State compatibility                 | No state-version change                                            | PASS   |
| Explicit security boundaries        | No security-boundary change                                        | PASS   |
| Verification follows impact         | generated checks, WSL closure assertion, both builds, graphical VM | PASS   |
| Current-system memory               | Desktop architecture and limitations reconciled                    | PASS   |
| Smallest coherent design            | One optional fragment extends existing Niri file ownership         | PASS   |

## Current and Target Design

### Current

`modules/home/niri.nix` embeds `eDP-1` and invokes `hyprctl` after sleep.
`modules/home/default.nix` unconditionally enables Bibata pointer cursor configuration.

### Target

The shared Niri module contains only reusable behavior plus an internal output fragment option.
The `nixos` host supplies its `eDP-1` stanza through its Home Manager user configuration.
Pointer cursor configuration exists only when GUI support is enabled.

### Decision Rationale

An internal text fragment preserves a single declarative owner for the generated KDL file and
keeps the change smaller than splitting the full Niri module or managing a runtime file.

## Repository Touchpoints

```text
modules/home/default.nix
modules/home/niri.nix
systems/x86_64-linux/nixos/default.nix
tests/unit.nix
tests/vm-nixos.nix
.specify/memory/current-system.md
```

## Verification Matrix

| Requirement/story    | Target             | Verification command or observation                         | Local/CI |
| -------------------- | ------------------ | ----------------------------------------------------------- | -------- |
| FR-001 / US1         | nixos generated HM | generated-configuration assertion and Niri CLI availability | Local/CI |
| FR-002..FR-003 / US2 | shared/nixos       | source and generated KDL assertions                         | Local    |
| FR-004 / US3         | WSL HM             | cursor option and closure/package assertions                | Local    |
| INV-001..INV-002     | both hosts         | both host builds                                            | Local    |

## Delivery and Recovery

1. Add generated assertions for resume, display ownership, and WSL cursor absence.
2. Add the host fragment option, move the stanza, and gate pointer cursor configuration.
3. Build both hosts and run the graphical VM when feasible.
4. Roll back through the prior generation if session behavior regresses.

## Current-System Reconciliation

- Record host-owned display composition and GUI-gated cursor behavior.
- Remove the three resolved desktop limitations.

## Complexity Tracking

No constitution violation or retained complexity.
