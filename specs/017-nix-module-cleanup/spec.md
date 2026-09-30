# Feature Specification: Nix Module Cleanup

**Feature Directory**: `017-nix-module-cleanup`

**Created**: 2026-09-30

**Status**: Ready for implementation

**Input**: Improve code cleanliness and maintainability based on the repository audit.

Before completing this specification, read `.specify/memory/constitution.md` and
`.specify/memory/current-system.md`. Describe desired behavior, not implementation.

## Intent and Scope _(mandatory)_

### Problem

The configuration currently replaces the module system's standard library argument
with repository and Home Manager helpers. Some large, distinct configuration concerns
also live inside Nix module files, and a general utility module mixes everyday commands
with developer toolchains. These choices make the module interfaces and ownership harder
to understand than necessary.

### Desired Outcome

Maintainers can follow the standard Nix module interface, find native application
configuration in files of its own format, and locate packages by their purpose. Flake
outputs remain identical while shared derivations have one definition.

### Out of Scope

- Changing enabled software, package versions, host behavior, or generated runtime values.
- Changing cache, privilege, state-version, backup, or secret policies.
- Reworking Home Manager module discovery or the host/shared-module boundary.

## Affected Targets _(mandatory)_

| Target or layer                  | Affected? | Expected observable change                                                  |
| -------------------------------- | --------- | --------------------------------------------------------------------------- |
| `nixos` host                     | Yes       | Uses named repository helpers while preserving the standard module library. |
| `nixos-wsl` host                 | Yes       | Same module interface and package behavior as before.                       |
| Shared NixOS modules             | Yes       | Consume repository helpers through a named module argument.                 |
| Shared Home Manager modules      | Yes       | Consume repository and Home Manager helpers through named arguments.        |
| Developer shell or agent tooling | No        | No change.                                                                  |
| CI, caching, or verification     | Yes       | Module discovery expectations reflect the reorganized package module.       |

## User Scenarios & Testing _(mandatory)_

Treat the operator, configured user, and downstream project as the relevant users. Each
story represents an independently verifiable configuration outcome.

### User Story 1 - Keep Module Interfaces Compatible (Priority: P1)

As a maintainer, I want standard NixOS and Home Manager modules to receive the normal
Nixpkgs library so upstream modules remain interoperable with this configuration.

**Why this priority**: The standard module argument is a shared interface relied on by
all imported modules.

**Independent Test**: Evaluate both host configurations and their generated Home Manager
configurations, then build both host outputs.

**Acceptance Scenarios**:

1. **Given** either supported host, **When** its modules are evaluated, **Then** the
   module-system `lib` remains the Nixpkgs library and project helpers remain available
   under named custom arguments.
2. **Given** Home Manager activation modules, **When** they are evaluated, **Then** the
   activation DAG helper remains available without replacing `lib`.

### User Story 2 - Make Configuration Ownership Obvious (Priority: P2)

As a maintainer, I want long native-format configuration and developer packages grouped
by purpose so I can make changes without navigating unrelated settings.

**Why this priority**: Clear ownership makes routine changes easier to review and less
likely to alter unrelated behavior.

**Independent Test**: The generated Niri and Hypridle files remain byte-equivalent in
behavior, package closures remain unchanged, and the exact discovered module list matches
the reorganized tree.

**Acceptance Scenarios**:

1. **Given** the shared Niri configuration, **When** a maintainer edits it, **Then** the
   compositor configuration is stored in a KDL source file and host output configuration
   remains in its existing position in the generated file.
2. **Given** common utilities and developer toolchains, **When** Home Manager modules are
   reviewed, **Then** these package groups have clear, separate ownership while both hosts
   retain the same installed packages.
3. **Given** unit and configuration test outputs, **When** the flake is evaluated,
   **Then** each shared test derivation is defined once and exposed through both existing
   output paths.

### Edge Cases

- Both supported hosts must still evaluate if a GUI or WSL-specific Home Manager feature
  is disabled.
- The package split must not change GUI-only package conditions or the WSL package set.
- Repository helpers needed while resolving imports must remain available at import time.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The module system MUST retain its standard Nixpkgs `lib` argument.
- **FR-002**: Repository-specific and Home Manager-specific helpers MUST be passed under
  named custom arguments and remain available to every module that uses them.
- **FR-003**: Niri configuration MUST be stored in a KDL source file while host-owned
  output configuration remains host-scoped and is included in the generated file.
- **FR-004**: Common utilities and developer toolchains MUST have separate module
  ownership without changing either host's resulting package set.
- **FR-005**: The unit-test and configuration-test derivations MUST be shared by their
  package and check outputs rather than independently declared twice.
- **FR-006**: Automatic module discovery MUST remain deterministic and its exact-list test
  MUST describe the updated module tree.

### Invariants

- **INV-001**: Both supported host configurations and Home Manager layers MUST preserve
  their current options, packages, and generated runtime configuration.
- **INV-002**: Host-specific hardware, WSL, display, and filesystem decisions MUST remain
  in `systems/`.
- **INV-003**: State versions and the existing backup policy MUST remain unchanged.

### Security and State

- **SEC-001**: No privilege, credential, trust, or unfree-package policy changes are in
  scope.
- **STATE-001**: No persistent-state migration or state-version change is in scope.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: Both host outputs evaluate and build with standard module-library semantics.
- **SC-002**: The Home Manager generated Niri output contains the shared KDL settings and
  the host-specific output block; GUI and WSL package conditions remain unchanged.
- **SC-003**: The exact-list module discovery assertion passes for the reorganized tree.
- **SC-004**: The formatting check and repository Spec Kit validation pass.

## Current-System Impact _(mandatory)_

Identify claims in `.specify/memory/current-system.md` that will change after successful
implementation. Write `None` only when the feature has no effect on implemented
architecture, capability status, supported workflows, policies, verification, or known
limitations.

- **Claims to update**: Architecture description of the extended Nixpkgs library passed
  through `specialArgs`; module ownership description if it names utility groupings.
- **Limitations resolved or introduced**: None.

## Assumptions

- The approved cleanup is behavior-preserving and does not include the separately
  documented Home Manager backup-retention limitation.
- Existing package and generated-file assertions are sufficient when supplemented with
  module discovery and host build checks.
