# Research: Focused Verification

## Decision 1: Remove the nixd JSON assertion instead of restructuring JSON generation

- **Decision**: Remove `testNixdConfigUsesLockedInputPaths` and the test-only reads/parsing
  of nixd JSON from `tests/configuration.nix`; keep `modules/home/nixd.nix` unchanged.
- **Rationale**: The assertion checks serialized string layout and forces store paths into
  evaluator-level JSON values. That is an implementation detail, while the generated file
  and locked-input link farm remain owned by the nixd module and host build closure.
- **Alternatives considered**: Reintroduce string context while retaining JSON parsing;
  test JSON through a derivation; remove nixd generation. The first two preserve a brittle
  assertion and add machinery; removing nixd would change user functionality without
  evidence it is broken.

## Decision 2: Retain only checks tied to explicit policy or observable generated behavior

- **Decision**: Keep the exact unfree policy, module discovery lists, cache and trusted-user
  policies, Docker membership, local MCP store-command policy, curated skill-source
  integrity, and Codex merge behavior. Remove duplicated option equality, static package
  presence, trivial host/module flags, and weak output-string assertions.
- **Rationale**: These retained assertions guard the project constitution, security or
  reproducibility boundaries, external source integrity, or generated behavior. The other
  assertions restate declarations and have low regression-detection value.
- **Alternatives considered**: Keep all assertions as broad smoke checks. Rejected because
  they increase coupling without checking runtime behavior; actual host and VM checks
  remain available for behavior.
