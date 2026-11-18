# Implementation Plan: Repository-Owned Test Contracts

**Feature Directory**: `026-repository-owned-test-contracts` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification in `specs/026-repository-owned-test-contracts/spec.md`

## Summary

Replace full module inventory snapshots with fixture-based `scanPaths` contract coverage. Keep explicit security/reproducibility policy assertions, expand Codex merge behavior coverage, and isolate Bash/Nushell GitHub token wrappers into sourceable repository-owned snippets exercised with stub commands. Update the constitution and canonical verification description to match.

## Technical Context

**Configuration language**: Nix, with Bash, Nushell, and Python behavior under test

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: Both hosts are evaluated; only shared test and Home Manager source changes

**Affected layers**: Constitution, current-system verification prose, internal library tests, Home Manager shell integration, generated Codex configuration tests, flake check wiring

**Inputs/packages/options**: Existing pinned Nixpkgs packages; Bash, Nushell, Python with `tomlkit`; existing `lib.runTests` and NixOS VM test derivations

**State or migration impact**: None

**Security impact**: Token wrapper coverage verifies process-scoped credentials and fallback paths; no credentials or privilege policy changes

**Rollback**: Revert the feature commit; host generations and persistent state are unaffected

**Constraints**: Test only repository-owned behavior. Avoid exact generated inventories and assertions about Nix, shell, TOML, Docker, or other upstream internals. Preserve both Docker VM checks.

## Constitution Check

| Principle                           | Evidence of compliance                                                                                                                        | Status                        |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| Declarative, reproducible ownership | Shell snippets remain checked-in Home Manager sources; no runtime-resolved dependencies are introduced.                                       | PASS                          |
| Shared modules and host boundaries  | Shared helper tests use fixtures; WSL upstream modules remain host-scoped. Replace exact inventory rule with deterministic behavior contract. | PASS after approved amendment |
| State compatibility                 | No state-version or migration changes.                                                                                                        | PASS                          |
| Explicit security boundaries        | Token tests check child-process scoping and fallback without real credentials; existing trust policy assertions remain.                       | PASS                          |
| Verification follows impact         | Focused tests cover helper behavior and policy; host builds and VM tests remain CI checks.                                                    | PASS                          |
| Current-system memory               | Update verification description and test categorization to match retained checks.                                                             | PASS                          |
| Smallest coherent design            | Extract only shell wrappers needed for isolated behavior testing; no new test framework.                                                      | PASS                          |

## Current and Target Design

### Current

`tests/unit.nix` snapshots all paths returned by `internal.scanPaths` for the live Home Manager and NixOS module trees. Configuration checks retain explicit trust, cache, and MCP reproducibility policies and a generated Codex merge derivation. The merge derivation tests a single scenario. Bash and Nushell token wrapper logic is embedded in shell initialization strings, preventing direct isolated behavior checks. The constitution requires updating exact discovered-path lists whenever a module tree changes.

### Target

The discovery helper is tested against a small fixture using inclusion/exclusion predicates, so added eligible entries need no inventory update. The shell token wrappers live in checked-in source snippets embedded by Home Manager and are executed against stub `gh` and `nix` commands for success and fallback cases. Codex merge checks cover preservation, replacement, removal, and malformed-input safety. Exact policy checks and both Docker VM checks remain. The constitution requires deterministic discovery contract coverage rather than frozen live inventories.

### Decision Rationale

Fixture assertions verify the helper's public behavior while avoiding coupling to the current module inventory. Extracting just the shell functions makes their own behavior runnable in isolation without testing either shell implementation. Stub commands prevent network access and real credential use. Existing configuration and VM checks remain the proper evidence for host composition and runtime availability.

## Repository Touchpoints

```text
.specify/memory/constitution.md               Amend module discovery testing requirement and version.
.specify/memory/current-system.md              Describe contract and policy focused verification.
lib/internal/default.nix                       Keep behavior unchanged; test its helper through fixtures.
modules/home/bash.nix                          Load the checked-in Bash token wrapper snippet.
modules/home/nushell.nix                       Load the checked-in Nushell token wrapper snippet.
modules/home/nix-token-wrapper.bash            New source for Bash wrapper behavior.
modules/home/nix-token-wrapper.nu              New source for Nushell wrapper behavior.
tests/fixtures/scan-paths/                     New static fixture entries for discovery contract cases.
tests/unit.nix                                 Replace live exact path snapshots with fixture predicates.
tests/configuration.nix                        Retain policy checks and expand Codex merge scenarios.
tests/token-wrapper.nix                        New stub-command behavior checks for both shell wrappers.
flake.nix                                      Wire token wrapper check and categorize it honestly.
specs/026-repository-owned-test-contracts/*    Record spec, plan, research, tasks, and validation.
```

## Verification Matrix

| Requirement/story       | Target                       | Verification command or observation                    | Local/CI |
| ----------------------- | ---------------------------- | ------------------------------------------------------ | -------- |
| FR-001, FR-002 / US1    | Discovery helper             | `nix build .#unit-tests --no-link`                     | Local    |
| FR-003, FR-004 / US2    | Codex merge script           | `nix build .#configuration-tests --no-link`            | Local/CI |
| FR-005 / US2            | Bash and Nushell wrappers    | `nix build .#token-wrapper-tests --no-link`            | Local/CI |
| FR-006 / US3            | Both host policy projections | `nix build .#configuration-tests --no-link`            | Local/CI |
| FR-007 / US3            | Both runtime targets         | `nix build .#vm-test-nixos .#vm-test-wsl-mock`         | CI       |
| Constitution and memory | Governance                   | `.specify/scripts/bash/validate-project.sh`            | Local    |
| All changed Nix sources | Formatting                   | `nix build .#checks.x86_64-linux.formatting --no-link` | Local    |

## Delivery and Recovery

1. Amend the discovery testing policy before removing the snapshot tests.
2. Add behavior fixtures and sourceable shell snippets with stub-command tests.
3. Expand Codex merge scenarios and retain explicit policy and VM checks.
4. Run focused checks, project governance validation, and formatting; record CI-only host/VM checks if unavailable.
5. Revert the feature commit to recover the prior test model; no system rollback is needed.

## Current-System Reconciliation

Update the maintenance and verification section to state that discovery is covered by rule-based fixture tests, configuration assertions cover explicit policies and generated behavior, and shell token-wrapper behavior has a focused stub-command check. Retain host build and VM verification claims.

## Complexity Tracking

| Complexity                     | Why required                                                                                          | Simpler alternative rejected because                                                      |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Sourceable shell wrapper files | Allows focused execution of repository-owned Bash and Nushell behavior with controlled stub commands. | Keeping inline strings leaves tests coupled to extraction tricks or untested source text. |
