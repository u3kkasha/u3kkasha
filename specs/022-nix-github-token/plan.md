# Implementation Plan: Pass GitHub CLI Credentials to Nix

**Branch**: `022-nix-github-token` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

## Summary

Wrap `nix` in the managed Bash and Nushell startup configuration. Each wrapper reads `gh auth token` at invocation time and sets Nix's `access-tokens` setting only for the child process, preserving existing `NIX_CONFIG` and falling back to ordinary Nix execution when lookup fails.

## Technical Context

**Language/Version**: Nix expressions, Bash, Nushell
**Primary Dependencies**: Home Manager, GitHub CLI, Nix
**Storage**: None; credential remains in process memory and environment for one invocation
**Testing**: Existing Nix formatting and configuration evaluation workflows
**Target Platform**: x86_64-linux, Bash and Nushell
**Project Type**: NixOS/Home Manager configuration
**Performance Goals**: One `gh auth token` call per Nix invocation
**Constraints**: Never place the token in Nix store paths, generated config, or global session variables
**Scale/Scope**: Two managed interactive shells

## Constitution Check

- Security boundary is user-scoped; the token is attached only to the Nix process environment.
- No root or cross-user authority is granted.
- Bash and Nushell behavior is covered; current-system memory documents the integration.
- No architecture or host support change.

## Project Structure

```text
modules/home/bash.nix
modules/home/nushell.nix
.specify/memory/current-system.md
specs/022-nix-github-token/{spec,plan,tasks}.md
```

**Structure Decision**: Extend the existing native Home Manager shell configuration modules.
