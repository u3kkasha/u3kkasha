# Research: Persist Headroom Savings

## Decision 1: Use the savings-event path override

- **Decision**: Set Headroom's dedicated savings-event path declaratively for the user
  session and explicitly for the wrapped proxy while leaving its workspace and
  configuration roots temporary.
- **Rationale**: Headroom 0.36.0 resolves the savings ledger from an explicit argument, then
  `HEADROOM_SAVINGS_EVENTS_PATH`, then `HEADROOM_WORKSPACE_DIR/savings_events.jsonl`. The
  dedicated override therefore changes exactly one persistent resource.
- **Alternatives considered**: Persist the entire wrapper workspace (reject: retains much
  more state); copy the ledger during cleanup (reject: races and unnecessary bespoke state
  handling); parse proxy logs afterward (reject: less authoritative and logs are temporary).

## Decision 2: Share the MCP data ledger

- **Decision**: Store wrapper events at the ledger path inside the existing XDG Headroom
  data directory already used by the MCP server.
- **Rationale**: Headroom implements the ledger as append-only JSONL protected by an
  advisory file lock and explicitly supports concurrent MCP/proxy writers. One ledger
  provides cumulative reporting without reconciliation.
- **Alternatives considered**: Separate wrapper ledger (reject: fragmented totals); legacy
  default `~/.headroom` (reject: duplicates the declaratively configured XDG state root).

## Decision 3: Keep the standard report command useful

- **Decision**: Expose the shared ledger through the dedicated savings-path session variable
  so `headroom savings` reads it in a normal activated shell; also set the same variable in
  the launcher so recording is not dependent on shell activation state.
- **Rationale**: Headroom otherwise defaults standalone CLI reporting to `~/.headroom`, while
  the repository's MCP state is under XDG data. Selecting only the savings path unifies the
  user experience without redirecting memory, logs, caches, or other Headroom state.
- **Alternatives considered**: Require an environment prefix on every report command
  (reject: surprising); globally override the full Headroom workspace (reject: excessive
  state coupling); add a second reporting wrapper (reject: unnecessary interface).

## Decision 4: Retain Headroom's built-in lifecycle

- **Decision**: Keep Headroom's schema, aggregation, cost estimation, and maximum 30-day
  retention unchanged.
- **Rationale**: Those semantics are owned by the pinned dependency and already exposed by
  `headroom savings`; the repository should only select the durable location.
- **Alternatives considered**: Add repository-owned aggregation or indefinite retention
  (reject: duplicate behavior and broaden state ownership).

## Decision 5: Verify composition and behavior separately

- **Decision**: Assert the generated launcher contains the precise path override and retains
  temporary cleanup, then exercise Headroom's ledger across temporary-workspace deletion in
  the existing Headroom integration derivation.
- **Rationale**: This proves both the Nix wiring and the pinned dependency's runtime behavior
  without launching an interactive Codex client or requiring network access.
- **Alternatives considered**: Full interactive proxy/Codex VM test (reject: expensive,
  provider-dependent, and inconsistent with the existing verification boundary).

## Operational caveat: Reset requires quiescence

Ordinary appends, reads, and compaction are file-locked on the supported Linux targets.
Headroom's `savings --reset` removes the ledger without taking that lock, so operators must
stop active MCP/proxy writers before resetting history. This caveat does not affect routine
concurrent recording.
