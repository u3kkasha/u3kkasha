# Implementation Plan: Global Official .NET Skills

**Branch**: `023-global-dotnet-skills` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

## Summary

Pin the official `dotnet/skills` repository in the shared Home Manager source and expose every plugin skill directory containing `SKILL.md` to Codex. Use plugin-qualified link names to keep same-named skills distinct, while preserving existing global skills.

## Technical Context

**Language/Version**: Nix
**Primary Dependencies**: Nixpkgs `fetchFromGitHub`, Home Manager Codex skills option
**Storage**: N/A
**Testing**: Existing flake configuration evaluation and generated Home Manager links
**Target Platform**: x86_64-linux bare-metal NixOS and WSL hosts
**Project Type**: NixOS/Home Manager configuration
**Constraints**: Pin an immutable commit and fixed content hash; no runtime skill installer.
**Scale/Scope**: One upstream source and shared Home Manager configuration for both hosts.

## Constitution Check

- Declarative, reproducible ownership: pass; source revision and hash are pinned in Nix.
- Shared modules and host boundaries: pass; shared Home Manager configuration serves both hosts.
- Security boundaries: pass; skill files add no privileges or credentials.
- Verification: format Nix and evaluate both supported configurations and their generated skill links.
- Current-system memory: update the global skills documentation after implementation.
- Smallest coherent design: pass; derive links from the upstream catalog instead of duplicating its skill list.

## Research

- The official `dotnet/skills` README lists plugin collections and documents that their portable skills follow the Agent Skills standard and work with Codex.
- The pinned source is commit `2877c712edc20643b72f64e2983b168e6661d607`; its fixed unpacked source hash is `sha256-CctE7eJNAGKET2VGJwHKczCeLeiUQyMPgm+AkE6DoeI=`.
- The source currently contains 108 plugin skill directories with `SKILL.md`; plugin-qualified names prevent collisions and the generated map naturally follows future updates to the pinned revision.
- Repository-defined skills are installed as Codex skill directories through Home Manager's `programs.codex.skills` option.

## Project Structure

```text
modules/home/default.nix                 # Pin the source and derive Codex skill links
specs/023-global-dotnet-skills/           # Feature specification and implementation record
.specify/memory/current-system.md        # Document global .NET skills
```

## Verification

- Run the repository formatter check.
- Evaluate both host configurations and assert the generated Codex skill links include the pinned .NET catalog and retain existing skills.
