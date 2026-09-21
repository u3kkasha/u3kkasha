# Quickstart: Validate Agent Commit Guidance

```bash
snip -- nix fmt -- --fail-on-change
snip -- nix build path:.#configuration-tests --no-link
snip -- .specify/scripts/bash/validate-project.sh
```
