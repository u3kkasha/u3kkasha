# Data Model: CI Supply-Chain Hardening

## Verification Result

- **Evaluation result**: success, failure, cancelled, or skipped.
- **Build matrix result**: aggregate result of all four required targets.
- **Gate result**: success only when evaluation and matrix results are both success.
- **Stable context**: `CI Gate`, consumed by the default-branch ruleset.

## Workflow Trust Context

- **Untrusted context**: pull-request event; public cache reads only; no persisted checkout token.
- **Trusted context**: default-branch push or explicit manual dispatch; scoped cache publishing
  allowed.
- **Cache-independent context**: manual or monthly schedule; official Nix cache only.

## Repository Action Policy

- **Reference requirement**: full commit SHA.
- **GitHub-owned Actions**: allowed.
- **Third-party publishers**: Determinate Systems, Cachix, and Gitleaks only.
- **Default workflow token**: read-only; workflow-level overrides remain explicit.

## Deployment State

1. **Local-ready**: workflow commit exists locally and live independent settings are hardened.
2. **Remote-visible**: commit is pushed and `CI Gate` has been emitted at least once.
3. **Enforced**: ruleset requires `CI Gate`.

The transition from local-ready to remote-visible requires an operator push and is intentionally not
performed by this feature implementation.
