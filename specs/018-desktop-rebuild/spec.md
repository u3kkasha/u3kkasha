# Feature Specification: Bare-Metal Desktop Rebuild

**Feature Directory**: `018-desktop-rebuild`

**Created**: 2026-10-10

**Status**: Draft

**Input**: "Rebuild the bare-metal NixOS desktop around niri-flake and Noctalia with both project binary caches, while retaining Docker, gaming, development tooling, MCP and agent infrastructure, WSL support, and removing desktop-unrelated user CLI tools such as yazi, Codex, and OpenCode."

Before completing this specification, read `.specify/memory/constitution.md` and
`.specify/memory/current-system.md`. Describe desired behavior, not implementation.

## Intent and Scope _(mandatory)_

### Problem

The bare-metal desktop mixes a hand-written Niri KDL configuration, a separately installed
Noctalia package, and Home Manager-managed Noctalia settings. The desktop is visually
under-curated and its compositor/shell package ownership is unnecessarily duplicated.

### Desired Outcome

The bare-metal `nixos` host provides a cohesive, lean, declarative Niri desktop using the
Nix-native `niri-flake` module and the Noctalia flake package, with both upstream binary
caches configured. Noctalia is owned by Home Manager and Niri configuration is validated at
evaluation/build time, while all existing CLI, agent, Docker, gaming, development, MCP, and
WSL capabilities remain available where they are in scope.

### Out of Scope

- Replacing or enabling a graphical desktop on `nixos-wsl`.
- Removing any existing CLI or agent tools, including Yazi, Codex, or OpenCode.
- Changing system or Home Manager state versions.
- Adding DankMaterialShell or Stylix.

## Affected Targets _(mandatory)_

| Target or layer                  | Affected? | Expected observable change                                                      |
| -------------------------------- | --------- | ------------------------------------------------------------------------------- |
| `nixos` host                     | Yes       | Receives the rebuilt Niri/Noctalia desktop.                                     |
| `nixos-wsl` host                 | Yes       | Remains non-graphical and keeps WSL behavior.                                   |
| Shared NixOS modules             | Yes       | Desktop/cache ownership is simplified without widening desktop scope.           |
| Shared Home Manager modules      | Yes       | Unwanted CLI/agent modules are removed; retained shared tooling remains usable. |
| Developer shell or agent tooling | Yes       | Existing repository/dev and user tooling remains available.                     |
| CI, caching, or verification     | Yes       | Cache hints and host-specific assertions/builds are updated.                    |

## User Scenarios & Testing _(mandatory)_

Treat the operator, configured user, and downstream project as the relevant users. Each
story represents an independently verifiable configuration outcome.

### User Story 1 - Cohesive Bare-Metal Desktop (Priority: P1)

As the configured bare-metal user, I want a polished Niri desktop managed by NixOS and
Home Manager so that the compositor, shell, wallpaper, launcher, and desktop utilities
are reproducible and visually coherent.

**Why this priority**: This is the primary reason for the change.

**Independent Test**: Evaluate and build `nixosConfigurations.nixos`, inspect the generated
Niri and Noctalia configuration, and confirm the host uses the Niri and Noctalia project
packages with their configured caches.

**Acceptance Scenarios**:

1. **Given** the bare-metal host, **When** its configuration is evaluated, **Then** the
   Niri module and Noctalia Home Manager module are enabled without conflicting duplicate
   package ownership.
2. **Given** a valid flake evaluation, **When** the host is built, **Then** Niri config
   validation and Noctalia config validation complete successfully.

### User Story 2 - Preserve Existing User Tooling (Priority: P2)

As the configured user, I want the desktop rebuild to leave my existing CLI and agent
tooling available while retaining system and repository infrastructure that I use.

**Why this priority**: A desktop redesign must not silently remove established workflows.

**Independent Test**: Configuration assertions show existing CLI/agent applications and
retained capabilities remain enabled on their supported hosts.

**Acceptance Scenarios**:

1. **Given** the bare-metal and WSL compositions, **When** both are evaluated, **Then** WSL
   remains headless and existing shared infrastructure remains present.
2. **Given** the configured user profile, **When** its package/module closure is inspected,
   **Then** Yazi, Codex, OpenCode, and other existing CLI/agent tools remain available.

### Edge Cases

- The `nixos-wsl` host must not inherit graphical Niri/Noctalia settings or GUI-only
  packages through shared Home Manager defaults.
- A project cache miss must remain safe: Nix may build the pinned package locally.
- Runtime Noctalia state remains user-owned/generated and must not be edited in place.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The bare-metal host MUST use the Nix-native `niri-flake` module/package path
  with build-time configuration validation.
- **FR-002**: The bare-metal host MUST use the Noctalia project package through Home Manager
  and MUST retain the Noctalia Cachix bootstrap configuration.
- **FR-003**: The configuration MUST add the Niri project cache bootstrap configuration when
  the selected `niri-flake` package provides one.
- **FR-004**: Noctalia MUST have one declarative package owner for the bare-metal user;
  duplicate system-package installation MUST be removed.
- **FR-005**: Existing user CLI/agent applications, including Yazi, Codex, and OpenCode,
  MUST remain available after the desktop rebuild.
- **FR-006**: The `nixos-wsl` host MUST remain GUI-disabled and MUST not import the bare-metal
  host's physical output or desktop-only configuration.

### Invariants

- **INV-001**: `systemStateVersion` and `homeStateVersion` remain unchanged.
- **INV-002**: Host-specific display identity remains owned by `systems/x86_64-linux/nixos`.
- **INV-003**: Shared module discovery remains deterministic and its exact-list tests remain
  synchronized with any module changes.

### Security and State

- **SEC-001**: No new privilege, credential, trust, secret, socket, or unfree-package
  boundary is introduced.
- **STATE-001**: No state-version migration is introduced; rollback is the previous NixOS
  generation, with existing Noctalia runtime state preserved.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: `nix build .#nixos-build --no-link` succeeds and generated Niri/Noctalia
  configuration is validated.
- **SC-002**: `nix build .#nixos-wsl-build .#configuration-tests --no-link` succeeds with
  GUI-disabled WSL assertions intact.
- **SC-003**: The final desktop package/module set retains existing CLI/agent applications
  and declared Docker, gaming, development, MCP, and WSL capabilities.

## Current-System Impact _(mandatory)_

Identify claims in `.specify/memory/current-system.md` that will change after successful
implementation. Write `None` only when the feature has no effect on implemented
architecture, capability status, supported workflows, policies, verification, or known
limitations.

- **Claims to update**: Architecture, caching, and maintenance/verification sections
  describing the desktop package/module ownership.
- **Limitations resolved or introduced**: The current hand-written Niri/Noctalia ownership
  split is resolved; no CLI or agent tooling limitation is introduced.

## Assumptions

- The current locked nixpkgs and project inputs are retained unless a package/module conflict
  requires a narrowly scoped lock update.
- The Niri project cache is used only if the selected `niri-flake` revision documents a valid
  cache and public key; cache misses remain valid local builds.
- Existing CLI and agent applications are explicitly retained; this feature does not perform
  user-profile pruning.
