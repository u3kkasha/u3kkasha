# Implementation Plan: Persist Headroom Savings

**Feature Directory**: `010-persist-headroom-savings` | **Date**: 2026-09-09 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/010-persist-headroom-savings/spec.md`

Read the specification, `.specify/memory/constitution.md`, and
`.specify/memory/current-system.md` before filling this plan.

## Summary

Keep the `codex-headroom` proxy's workspace temporary while selecting Headroom's
savings-event ledger in the existing user-scoped XDG Headroom data directory. Declare the
same per-resource path for interactive shells and explicitly in the launcher, share the
single append-only ledger with the MCP integration, assert the generated configuration's
state split, and verify Headroom can aggregate events after temporary state is removed.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both (`nixos`, `nixos-wsl`)

**Affected layers**: shared Home Manager module, configuration tests, Headroom integration
tests, current-system memory

**Inputs/packages/options**: pinned `headroom-src` v0.36.0;
`internal.headroom.enable`; `HEADROOM_WORKSPACE_DIR`;
`HEADROOM_SAVINGS_EVENTS_PATH`; `xdg.dataHome`

**State or migration impact**: New compression events from wrapped Codex sessions persist
in the existing XDG Headroom data directory for Headroom's 30-day maximum ledger retention.
No prior deleted events are recoverable and no existing state requires migration.

**Security impact**: No privilege, credential, trust, secret, socket, or unfree-policy
change. The ledger is user-owned local accounting metadata; external telemetry and
subscription tracking stay disabled.

**Rollback**: Activate the previous Home Manager/NixOS generation or revert the ledger-path
override. Existing user-owned ledger data may be left in place or removed manually with
`headroom savings --reset` under the matching workspace path.

**Constraints**: Preserve pure evaluation, avoid a persistent proxy service, retain
per-session memory/config/log cleanup, use Headroom's supported path override, and do not
add runtime dependencies or model downloads.

## Constitution Check

_GATE: Must pass before design and be re-checked after the design is complete._

| Principle                           | Evidence of compliance                                               | Status |
| ----------------------------------- | -------------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | Home Manager owns the launcher and XDG path; Headroom remains pinned | PASS   |
| Shared modules and host boundaries  | Shared wrapper behavior is identical on both configured hosts        | PASS   |
| State compatibility                 | Additive ledger retention; no state-version or migration change      | PASS   |
| Explicit security boundaries        | User-scoped local ledger only; telemetry controls unchanged          | PASS   |
| Verification follows impact         | Formatting, configuration, and Headroom integration checks mapped    | PASS   |
| Current-system memory               | Wrapper state-retention claim identified for reconciliation          | PASS   |
| Smallest coherent design            | One supported per-resource override; no persistent proxy/workspace   | PASS   |

## Current and Target Design

### Current

`modules/home/headroom.nix` starts the opt-in proxy with
`HEADROOM_WORKSPACE_DIR` and `HEADROOM_CONFIG_DIR` under a new temporary directory. Its
cleanup trap removes that directory, including `savings_events.jsonl`. `modules/home/mcp.nix`
independently uses `${config.xdg.dataHome}/headroom` as its persistent workspace. The
"Home Manager and Agent Tooling" current-system section currently describes the wrapper as
removing all temporary state at exit.

### Target

Define the persistent Headroom data path once in the wrapper module. Declare its
`savings_events.jsonl` file as the user session's per-resource ledger path so ordinary
`headroom savings` reads the unified history, and explicitly export the same value inside
the launcher so wrapper correctness does not depend on its caller's environment. All other
proxy resources continue to derive from the temporary workspace/config roots and are
deleted by the existing trap. The MCP server and proxy therefore append to the same
file-locked ledger.

### Decision Rationale

Persisting the entire proxy workspace was rejected because it would retain memory, logs,
caches, and configuration beyond the wrapper's isolation contract. A second wrapper-only
ledger was rejected because it would fragment reporting. A global workspace override was
rejected because it would broaden unrelated Headroom CLI state. The dedicated session
variable plus the launcher's matching explicit export affects only savings accounting and
keeps reporting usable through the standard CLI.

## Repository Touchpoints

```text
modules/home/headroom.nix
tests/configuration.nix
tests/headroom.nix
.specify/memory/current-system.md
specs/010-persist-headroom-savings/
```

## Verification Matrix _(mandatory)_

| Requirement/story     | Target                              | Verification command or observation                    | Local/CI     |
| --------------------- | ----------------------------------- | ------------------------------------------------------ | ------------ |
| FR-001, FR-002 / US1  | Home Manager launcher on both hosts | `nix build .#configuration-tests --no-link`            | Local/CI     |
| FR-003, FR-005 / US1  | Headroom ledger behavior            | `nix build .#headroom-tests --no-link`                 | Local/CI     |
| FR-004 / US2          | Launcher cleanup boundary           | `nix build .#configuration-tests --no-link`            | Local/CI     |
| INV-001–INV-004 / US2 | Both host configurations            | `nix build .#configuration-tests --no-link`            | Local/CI     |
| Nix formatting        | Repository                          | `nix build .#checks.x86_64-linux.formatting --no-link` | Local/CI     |
| Host composition      | `nixos`, `nixos-wsl`                | `nix build .#nixos-build .#nixos-wsl-build --no-link`  | CI/delegated |

## Delivery and Recovery

1. Add the explicit persistent savings-ledger override without changing the temporary
   workspace roots or cleanup trap.
2. Add launcher-content assertions and a ledger persistence/aggregation integration test,
   then run formatting and relevant builds.
3. Reconcile current-system memory and activate through the normal NixOS or Home Manager
   workflow. Roll back to the previous generation if needed; prior ledger lines remain
   harmless user-owned state.

## Current-System Reconciliation

After implementation, update only the claims proven to have changed:

- Update the Headroom wrapper architecture claim to say that only savings accounting is
  persistent and shared with the MCP integration.
- Preserve the existing telemetry, routing, loopback, temporary-workspace, and verification
  claims.

The mandatory `speckit.system-memory.sync` hook performs this reconciliation and records
the result in the feature tasks.

## Complexity Tracking

> Fill only for justified constitution violations or deliberately retained complexity.

No constitution violations or deliberately retained complexity.
