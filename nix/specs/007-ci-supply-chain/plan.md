# Implementation Plan: CI Supply-Chain Hardening

**Feature Directory**: `007-ci-supply-chain` | **Date**: 2026-09-08 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/007-ci-supply-chain/spec.md`

## Summary

Harden the two existing GitHub Actions workflows and the live repository policy. The verification
workflow will expose a stable aggregate gate, separate read-only PR cache use from trusted cache
publishing, bound all jobs, schedule official-cache-only builds monthly, and show an `nvd` system
diff for automated lock updates. The updater will gain concurrency and a timeout. GitHub settings
will enforce immutable allowlisted Actions, enable native security automation, and require the
gate only after the workflow commit is available remotely.

## Technical Context

**Configuration language**: YAML workflows, Markdown governance artifacts, GitHub repository settings

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: none (both host build outputs remain verification targets)

**Affected layers**: CI, developer shell/pre-commit, Cachix publishing boundary, repository ruleset,
dependency/security automation

**Inputs/packages/options**: Existing pinned checkout, Nix installer, Cachix, Gitleaks, and lock-update
Actions; `nvd` already supplied by the locked dev shell; `actionlint` from the locked package set

**State or migration impact**: N/A; no NixOS or Home Manager state changes

**Security impact**: Removes cache write and checkout credentials from PR jobs; constrains allowed
Actions; adds mandatory verification and native static/security analysis

**Rollback**: Revert the workflow/spec commit, restore prior Actions permissions, disable native
security features if necessary, and remove the required gate from ruleset `17533543`

**Constraints**: Do not push; do not activate hosts; preserve immutable Action references; avoid
requiring a check that does not yet exist on the remote default branch

## Constitution Check

_GATE: Passed before and after design._

| Principle                           | Evidence of compliance                                                                                      | Status |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | Workflow behavior is checked in; all third-party Actions remain pinned                                      | PASS   |
| Shared modules and host boundaries  | No host/module behavior changes; both outputs remain verified                                               | PASS   |
| State compatibility                 | No state versions, migrations, or persistent host data change                                               | PASS   |
| Explicit security boundaries        | PR and trusted-push cache credentials are separated and documented                                          | PASS   |
| Verification follows impact         | Workflow validation, governance validation, flake checks, builds, and live-setting queries are mapped below | PASS   |
| Current-system memory               | Caching/trust and verification claims are reconciled after implementation                                   | PASS   |
| Smallest coherent design            | Existing workflows, dev-shell `nvd`, and one stable gate are extended without a new service                 | PASS   |

## Current and Target Design

### Current

`.github/workflows/verify.yml` runs flake checks, governance validation, four matrix builds,
and manual-only cache-independent builds. All ordinary jobs receive the Cachix auth token and have
no timeouts. `.github/workflows/update-flake.yml` updates the lock weekly but has no concurrency or
timeout. The default-branch ruleset requires a pull request but no successful check. Repository
Actions allow every publisher and do not enforce SHA references; native security updates and CodeQL
default setup are disabled.

### Target

Pull requests configure Cachix without authentication, while `push` and trusted manual jobs retain
publishing. Every job has a finite timeout and checkout credentials are not persisted outside the
write-capable updater. The required build graph terminates in `CI Gate`, whose result is derived from
the evaluation job and complete matrix. A monthly schedule executes only official-cache builds.
Lock-update PRs compare the previous and proposed bare-metal closures with the already-pinned `nvd`.
Repository settings enforce full SHAs, a minimal Action publisher set, security updates, CodeQL, and
eventually the gate.

### Decision Rationale

A final gate avoids fragile ruleset coupling to matrix-generated check names and gives the ruleset one
durable context. The gate uses `always()` so failure or cancellation cannot suppress it. Cache
publishing is event-gated rather than secret-presence-gated, keeping the trust decision explicit.
The package diff is placed in the existing `nixos-build` matrix leg to reuse its proposed-system
closure; only the base closure is additional work. Monthly cache-independent validation uses the
same workflow but suppresses ordinary verification/build jobs to avoid duplicate scheduled work.

## Repository Touchpoints

```text
.github/workflows/update-flake.yml
.github/workflows/verify.yml
.specify/memory/current-system.md
flake.nix
specs/007-ci-supply-chain/
GitHub repository Actions permissions
GitHub repository automated security fixes
GitHub repository CodeQL default setup
GitHub ruleset 17533543 (after remote workflow availability)
```

## Verification Matrix _(mandatory)_

| Requirement/story   | Target                       | Verification command or observation                                           | Local/CI  |
| ------------------- | ---------------------------- | ----------------------------------------------------------------------------- | --------- |
| FR-001 / US1        | Workflow graph               | `actionlint .github/workflows/*.yml` and inspect `needs`/result predicates    | Local     |
| FR-002 / US1        | Default-branch ruleset       | `gh api repos/u3kkasha/u3kkasha/rulesets/17533543`                            | Post-push |
| FR-003–FR-004 / US2 | Workflow credential boundary | Inspect event-conditioned Cachix steps and `persist-credentials`              | Local     |
| FR-005–FR-008 / US3 | Workflow operations          | `actionlint .github/workflows/*.yml` and inspect triggers/summary command     | Local/CI  |
| FR-009              | Actions policy               | Query Actions permissions and selected Action patterns                        | Live      |
| FR-010              | Security automation          | Query automated security fixes and CodeQL default setup                       | Live      |
| FR-011              | Workflow linting             | `nix build .#checks.x86_64-linux.actionlint --no-link` and inspect pre-commit | Local/CI  |
| INV-001             | Existing checks/builds       | `nix flake check .` and CI matrix                                             | Local/CI  |
| INV-003             | State versions               | `git diff` proves no state-version source change                              | Local     |
| SC-005              | Governance                   | `.specify/scripts/bash/validate-project.sh`                                   | Local     |

## Delivery and Recovery

1. Create and validate the feature artifacts before changing workflows or live settings.
2. Harden checked-in workflows and documentation, then run local YAML, governance, formatting, and
   flake verification.
3. Apply only live settings that do not depend on unpublished workflow content: allowlist/SHA policy,
   security updates, and CodeQL.
4. Commit without pushing. After the operator pushes and `CI Gate` appears on a pull request, add
   that context to ruleset `17533543` before merging subsequent changes.
5. Roll back file changes by reverting the commit and live changes through their corresponding API
   settings; remove the required context first if the workflow gate is ever removed.

## Current-System Reconciliation

After implementation, update only the claims proven to have changed:

- Cachix write credentials are restricted to trusted push/manual events.
- CI has bounded jobs, a stable aggregate gate, monthly official-cache verification, and automated
  package-impact reporting.
- The locked developer environment, pre-commit hook, and CI flake check all enforce workflow linting.
- Repository Actions are immutable/allowlisted and native dependency/static security automation is
  enabled.
- The gate remains documented as pending live ruleset activation until the workflow is pushed.

The mandatory `speckit.system-memory.sync` hook performs this reconciliation and records the result
in the feature tasks.

## Complexity Tracking

No constitution violations or retained exceptional complexity.
