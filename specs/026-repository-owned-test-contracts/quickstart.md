# Repository-Owned Test Contracts Quickstart

## Focused helper and policy checks

```bash
nix build .#unit-tests .#configuration-tests .#token-wrapper-tests --no-link
```

Expected: discovery fixture rules, explicit host policy, Codex merge behavior, and Bash/Nushell token wrapper behavior pass without test-time network access or real credentials.

## Runtime integration

```bash
nix build .#vm-test-nixos .#vm-test-wsl-mock
```

Expected: configured-user Docker access remains available on both host targets.

## Governance and formatting

```bash
.specify/scripts/bash/validate-project.sh
nix build .#checks.x86_64-linux.formatting --no-link
```

## Host builds

```bash
nix build .#nixos-build .#nixos-wsl-build --no-link
```

Host builds and VM derivations are heavier than the focused checks and may be delegated to CI. Record any commands not run in the completion report.

## Execution status

- Focused unit, configuration, and token-wrapper checks passed locally.
- Formatting and Spec Kit governance validation passed locally.
- The combined host and VM build was stopped after ten minutes without completing; the repository CI matrix includes both host builds and both VM derivations, which remain delegated to CI.
