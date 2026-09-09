# Implementation Plan: Root Flake Layout

**Feature Directory**: `009-root-flake-layout` | **Date**: 2026-09-09 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/009-root-flake-layout/spec.md`

## Summary

Relocate every tracked configuration artifact from `nix/` to the Git repository root,
preserving the existing root README, license, GitHub metadata, and repository ignore rules.
Make the root the flake and project-tooling boundary, update CI and developer commands, and
change Actionlint to consume `.github/workflows` from within that boundary. Do not promote
ignored runtime artifacts or change evaluated host behavior.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: both (`nixos`, `nixos-wsl`) for regression verification only

**Affected layers**: flake layout, developer shell, agent tooling, tests, CI, documentation

**Inputs/packages/options**: Existing locked inputs and `pkgs.actionlint`; no dependency changes

**State or migration impact**: No deployed state or state-version change; local ignored tool
state stays untracked and is not part of the configuration migration

**Security impact**: None; credentials, privileges, trust, secrets, sockets, and unfree policy
remain unchanged

**Rollback**: Revert the relocation and path-reference changes as one commit; no activated host
generation or persistent state needs recovery

**Constraints**: Root `README.md`, `LICENSE`, `.github/`, and `.gitignore` must be preserved;
GitHub workflows must remain under root `.github/workflows`; pure `path:.` evaluation must work;
historical completed specs remain unchanged; file moves must preserve history where practical

## Constitution Check

_GATE: Passed before design and re-checked after design._

| Principle                           | Evidence of compliance                                                                                                             | Status |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | All configuration and locked inputs remain tracked under one root flake; no runtime resolver is added.                             | PASS   |
| Shared modules and host boundaries  | Module and host directory contents are relocated without changing their boundaries or discovery lists.                             | PASS   |
| State compatibility                 | No state option, format, or state version changes.                                                                                 | PASS   |
| Explicit security boundaries        | No privilege, credential, secret, trust, socket, or unfree-policy changes.                                                         | PASS   |
| Verification follows impact         | Pure Git/path Actionlint checks, formatting, governance, unit/configuration tests, and both host builds cover the affected layers. | PASS   |
| Current-system memory               | Architecture, tooling paths, commands, and the resolved purity limitation are identified for reconciliation.                       | PASS   |
| Smallest coherent design            | One root boundary removes special path handling instead of adding another source input or duplicating workflows.                   | PASS   |

Post-design review: all gates remain PASS. The design introduces no new abstraction,
dependency, security boundary, state migration, or host-specific behavior.

## Current and Target Design

### Current

The Git repository root owns `README.md`, `LICENSE`, `.gitignore`, and `.github/`. The Nix
flake, modules, tests, Spec Kit memory, and agent configuration are nested under `nix/`.
CI invokes `./nix`, the lock updater declares `path-to-flake-dir: nix`, and the Actionlint
derivation uses `../.github/workflows`. Git-aware flake resolution includes the repository
parent, but `path:./nix` copies only the nested directory and cannot resolve that path purely.

### Target

The tracked contents of `nix/` live directly at the Git repository root. The existing public
README, license, GitHub metadata, and root ignore rules remain. The nested directory is gone.
The flake uses `./.github/workflows`; CI and hooks invoke `.`; the dependency updater uses its
default root flake; `.envrc`, `AGENTS.md`, `.specify/`, and agent configuration are root-local.

Root and nested ignore rules are merged. Ignored `.direnv`, result links, CodeGraph databases,
Serena caches/local files, generated hook links, and extension caches are not migrated as
tracked source. Existing root-local runtime state may remain ignored but is not authoritative.

### Decision Rationale

A root flake matches the actual repository ownership boundary and GitHub's fixed workflow
location. It makes ordinary and explicit path inputs equivalent and simplifies all public
commands. Retaining `nix/` with an extra workflow source input would preserve two roots and
more lock/configuration machinery. Duplicating workflows under `nix/` would be misleading and
would not change GitHub's discovery requirement. Moving `.github/` is not viable.

## Repository Touchpoints

```text
.github/workflows/update-flake.yml       update flake path
.github/workflows/verify.yml             remove ./nix and dir=nix references
.gitignore                               merge declarative ignore rules
README.md                                preserve public profile document
LICENSE                                 preserve license
flake.nix                               relocate; make Actionlint root-relative; update hooks
flake.lock                              relocate unchanged
treefmt.nix                             relocate unchanged
.envrc                                  relocate
AGENTS.md                               relocate project entrypoint
.agents/ .codex/ .specify/              relocate project tooling and active feature
docs/ lib/ modules/ packages/            relocate configuration sources
systems/ tests/ specs/ okf/              relocate hosts, checks, history, knowledge
nix/                                    remove after tracked contents are relocated
```

## Verification Matrix _(mandatory)_

| Requirement/story     | Target              | Verification command or observation                              | Local/CI |
| --------------------- | ------------------- | ---------------------------------------------------------------- | -------- |
| FR-001, FR-003 / US1  | Root flake          | `nix flake metadata .` and `nix flake check --no-build`          | Local    |
| FR-004, FR-005 / US1  | Actionlint          | `nix build .#checks.x86_64-linux.actionlint --no-link`           | Local/CI |
| FR-004, FR-005 / US1  | Explicit path input | `nix build 'path:.#checks.x86_64-linux.actionlint' --no-link`    | Local    |
| FR-006                | GitHub workflows    | `actionlint .github/workflows/*.yml`                             | Local/CI |
| FR-007                | Source relocation   | `git status --short` plus tracked/ignored-file review            | Local    |
| FR-008, INV-002 / US2 | Quick behavior      | `nix build .#unit-tests .#configuration-tests --no-link`         | Local/CI |
| FR-008, INV-002 / US2 | Both hosts          | `nix build .#nixos-build .#nixos-wsl-build --no-link`            | Local/CI |
| FR-009                | Governance          | `.specify/scripts/bash/validate-project.sh`                      | Local/CI |
| SC-004                | Active references   | `rg -n --hidden -S '\./nix                                       | dir=nix  | path-to-flake-dir' . --glob '!.git/**' --glob '!specs/00[1-8]-\*/**'` | Local |
| INV-001 / US2         | Public files        | `git diff -- README.md LICENSE` is empty and both remain tracked | Local    |

## Delivery and Recovery

1. Relocate tracked project files and merge root metadata without copying ignored artifacts.
2. Update active source, CI, hooks, instructions, and current feature artifacts for root paths.
3. Run lightweight pure/path checks and governance validation, followed by configuration tests
   and both host builds.
4. No activation is required. Deliver the relocation as one reviewable change.
5. Roll back by reverting that change; no state or credential recovery is necessary.

## Current-System Reconciliation

After implementation, update only the claims proven to have changed:

- Configuration entrypoint and architecture paths become repository-root paths.
- Developer shell, maintenance, CI, and verification commands lose the `nix/` prefix.
- Agent tooling and Spec Kit project locations become root-relative.
- Actionlint validates root workflows from inside the flake source boundary and supports pure
  explicit path evaluation.

The mandatory `speckit.system-memory.sync` hook performs this reconciliation and records
the result in the feature tasks.

## Complexity Tracking

No constitution violations or deliberately retained complexity.
