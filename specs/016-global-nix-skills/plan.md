# Implementation Plan: Global Nix Skills

**Branch**: `016-global-nix-skills` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

## Summary

Pin `olafkfreund/nix-skills`, import its Home Manager module for both supported hosts, and select six Nix skills for Codex and OpenCode. Keep the existing skills CLI for project-level discovery.

## Technical Context

**Language/Version**: Nix
**Primary Dependencies**: nix-skills flake input, Home Manager
**Storage**: N/A
**Testing**: Existing Home Manager configuration assertions and flake evaluation
**Target Platform**: x86_64-linux NixOS bare-metal and WSL hosts
**Project Type**: NixOS/Home Manager configuration
**Constraints**: All dependency sources stay pinned; global skill settings remain host-neutral.
**Scale/Scope**: One flake input and the shared Home Manager configuration.

## Constitution Check

- Declarative, reproducible ownership: pass; skills are built from a locked flake input and installed by Home Manager.
- Shared module and host boundaries: pass; configuration belongs in shared Home Manager defaults.
- Security boundaries: pass; no new privileges or credentials.
- Verification: inspect the pinned upstream module and run relevant formatting/evaluation checks as allowed.
- Current-system memory: update agent tooling and pinned dependency documentation after the change.
- Smallest coherent design: use the upstream Home Manager module, no additional skill installer.

## Research

- Upstream exposes `programs.nix-skills.enable`, `skills`, and `agents`; skill choices are validated against its catalog.
- Upstream supports native Codex and OpenCode skill directories.
- The existing Vercel `skills` CLI is an interactive/project-oriented tool and remains installed.

## Project Structure

```text
flake.nix                         # pin nix-skills and follow repository nixpkgs/Home Manager
modules/home/default.nix          # import upstream module and select global skills/agents
flake.lock                        # locked nix-skills revision
tests/configuration.nix           # assertions for skill selection and CLI retention
.specify/memory/current-system.md # record the implemented global skills workflow
```

## Verification

- Format changed Nix files.
- Evaluate configuration assertions for both supported hosts and verify the upstream skill targets.
- Confirm the lockfile pins nix-skills.
