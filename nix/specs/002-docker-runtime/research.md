# Research: Docker Runtime

## Decision: Conventional rootful Docker

**Rationale**: The operator prioritizes hassle-free Docker Compose and broad container
compatibility and explicitly accepts the root-equivalent `docker` group boundary.

**Alternatives considered**: Rootless Docker was rejected due to added constraints around
privileged ports, devices, networking, per-user daemon lifecycle, and some resource controls.

## Decision: No automatic Podman-state migration

**Rationale**: Docker and Podman maintain distinct state. Automatic mutation would exceed
declarative ownership and create data-loss risk.

**Alternatives considered**: Export/import automation was rejected as workload-specific.
