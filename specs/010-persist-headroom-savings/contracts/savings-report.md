# Savings Reporting Contract

## Producer contract

An opt-in `codex-headroom` session that achieves positive compression savings appends an
event to the configured user's persistent Headroom ledger. The session must not redirect
any other Headroom state outside its temporary workspace.

## Consumer contract

In a shell started after configuration activation, the configured user runs:

```bash
headroom savings
```

The report includes applicable wrapped-proxy and MCP compression events within Headroom's
supported reporting window. `--json` exposes the same report as structured data.

## Privacy and failure contract

- The ledger remains local and user-scoped.
- External telemetry and subscription tracking remain disabled for the wrapped proxy.
- Sessions with no positive savings add no event.
- Failure to write an event must not expose credentials or make temporary state persistent.
- The user must stop active Headroom MCP/proxy writers before running
  `headroom savings --reset` because the pinned reset operation is not file-locked.
