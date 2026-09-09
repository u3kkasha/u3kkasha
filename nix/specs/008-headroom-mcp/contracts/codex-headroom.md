# Contract: Opt-in Codex Proxy Launcher

- Command: `codex-headroom [CODEX_ARGS...]`
- Normal `codex`: unchanged and direct
- Proxy bind: `127.0.0.1` only
- Proxy lifetime: launcher/session scoped; cleaned up on success, failure, and interruption
- Codex routing: process-local configuration override only
- Credentials: inherited by Codex and forwarded in process; never declared, persisted, or logged
- Telemetry: external telemetry disabled
- Files: Codex configuration, MCP entries, and project instruction files remain byte-identical

The launcher must fail clearly if its proxy cannot become healthy. It must not kill or adopt an
unrelated process occupying its selected endpoint. Antigravity CLI is not routed through this
launcher.
