# Implementation Plan: Codex Nuxt UI Skill

**Branch**: `021-codex-nuxt-ui-skill` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

## Summary

Add the official Nuxt UI v4 skill to Codex through Home Manager's native skill option, pinning the upstream source with a Git revision and fixed hash. Limit both the nix-skills manager and native global skills to Codex, and update canonical system memory.

## Technical Context

**Language/Version**: Nix

**Primary Dependencies**: Nuxt UI repository skill at revision `550471d1a2c1178c9cc9593d8ff684cae7d64674`

**Storage**: Fixed-hash Nix source and Home Manager managed skill links

**Testing**: Formatting and generated configuration assertions for both hosts

**Target Platform**: `x86_64-linux`, bare-metal NixOS and NixOS-WSL

**Constraints**: Do not alter OpenCode application enablement or unrelated configuration.

## Constitution Check

- Declarative and reproducible ownership: pass; Home Manager owns a pinned source.
- Shared host behavior: pass; shared Home Manager config applies to both hosts.
- Verification: assert skill selection for both host evaluations and format changes.
- Current-system memory: update in the same implementation.
- Specification threshold: satisfied; change applies to both supported hosts.

## Project Structure

```text
modules/home/default.nix
tests/configuration.nix
.specify/memory/current-system.md
specs/021-codex-nuxt-ui-skill/{spec,plan,tasks}.md
```

## Complexity Tracking

No constitution exceptions.
