# Data Model: Persist Headroom Savings

## Savings Event

An append-only Headroom-owned accounting record produced when compression reduces input
tokens.

Fields are owned by Headroom's schema and include schema version, timestamp, tokens before,
tokens after, tokens saved, estimated avoided cost, model, client, source, and process ID.

Validation rules:

- Events are written only when saved tokens are positive.
- Token and cost values are non-negative.
- Concurrent writers append under Headroom's advisory file lock.
- Records older than Headroom's maximum 30-day reporting retention may be pruned.

## Persistent Savings Ledger

A user-owned JSONL file at the shared Headroom XDG data location. It contains zero or more
savings events and is the source for cumulative savings reports.

Relationships:

- The Headroom MCP server and each opt-in wrapped Codex proxy may append savings events.
- `headroom savings` reads and aggregates ledger events.
- The ledger is independent of each wrapped session's temporary workspace lifecycle.

## Wrapped Headroom Session

A temporary proxy process plus workspace/config directory created for one opt-in Codex
invocation.

State transitions:

1. Create temporary workspace and configuration roots.
2. Start loopback proxy with the shared ledger selected.
3. Append any compression savings to the shared ledger.
4. Stop the proxy and delete all temporary session state.
5. Leave the shared ledger available for later reporting.
