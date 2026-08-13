# Research: Verification Integrity

## Decision: Split at the supported-configuration dependency boundary

**Rationale**: Any test importing complete `nixosConfigurations` may retain large generated
closures. Pure discovery/internal assertions do not need those inputs and remain quick.

**Alternatives considered**: Renaming the existing monolith would be honest but would not restore
a fast unit target; dropping generated assertions would reduce coverage.

## Decision: Preserve nixd string context directly

**Rationale**: Nix string context is the declarative dependency edge from generated config to its
locked-input link farm. Evaluation will decide whether a real cycle exists.

**Alternatives considered**: Keeping `unsafeDiscardStringContext` without evidence violates the
smallest-design principle.
