# Feature Specification: Root Flake Layout

**Feature Directory**: `009-root-flake-layout`

**Created**: 2026-09-09

**Status**: Draft

**Input**: "Lift the Nix configuration from the `nix/` subdirectory to the public GitHub repository root while preserving the root README and fixing the Actionlint source-boundary problem."

## Intent and Scope _(mandatory)_

### Problem

The repository's configuration entrypoint is nested under `nix/`, while GitHub workflows
must remain under the repository-root `.github/` directory. The Actionlint check reaches
outside its flake directory to lint those workflows. This works only when Nix recognizes
the checkout as a Git source containing the parent directory; an explicit path-based flake
source cannot access the workflows and emits a misleading purity error. The nested layout
also forces contributors and CI to use special `./nix` and `dir=nix` paths.

### Desired Outcome

The repository root is the single configuration and verification boundary. The public
profile README, license, and GitHub metadata remain at the root alongside the flake.
Developers and CI can use root-relative commands, and Actionlint validates the root
workflows during pure Git-based and path-based flake evaluation.

### Out of Scope

- Changing host configuration behavior, package selections, credentials, trust, caches,
  state versions, or supported targets.
- Rewriting the public profile README beyond path corrections required by the migration.
- Changing workflow behavior except for paths that identify the relocated flake and tools.

## Affected Targets _(mandatory)_

| Target or layer                  | Affected? | Expected observable change                                                             |
| -------------------------------- | --------- | -------------------------------------------------------------------------------------- |
| `nixos` host                     | No        | The evaluated host remains equivalent.                                                 |
| `nixos-wsl` host                 | No        | The evaluated host remains equivalent.                                                 |
| Shared NixOS modules             | No        | Module behavior remains equivalent after relocation.                                   |
| Shared Home Manager modules      | No        | Home configuration remains equivalent after relocation.                                |
| Developer shell or agent tooling | Yes       | Root-level development commands and discovery paths replace `nix/`-prefixed paths.     |
| CI, caching, or verification     | Yes       | CI and checks operate from the repository root; Actionlint stays pure for path inputs. |

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Use the repository root as the flake (Priority: P1)

A contributor can clone the public repository and run supported Nix commands from its
root without knowing about a nested configuration directory.

**Why this priority**: A single source boundary removes the cause of the Actionlint purity
failure and simplifies every supported entrypoint.

**Independent Test**: From the repository root, evaluate the flake and build its Actionlint
check both as the ordinary checkout and as an explicit path input without `--impure`.

**Acceptance Scenarios**:

1. **Given** a repository checkout, **When** a contributor runs the documented root-level
   check commands, **Then** Nix finds the flake and completes pure evaluation.
2. **Given** an explicit path-based flake input, **When** the Actionlint check is built,
   **Then** both root workflow files are linted without accessing a parent source boundary.

### User Story 2 - Preserve public profile presentation and system behavior (Priority: P2)

Repository visitors continue to see the existing profile README, while operators retain
the same supported NixOS and Home Manager configurations.

**Why this priority**: Layout cleanup must not compromise the repository's public-facing
purpose or silently change deployed systems.

**Independent Test**: Confirm the root README and license remain tracked, then run the
quick tests and evaluate/build both supported hosts from the root flake.

**Acceptance Scenarios**:

1. **Given** the migrated repository, **When** GitHub renders its landing page, **Then** the
   existing root README remains the profile document.
2. **Given** the migrated root flake, **When** supported host outputs and configuration
   tests are evaluated, **Then** both hosts and their declared behavior remain available.

### Edge Cases

- An explicit `path:.` input must include `.github/workflows` and lint it purely.
- Generated or ignored runtime artifacts under `nix/` must not be promoted as tracked
  configuration or overwrite root-local tooling state.
- Root and nested ignore rules or tool configuration must be merged without losing either
  repository-wide exclusions or relevant declarative settings.
- Historical completed feature records may retain old command examples as historical
  evidence; canonical current-system documentation must describe only the new layout.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The repository root MUST contain the configuration entrypoint and dependency lock.
- **FR-002**: The existing root `README.md`, `LICENSE`, `.github/`, and repository metadata
  MUST remain available at the repository root.
- **FR-003**: Supported development, formatting, linting, and build commands MUST operate
  from the repository root without a `nix/` path prefix.
- **FR-004**: Actionlint MUST validate every repository-root GitHub workflow using a source
  contained within the flake boundary.
- **FR-005**: The Actionlint check MUST evaluate and build without `--impure` for both the
  normal Git checkout and an explicit path-based flake source.
- **FR-006**: CI and dependency-update workflows MUST target the relocated root flake.
- **FR-007**: Tracked configuration formerly under `nix/` MUST be relocated without loss;
  ignored generated artifacts MUST not be unintentionally added.
- **FR-008**: Both supported host outputs and the existing verification outputs MUST remain
  exposed after relocation.
- **FR-009**: Canonical project instructions and current-system documentation MUST describe
  the root layout and root-level commands.

### Invariants

- **INV-001**: The public profile README remains the repository landing-page document.
- **INV-002**: Host behavior, shared module boundaries, cache policy, trust policy, unfree
  policy, security boundaries, and state versions remain unchanged.
- **INV-003**: Historical completed feature artifacts remain historical records except for
  this feature's new artifacts.
- **INV-004**: Flake inputs remain locked and persistent dependencies remain declarative.

### Security and State

- **SEC-001**: No credential, privilege, trusted-user, cache-authority, secret-handling, or
  unfree-package policy changes are authorized.
- **STATE-001**: No persistent-state migration or state-version change is authorized; rollback
  consists of restoring the prior directory layout and path references.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: One root-level command builds the Actionlint check against all two tracked
  workflow files with zero lint errors and no impurity allowance.
- **SC-002**: Explicit path-based evaluation builds the same Actionlint check without
  `--impure` and without an out-of-boundary path error.
- **SC-003**: Formatting, unit, configuration, and both supported host evaluations/builds
  remain successful from the root entrypoint.
- **SC-004**: A repository search finds zero active CI, developer-hook, canonical instruction,
  or current-system commands that require `./nix` or `dir=nix`.
- **SC-005**: The original root README and license remain tracked and unchanged in purpose.

## Current-System Impact _(mandatory)_

- **Claims to update**: Architecture entrypoint and paths; maintenance commands; verification
  workflow; CI flake paths; agent-tooling discovery locations.
- **Limitations resolved or introduced**: Resolve the implicit limitation that Actionlint's
  flake check depends on Git-aware inclusion of a directory outside the nested flake root.

## Assumptions

- The repository is primarily the public profile plus this Nix configuration, so a root flake
  is the smallest coherent long-term layout.
- GitHub continues to render a root `README.md` regardless of other root-level files.
- Root `.github/` placement remains mandatory for GitHub workflow discovery.
