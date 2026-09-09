# Research: Full Headroom Integration

## Supported feature boundary

- **Decision**: Package Headroom v0.36.0 with its official `[all]` groups: proxy, code, ML, memory,
  relevance, image, reports, observability, evals, voice, HTML, MCP, and spreadsheet.
- **Rationale**: This is upstream's complete supported bundle and matches the operator's intent.
- **Alternatives considered**: Literal installation of every separately optional framework/provider
  adapter was rejected because it is not upstream `[all]`, adds unrelated services, and includes
  dependencies absent from the pinned package set.

## Python and Rust closure

- **Decision**: Preserve Rust core's default `ml` feature and build a private Python package set for
  the Headroom derivation. Pin upstream-compatible `tree-sitter-language-pack`, Torch,
  `sentence-transformers`, `datasets`, and the security-fixed `pydantic-settings`; use Python 3.14's
  `rapidocr` branch and include `h2` for HTTP/2.
- **Rationale**: The locked global versions conflict with upstream's supported constraints. Private
  pins prevent unrelated system packages from changing.
- **Alternatives considered**: Relaxing constraints is unsupported; updating the entire nixpkgs
  input is excessive; disabling Rust ML contradicts the expanded scope.

## Immutable runtime assets

- **Decision**: Fetch fixed revisions of Kompress, technique-router, SigLIP encoder, ONNX MiniLM,
  FastEmbed BGE, ModernBERT/tokenizer, sentence-transformer, RapidOCR, and required tiktoken data as
  fixed-output derivations. Present them through deterministic read-only cache layouts and offline
  environment variables.
- **Rationale**: Upstream otherwise downloads multi-hundred-megabyte assets into mutable user caches
  on first use. Several models are internally pinned, while floating defaults require an explicit
  revision selected and locked by this feature.
- **Alternatives considered**: Runtime downloads violate repository ownership; copying store models
  into mutable home caches duplicates multi-gigabyte data; remote model inference adds credentials
  and egress.

## MCP integration

- **Decision**: Register `${headroom}/bin/headroom mcp serve` once in the existing central registry.
- **Rationale**: Codex, Antigravity CLI, and OpenCode already consume this source of truth.
- **Alternatives considered**: `headroom mcp install` and client-specific entries mutate or duplicate
  managed configuration.

## Codex proxy lifecycle

- **Decision**: Provide `codex-headroom`, a repository-owned opt-in launcher that starts an
  ephemeral proxy on `127.0.0.1`, waits for readiness, launches pinned Codex with a process-local
  base-URL override, and reliably cleans up. Keep external telemetry off.
- **Rationale**: Ordinary Codex remains direct; no persistent service or config mutation is needed.
- **Alternatives considered**: Headroom's native wrapper still performs registrar cleanup; an
  always-on service broadens local exposure; global `OPENAI_BASE_URL` changes every consumer.

## Antigravity boundary

- **Decision**: Supply Antigravity CLI with full Headroom MCP tools but no transparent proxy route.
- **Rationale**: Current `agy` traffic uses Google Cloud Code endpoints that are not reliably
  supported by Headroom's proxy/wrapper surface.
- **Alternatives considered**: Hidden endpoint overrides are fragile and can make every agent call
  fail; direct Gemini SDK support does not prove Antigravity CLI protocol compatibility.

## Security and state

- **Decision**: No declared credentials, global provider variables, external telemetry, remote
  inference, or default service. Proxy traffic and state remain process/user scoped; Headroom state
  is retained on rollback but is non-authoritative.
- **Rationale**: This exposes every local feature without silently widening trust or deleting data.
- **Alternatives considered**: Automatic cleanup risks user data; declarative secrets are
  unnecessary because Codex already supplies authentication to its selected provider path.
