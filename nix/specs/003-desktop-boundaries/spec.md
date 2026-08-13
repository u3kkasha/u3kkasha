# Feature Specification: Desktop Boundaries

**Feature Directory**: `003-desktop-boundaries`

**Created**: 2026-08-13

**Status**: Draft

**Input**: "Use Niri-native monitor resume, move physical display configuration to the bare-metal host, and exclude cursor assets when GUI support is disabled."

## Intent and Scope

### Problem

The shared Home Manager layer contains a physical laptop display declaration, invokes a
Hyprland command when a Niri session resumes, and includes cursor assets even for the
GUI-disabled WSL composition.

### Desired Outcome

Shared desktop modules remain reusable, Niri resumes monitors through its own interface,
the bare-metal host owns its display details, and GUI-disabled Home Manager closures contain
no GUI-only cursor configuration or cursor package.

### Out of Scope

- Changing the selected compositor, display mode, scale, cursor theme, or state versions.
- Enabling a graphical session on WSL.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                               |
| -------------------------------- | --------- | -------------------------------------------------------- |
| `nixos` host                     | Yes       | Owns its display stanza and uses native Niri resume      |
| `nixos-wsl` host                 | Yes       | Excludes cursor configuration and assets                 |
| Shared NixOS modules             | No        | N/A                                                      |
| Shared Home Manager modules      | Yes       | Becomes host-neutral and correctly GUI-gated             |
| Developer shell or agent tooling | No        | N/A                                                      |
| CI, caching, or verification     | Yes       | Generated configuration and closure assertions are added |

## User Scenarios & Testing

### User Story 1 - Resume a Niri Session Correctly (Priority: P1)

As the graphical user, suspended monitors power on through a command that belongs to the
active Niri session.

**Why this priority**: The current command targets a different compositor and can fail at runtime.

**Independent Test**: Generated idle configuration contains `niri msg action
power-on-monitors`, excludes the prior `hyprctl` command, and a practical command check is
present in the graphical VM validation.

**Acceptance Scenarios**:

1. **Given** the Niri session resumes, **When** the idle manager runs its after-sleep action,
   **Then** it calls Niri's native power-on-monitors action.

### User Story 2 - Keep Host Display Details Host-Owned (Priority: P2)

As a maintainer, I can reuse the shared Niri module without inheriting the bare-metal
laptop's physical output declaration.

**Why this priority**: Host-specific display facts violate the shared module boundary.

**Independent Test**: The shared generated Niri fragment contains no `eDP-1` stanza while
the `nixos` host composition contributes the same mode and scale.

**Acceptance Scenarios**:

1. **Given** the shared Home Manager modules, **When** they are inspected independently,
   **Then** they contain no physical output identifier.
2. **Given** the bare-metal host, **When** its Home Manager configuration is generated,
   **Then** its `eDP-1` mode and scale remain configured.

### User Story 3 - Keep WSL GUI-Free (Priority: P2)

As the WSL user, disabling GUI support excludes GUI-only cursor configuration and assets.

**Why this priority**: A disabled feature must not enlarge the WSL closure with its packages.

**Independent Test**: WSL Home Manager evaluation shows no enabled pointer cursor and no
Bibata cursor package in its package or generated closure inputs.

**Acceptance Scenarios**:

1. **Given** `internal.gui.enable = false`, **When** Home Manager is evaluated, **Then** the
   cursor configuration is disabled and the cursor package is absent.

### Edge Cases

- Host-specific Niri text must merge deterministically with the shared generated file.
- The cursor theme remains enabled on the graphical bare-metal host.

## Requirements

### Functional Requirements

- **FR-001**: Niri resume handling MUST invoke `niri msg action power-on-monitors` and MUST
  NOT invoke `hyprctl`.
- **FR-002**: Shared Home Manager modules MUST NOT contain physical output identifiers or
  host-specific display modes.
- **FR-003**: The bare-metal host MUST retain its current `eDP-1` mode and scale declaratively.
- **FR-004**: Disabling `internal.gui.enable` MUST disable pointer cursor configuration and
  exclude its cursor package from the WSL Home Manager closure.

### Invariants

- **INV-001**: The graphical host MUST retain Niri and the existing display behavior.
- **INV-002**: WSL MUST remain non-graphical and both state versions MUST remain unchanged.

### Security and State

- **SEC-001**: No privilege, credential, socket, or trust boundary changes.
- **STATE-001**: No persistent-state migration; rollback is the previous generation.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Generated-configuration checks prove the native resume command and host-only
  display stanza.
- **SC-002**: A WSL closure assertion proves the cursor package is absent.
- **SC-003**: Both host builds pass and the graphical VM derivation validates the practical
  Niri command path when feasible.

## Current-System Impact

- **Claims to update**: Architecture host boundaries, Home Manager GUI behavior,
  Maintenance and Verification.
- **Limitations resolved or introduced**: Resolves the Niri resume, GUI cursor leakage, and
  shared physical-display limitations; introduces none.

## Assumptions

- The existing `eDP-1` declaration accurately describes only the `nixos` host.
