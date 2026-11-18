# Implementation Plan: Modern Web Guidance Skill

**Branch**: `020-modern-web-guidance` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/020-modern-web-guidance/spec.md`

## Summary

Install only the official Modern Web Guidance skill source from the version 1.0.1 GitHub release archive as a fixed-hash Nix source. Home Manager exposes that source to Codex and OpenCode. Preserve upstream invocation instructions and leave CLI selection to the agent. Update current-system memory to explain global and project-level skill management.

## Technical Context

**Language/Version**: Nix

**Primary Dependencies**: Pinned Nixpkgs, GoogleChrome/modern-web-guidance release `v1.0.1`

**Storage**: Nix store; Home Manager symlinks

**Testing**: Nix formatting and evaluation of both host configurations

**Target Platform**: `x86_64-linux`, bare-metal NixOS and NixOS-WSL

**Project Type**: NixOS/Home Manager configuration

**Performance Goals**: CLI search and retrieval use the local corpus

**Constraints**: Pin skill source with fixed hash; do not bundle a Node runtime or CLI

**Scale/Scope**: Shared Home Manager defaults and canonical system memory

## Constitution Check

- Declarative/reproducible ownership: pass; package is a fixed-hash Nix source and Home Manager owns its installation.
- Security boundaries: pass; no credentials are needed and telemetry is disabled in the wrapper.
- Verification: format and evaluate both host configurations; no new discovered module was added.
- Current-system memory: update in the same implementation.
- Specification threshold: satisfied; this feature crosses shared Home Manager and agent-tooling configuration.

## Project Structure

```text
modules/home/default.nix
.specify/memory/current-system.md
specs/020-modern-web-guidance/{spec,plan,tasks}.md
```

**Structure Decision**: Extend the existing shared Home Manager defaults so both hosts and both configured agents receive the same pinned skill and CLI.

## Complexity Tracking

No constitution exceptions.
