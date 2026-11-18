# Implementation Plan: Lock Global Skill Sources

**Branch**: `024-locked-global-skill-sources` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

## Summary

Declare the .NET, Modern Web Guidance, and Nuxt UI repositories as non-flake inputs and use those inputs in shared Home Manager configuration. The nix-skills catalog is already a flake input. The existing update workflow then refreshes all four locked sources and its pull request is validated by regular CI.

## Technical Context

**Language/Version**: Nix
**Primary Dependencies**: Nix flakes, Home Manager, DeterminateSystems/update-flake-lock
**Storage**: `flake.lock`
**Testing**: Format and evaluate both supported host configurations
**Target Platform**: x86_64-linux bare-metal NixOS and WSL hosts
**Project Type**: NixOS/Home Manager configuration
**Constraints**: Follow upstream repositories while installing only lockfile-pinned content.
**Scale/Scope**: Three skill-source inputs, shared Home Manager configuration, and existing lock-update workflow.

## Constitution Check

- Declarative, reproducible ownership: pass; skill repositories resolve to immutable lockfile revisions.
- Shared modules and host boundaries: pass; both hosts consume the same Home Manager inputs.
- Security boundaries: pass; no permissions or credentials change.
- Verification: format and evaluate both host configurations; CI checks update pull requests.
- Current-system memory: update the lock and update workflow documentation.
- Smallest coherent design: pass; reuse the current update workflow and existing `inputs` module argument.

## Research

- `.github/workflows/update-flake.yml` invokes `DeterminateSystems/update-flake-lock` without filtering inputs.
- The action updates the flake lockfile and opens a pull request; the repository's normal PR workflow evaluates and builds the supported configurations.
- `nix-skills` is already declared as a flake input; dotnet/skills, GoogleChrome/modern-web-guidance, and nuxt/ui currently use direct `fetchFromGitHub` declarations and should move into the lock.
- A non-flake source input exposes the repository tree while keeping its revision and content hash in `flake.lock`.

## Project Structure

```text
flake.nix                              # Declare skill catalog source inputs
flake.lock                             # Lock each source revision and content hash
modules/home/default.nix               # Consume the locked source trees
.specify/memory/current-system.md     # Document skill update lifecycle
specs/024-locked-global-skill-sources/ # Feature record
```

## Verification

- Format changed Nix and Markdown files.
- Evaluate both host skill maps and confirm existing global skills remain present.
- Run Spec Kit governance validation.
