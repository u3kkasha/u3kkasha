# Research: Cache and Package Policy

## Decision: Use an internal data file as the canonical cache source

**Rationale**: Nix requires flake `nixConfig` values to be literal and does not expose them through
`self` outputs. Removing duplicate flake metadata lets both installed daemons consume one imported source.

**Alternatives considered**: Importing a standalone data file into `nixConfig` is rejected as a
thunk; projecting `self.nixConfig` fails because it is not an output; repeating literals preserves duplication.

## Decision: Allow only Steam-family package names

**Rationale**: Current supported-host evaluation identifies Steam as the intentional unfree feature.
The exact allowlist is `steam`, `steam-original`, and `steam-unwrapped` to cover its evaluated package family.

**Alternatives considered**: Blanket `allowUnfree` violates policy; a `steam*` prefix would permit unrelated future names.
