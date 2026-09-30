# Feature Specification: Replace Flox with devenv

**Feature Directory**: `014-flox-to-devenv`

**Created**: 2026-09-30

**Status**: Approved for implementation

**Input**: "Remove the commits which added Flox and add devenv as a Home Manager package."

## Intent and Scope

### Problem

The configured user has decided to use devenv as the developer environment CLI. Flox was
introduced by three local-only commits, but that integration is not part of the desired
system configuration.

### Desired Outcome

The configured user can run devenv on both supported hosts through Home Manager. The
three Flox commits are absent from branch history, and no Flox configuration remains.

### Out of Scope

- Replacing the repository's existing flake development shell.
- Configuring project-specific devenv environments or services.
- Installing or enabling FloxHub integrations.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                                                            |
| -------------------------------- | --------- | ------------------------------------------------------------------------------------- |
| `nixos` host                     | Yes       | devenv is available to the configured user.                                           |
| `nixos-wsl` host                 | Yes       | devenv is available to the configured user.                                           |
| Shared NixOS modules             | No        | N/A                                                                                   |
| Shared Home Manager modules      | Yes       | devenv replaces Flox in the CLI package set.                                          |
| Developer shell or agent tooling | No        | Existing flake development shell remains in use.                                      |
| CI, caching, or verification     | Yes       | Flox cache trust and input are removed; host evaluations verify package availability. |

## User Scenarios & Testing

### User Story 1 - Use devenv from either configured host (Priority: P1)

The configured user can invoke devenv after Home Manager activates on either supported
host, without separately installing it.

**Why this priority**: This is the requested replacement for the Flox CLI.

**Independent Test**: Evaluate Home Manager package lists for both hosts and confirm they
contain devenv and no Flox package.

**Acceptance Scenarios**:

1. **Given** either supported host, **When** its Home Manager configuration is evaluated,
   **Then** the configured CLI package set includes devenv.
2. **Given** the shared CLI configuration is enabled, **When** its package set is
   evaluated, **Then** it no longer includes Flox.

### Edge Cases

- The package remains conditional on the existing shared CLI module being enabled.
- A host with no cache hit can still obtain devenv through its normal Nix build path.

## Requirements

### Functional Requirements

- **FR-001**: Shared Home Manager MUST install devenv from the repository's locked nixpkgs
  input for both supported hosts.
- **FR-002**: The flake MUST NOT contain a Flox input or Flox-specific cache trust settings.
- **FR-003**: The public tool list MUST identify devenv in place of Flox.
- **FR-004**: The existing repository development shell MUST remain unchanged.
- **FR-005**: The repository formatter MUST exclude `.serena/**` so it does not rewrite
  Serena-owned configuration.

### Invariants

- **INV-001**: Shared Home Manager behavior remains host-neutral and applies to both hosts.
- **INV-002**: The remaining cache keys and substituters stay synchronized between flake
  bootstrap settings and the internal cache projection.

### Security and State

- **SEC-001**: No Flox-specific trusted cache keys remain; add no new trusted keys or
  credentials.
- **STATE-001**: No persistent state or compatibility version changes are required.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Both host configurations evaluate with devenv present in the configured
  user's package set and Flox absent.
- **SC-002**: The flake has no Flox input, Flox cache URL, or Flox cache key, and the
  existing default development shell definition remains unchanged.
- **SC-003**: The repository-wide formatting check passes without changing
  `.serena/project.yml`.

## Current-System Impact

- **Claims to update**: Home Manager and Agent Tooling section: shared user tooling now
  includes devenv; Local Developer Workflow row: treefmt excludes Serena-owned files.
- **Limitations resolved or introduced**: The global development environment CLI changes
  from Flox to devenv. Project environments remain unconfigured.

## Assumptions

- `pkgs.devenv` from the flake's existing locked nixpkgs input is the intended package.
- "Remove the commits" means rewrite the three local-only Flox commits, which were not on
  `origin/main`; unrelated working-tree changes must be preserved.
