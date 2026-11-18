# Research: Repository-Owned Test Contracts

## Decision: Test module discovery against a minimal fixture

- **Decision**: Use a checked-in fixture with one eligible `.nix` file, a `default.nix`, a non-Nix file, one directory with `default.nix`, and one directory without it; assert the expected inclusion and exclusion rules without comparing a complete inventory.
- **Rationale**: The helper contract is deterministic inclusion/exclusion. A fixture tests that behavior and accepts additional eligible entries automatically.
- **Alternatives considered**: Keep snapshots of both live module trees (high maintenance and inventory coupling); test only the current nonempty result (does not prove exclusion rules).

## Decision: Exercise shell wrappers with stub executables

- **Decision**: Move only the repository-owned wrapper definitions into sourceable Bash and Nushell files, then run each against fake `gh` and `nix` commands with controlled outputs and environment.
- **Rationale**: This tests token handling, environment scope, fallback, and argument forwarding without network access, credentials, or assertions about shell internals.
- **Alternatives considered**: Assert generated shell text (brittle and non-behavioral); invoke real GitHub/Nix services (external and unnecessary).

## Decision: Expand Codex merge tests at its observable boundary

- **Decision**: Invoke the existing merge command on temporary TOML files and inspect the resulting user settings and managed MCP section; test invalid managed input leaves the current file unchanged.
- **Rationale**: The script's contract is preservation and replacement behavior. Tests need not assert TOML formatting, temp-file naming, or library-specific details.
- **Alternatives considered**: Snapshot the complete TOML output (layout coupling); unit test TOMLKit behavior (upstream-library testing).

## Decision: Amend discovery governance and preserve explicit policies

- **Decision**: Change Constitution II's exact-list requirement into a deterministic discovery-contract requirement, and retain policy assertions where values protect an explicit security or reproducibility boundary.
- **Rationale**: This retains regression detection without forcing an assertion update for each ordinary module addition.
- **Alternatives considered**: Leave constitution unchanged (would make fixture coverage noncompliant); remove discovery tests (loses protection for the helper contract).
