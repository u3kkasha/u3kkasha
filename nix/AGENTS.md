# Agent entrypoint

Before changing this repository, read and follow:

- `.specify/memory/constitution.md` for binding engineering and governance rules.
- `.specify/memory/current-system.md` for the canonical implemented architecture,
  supported targets, workflows, verification, and known limitations.

Use the Spec Kit workflow for changes that meet the constitution's specification
threshold. Treat completed feature artifacts under `specs/` as historical change
records; they do not override the current-system document or source code.

When `.codegraph/` exists, use CodeGraph before text search to understand or locate
code. Use Semble first for broad semantic searches, then Serena for precise symbol
inspection and edits. Use the NixOS MCP for current Nix package, option, flake, and
cache information.
