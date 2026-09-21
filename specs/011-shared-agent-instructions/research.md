# Research: Shared Agent Instructions

## Decision: Use Gemini's global instruction path

- **Decision**: Export Gemini guidance to `~/.gemini/GEMINI.md`.
- **Rationale**: That is the existing global Gemini instruction file; the requested
  Antigravity runtime subdirectory has no `GEMINI.md` and remains application-owned.
- **Alternatives considered**: Creating `~/.gemini/antigravity-cli/GEMINI.md`, rejected
  because no observed integration consumes it.

## Decision: One shared Home Manager payload

- **Decision**: Define one Nix string and assign it to both `home.file` destinations.
- **Rationale**: Evaluation guarantees byte-identical output and prevents future drift.
- **Alternatives considered**: Two copied source files or package-specific declarations,
  rejected because they duplicate policy.
