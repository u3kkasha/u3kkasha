{
  pkgs,
  headroom,
}:

let
  pythonEnv = headroom.python.withPackages (_: [ headroom ]);
in
pkgs.runCommand "headroom-tests"
  {
    nativeBuildInputs = [
      headroom
      pkgs.jq
      pythonEnv
    ];
  }
  ''
    export XDG_CACHE_HOME="$TMPDIR/cache"
    export XDG_CONFIG_HOME="$TMPDIR/config"
    export XDG_DATA_HOME="$TMPDIR/data"
    export HEADROOM_WORKSPACE_DIR="$TMPDIR/workspace"
    export HEADROOM_CONFIG_DIR="$TMPDIR/headroom-config"
    export HF_HOME=${headroom.headroom-models}
    export HF_HUB_CACHE=${headroom.headroom-models}/hub
    export HF_HUB_OFFLINE=1
    export TRANSFORMERS_OFFLINE=1
    export TIKTOKEN_CACHE_DIR=${headroom.headroom-models}/tiktoken
    export HEADROOM_SENTENCE_TRANSFORMER=${headroom.headroom-models.sentenceTransformer}
    export DO_NOT_TRACK=1
    export OTEL_SDK_DISABLED=true
    mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$HEADROOM_WORKSPACE_DIR" "$HEADROOM_CONFIG_DIR"

    headroom --version | grep '0.36.0'
    headroom tools doctor > "$TMPDIR/tools.txt"
    grep 'difft.*on-path' "$TMPDIR/tools.txt"
    grep 'scc.*on-path' "$TMPDIR/tools.txt"
    grep 'ast-grep.*on-path' "$TMPDIR/tools.txt"

    python3 - <<'PY'
    import asyncio
    import os

    import anthropic
    import datasets
    import fastapi
    import fastembed
    import headroom
    import httpx
    import magika
    import mcp
    import numpy
    import onnxruntime
    import openai
    import openpyxl
    import PIL
    import rapidocr
    import sentence_transformers
    import sklearn
    import tiktoken
    import torch
    import trafilatura
    import transformers
    import tree_sitter_language_pack
    import uvicorn
    import websockets
    import xlrd

    from headroom.memory.adapters.embedders import OnnxLocalEmbedder
    from headroom.transforms.kompress_compressor import KompressCompressor

    assert os.environ["HF_HUB_OFFLINE"] == "1"
    assert os.environ["TRANSFORMERS_OFFLINE"] == "1"
    assert os.environ["DO_NOT_TRACK"] == "1"
    assert os.environ["OTEL_SDK_DISABLED"] == "true"

    for encoding_name in ("o200k_base", "cl100k_base", "p50k_base", "r50k_base"):
        encoding = tiktoken.get_encoding(encoding_name)
        assert encoding.encode("Headroom offline tokenizer smoke test")

    backend = KompressCompressor().preload(allow_download=False)
    assert backend.startswith("onnx"), backend

    async def check_embedder():
        vector = await OnnxLocalEmbedder().embed("Headroom offline model smoke test")
        assert vector.shape == (384,), vector.shape

    asyncio.run(check_embedder())
    PY

    # Nix's build sandbox intentionally has no network namespace. The MCP
    # tools operate locally and must still complete when no proxy is reachable.
    export HEADROOM_PROXY_URL=http://127.0.0.1:9
    coproc HEADROOM_MCP { headroom mcp serve 2> "$TMPDIR/mcp.log"; }

    printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"nix-test","version":"1"}}}' >&"''${HEADROOM_MCP[1]}"
    IFS= read -r initialize_response <&"''${HEADROOM_MCP[0]}"
    printf '%s' "$initialize_response" | jq -e '.id == 1 and .result.serverInfo.name == "headroom"'

    printf '%s\n' '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' >&"''${HEADROOM_MCP[1]}"
    printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' >&"''${HEADROOM_MCP[1]}"
    IFS= read -r tools_response <&"''${HEADROOM_MCP[0]}"
    printf '%s' "$tools_response" | jq -e \
      '[.result.tools[].name] | sort == ["headroom_compress", "headroom_retrieve", "headroom_stats"]'

    content="$(for i in $(seq 1 180); do printf 'Headroom preserves the full original while reducing repeated context for later reasoning. '; done)"
    jq -cn --arg content "$content" \
      '{jsonrpc:"2.0",id:3,method:"tools/call",params:{name:"headroom_compress",arguments:{content:$content}}}' \
      >&"''${HEADROOM_MCP[1]}"
    IFS= read -r compress_response <&"''${HEADROOM_MCP[0]}"
    hash="$(printf '%s' "$compress_response" | jq -er '.result.content[0].text | fromjson | .hash')"
    test -n "$hash"

    jq -cn --arg hash "$hash" \
      '{jsonrpc:"2.0",id:4,method:"tools/call",params:{name:"headroom_retrieve",arguments:{hash:$hash}}}' \
      >&"''${HEADROOM_MCP[1]}"
    IFS= read -r retrieve_response <&"''${HEADROOM_MCP[0]}"
    printf '%s' "$retrieve_response" | jq -e --arg content "$content" \
      '(.result.content[0].text | fromjson) as $result | $result.source == "local" and $result.original_content == $content'

    kill "$HEADROOM_MCP_PID" 2>/dev/null || true
    wait "$HEADROOM_MCP_PID" 2>/dev/null || true
    touch "$out"
  ''
