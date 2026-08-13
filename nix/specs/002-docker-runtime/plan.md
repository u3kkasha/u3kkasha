# Implementation Plan: Docker Runtime

**Feature Directory**: `002-docker-runtime` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary

Replace the discovered shared Podman module with a Docker module, enable conventional
rootful Docker on both supported hosts, grant the configured user `docker` group access,
and validate Docker Engine plus Compose while excluding Podman.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both

**Affected layers**: shared NixOS, host composition, unit/generated checks, VM tests

**Inputs/packages/options**: pinned nixpkgs; `virtualisation.docker.enable`, Docker Compose v2

**State or migration impact**: Docker uses separate runtime state; Podman state is not migrated

**Security impact**: rootful daemon and `docker` group are an accepted root-equivalent boundary

**Rollback**: boot the previous generation; manually migrate container data if needed

**Constraints**: remove the discovered Podman module and update its exact-list test; keep both state versions

## Constitution Check

| Principle                           | Evidence of compliance                                            | Status |
| ----------------------------------- | ----------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | NixOS module owns Docker                                          | PASS   |
| Shared modules and host boundaries  | Runtime policy is shared; discovery list updated                  | PASS   |
| State compatibility                 | No state-version change; manual runtime-state boundary documented | PASS   |
| Explicit security boundaries        | Root-equivalent Docker group explicitly accepted and tested       | PASS   |
| Verification follows impact         | Assertions, both builds, both VM tests                            | PASS   |
| Current-system memory               | Container capability and security claims reconciled               | PASS   |
| Smallest coherent design            | Replace one runtime module without compatibility layers           | PASS   |

## Current and Target Design

### Current

`modules/nixos/podman/default.nix` enables Podman, its Docker CLI compatibility link and
root-equivalent socket; `modules/nixos/system/default.nix` grants `podman` group membership.

### Target

`modules/nixos/docker/default.nix` enables rootful Docker. Both hosts enable the internal
Docker module. The system module grants `docker` group membership only when Docker is enabled.

### Decision Rationale

Rootless Docker reduces privilege but adds compatibility constraints. The operator explicitly
selected conventional rootful Docker for the least-friction Compose and container workflow.

## Repository Touchpoints

```text
modules/nixos/podman/default.nix (remove)
modules/nixos/docker/default.nix (add)
modules/nixos/system/default.nix
systems/x86_64-linux/nixos/default.nix
systems/x86_64-linux/nixos-wsl/default.nix
tests/unit.nix
tests/vm-nixos.nix
tests/vm-wsl-mock.nix
.specify/memory/current-system.md
```

## Verification Matrix

| Requirement/story    | Target     | Verification command or observation                   | Local/CI             |
| -------------------- | ---------- | ----------------------------------------------------- | -------------------- |
| FR-001..FR-004 / US1 | both hosts | generated configuration checks                        | Local                |
| FR-003               | VM tests   | `docker compose version` and daemon check             | CI/local if feasible |
| INV-001              | both hosts | `nix build .#nixos-build .#nixos-wsl-build --no-link` | Local                |
| INV-002              | both hosts | focused state-version assertions                      | Local                |

## Delivery and Recovery

1. Add failing Docker/Podman/group/discovery assertions.
2. Replace the module and host flags, then update VM runtime checks.
3. Build both hosts; boot a new generation only after evaluation succeeds.
4. Roll back to the previous NixOS generation if Docker disrupts workloads; Podman data is untouched but not migrated.

## Current-System Reconciliation

- Replace Podman capability and architecture claims with Docker.
- Record the accepted Docker group boundary and remove the Podman socket limitation.

## Complexity Tracking

| Complexity                   | Why required                             | Simpler alternative rejected because                           |
| ---------------------------- | ---------------------------------------- | -------------------------------------------------------------- |
| Root-equivalent Docker group | Compatibility-first operator requirement | Rootless Docker may impede privileged/network/device workloads |
