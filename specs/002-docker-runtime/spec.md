# Feature Specification: Docker Runtime

**Feature Directory**: `002-docker-runtime`

**Created**: 2026-08-13

**Status**: Draft

**Input**: "Replace Podman completely with conventional rootful Docker, preserving hassle-free Docker Compose and container use."

## Intent and Scope

### Problem

The supported hosts currently provide Podman and emulate Docker CLI behavior. The operator
instead requires the actual Docker engine and Compose workflow on both hosts.

### Desired Outcome

Both supported hosts provide conventional rootful Docker, the configured user can run
`docker` and `docker compose` without `sudo`, and no Podman service, package, option, socket,
or group membership remains enabled.

### Out of Scope

- Rootless Docker.
- Preserving Podman compatibility or Podman-managed container state.
- Migrating existing Podman images, containers, or volumes automatically.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                               |
| -------------------------------- | --------- | -------------------------------------------------------- |
| `nixos` host                     | Yes       | Uses Docker and grants the configured user Docker access |
| `nixos-wsl` host                 | Yes       | Uses Docker and grants the configured user Docker access |
| Shared NixOS modules             | Yes       | Docker replaces the Podman module and group policy       |
| Shared Home Manager modules      | No        | N/A                                                      |
| Developer shell or agent tooling | No        | N/A                                                      |
| CI, caching, or verification     | Yes       | Assertions and VM tests validate Docker and Compose      |

## User Scenarios & Testing

### User Story 1 - Run Docker Workloads Directly (Priority: P1)

As the configured user, I can run ordinary Docker and Compose workloads without `sudo` or
a Podman compatibility layer.

**Why this priority**: This is the operator-selected container runtime and daily workflow.

**Independent Test**: Both host evaluations select Docker, exclude Podman, and the VM tests
successfully invoke `docker`, `docker compose`, and the Docker daemon.

**Acceptance Scenarios**:

1. **Given** either supported host, **When** its configuration is evaluated, **Then** Docker
   is enabled, Podman is disabled or absent, and the configured user belongs to `docker` but
   not `podman`.
2. **Given** a booted VM test, **When** the configured user invokes Docker and Compose,
   **Then** both commands use the Docker engine successfully.

### Edge Cases

- Existing Podman images, containers, and volumes are not visible to Docker and require
  manual migration if the operator later needs them.
- Docker group membership is intentionally root-equivalent and is accepted for compatibility.

## Requirements

### Functional Requirements

- **FR-001**: Both supported hosts MUST enable conventional rootful Docker.
- **FR-002**: The configured user MUST be able to use Docker without `sudo` through `docker`
  group membership.
- **FR-003**: Docker Compose v2 behavior MUST be available through `docker compose`.
- **FR-004**: Podman packages, services, compatibility links, sockets, and group membership
  MUST be removed from the supported host configurations.

### Invariants

- **INV-001**: Both `nixos` and `nixos-wsl` MUST remain supported and buildable.
- **INV-002**: System and Home Manager state versions MUST remain unchanged.

### Security and State

- **SEC-001**: Membership in the rootful Docker `docker` group is an explicitly accepted,
  tested root-equivalent privilege boundary.
- **STATE-001**: Podman runtime state is not migrated; rollback uses the previous NixOS
  generation and any needed container data migration remains manual.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Focused assertions pass for Docker enabled, Compose available, Podman absent,
  and exact container group membership on both hosts.
- **SC-002**: Both host builds succeed without changing either state version.
- **SC-003**: Both VM test derivations exercise Docker CLI behavior; full execution may be
  delegated to CI when local resources are insufficient.

## Current-System Impact

- **Claims to update**: Capability Status, Architecture host ownership, Configuration,
  Caching, and Trust, Maintenance and Verification.
- **Limitations resolved or introduced**: Removes the Podman socket limitation and introduces
  the explicitly accepted root-equivalent Docker daemon/group boundary.

## Assumptions

- Ease of compatibility takes precedence over the stronger isolation of rootless Docker.
- The pinned NixOS Docker module supplies the Docker CLI and Compose plugin.
