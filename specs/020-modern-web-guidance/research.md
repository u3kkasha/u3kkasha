# Research: Modern Web Guidance Skill

## Decision: Install only the official skill source as a fixed-output Nix source

The official GoogleChrome GitHub distribution publishes the skill instructions and guide files. Pin release `v1.0.1` by the unpacked source archive's SHA-256. Do not package the CLI or add a Node runtime; preserve upstream instructions so the agent can determine whether and how to invoke the CLI.

## Decision: Share skill contents with both configured agents

The existing `programs.nix-skills` module installs reusable skills under `.agents/skills` for Codex and OpenCode-specific paths under `.config/opencode/skills`. Follow those same locations for the new Google skill.

## Decision: Preserve upstream invocation guidance

The skill itself explains the CLI invocation and relevant network/telemetry behavior. Keep the source instructions unchanged and leave invocation decisions to the agent as requested.
