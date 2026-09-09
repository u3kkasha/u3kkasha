{ pkgs }:

pkgs.writeScript "headroom-mcp-smoke" ''
  #!${pkgs.python3}/bin/python3
  import json
  import os
  import subprocess
  import tempfile

  state_root = tempfile.TemporaryDirectory(prefix="headroom-mcp-smoke.")
  environment = os.environ.copy()
  environment["HEADROOM_WORKSPACE_DIR"] = state_root.name
  environment["HEADROOM_CONFIG_DIR"] = os.path.join(state_root.name, "config")
  environment["HEADROOM_PROXY_URL"] = "http://127.0.0.1:9"

  server = subprocess.Popen(
      ["headroom", "mcp", "serve"],
      stdin=subprocess.PIPE,
      stdout=subprocess.PIPE,
      stderr=subprocess.PIPE,
      text=True,
      env=environment,
  )

  def call(payload):
      assert server.stdin is not None
      assert server.stdout is not None
      server.stdin.write(json.dumps(payload) + "\n")
      server.stdin.flush()
      return json.loads(server.stdout.readline())

  try:
      initialized = call({
          "jsonrpc": "2.0",
          "id": 1,
          "method": "initialize",
          "params": {
              "protocolVersion": "2024-11-05",
              "capabilities": {},
              "clientInfo": {"name": "nixos-vm-test", "version": "1"},
          },
      })
      assert initialized["result"]["serverInfo"]["name"] == "headroom"

      assert server.stdin is not None
      server.stdin.write(json.dumps({
          "jsonrpc": "2.0",
          "method": "notifications/initialized",
          "params": {},
      }) + "\n")
      server.stdin.flush()

      tools = call({"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
      names = sorted(tool["name"] for tool in tools["result"]["tools"])
      assert names == ["headroom_compress", "headroom_retrieve", "headroom_stats"]

      content = (
          "Headroom preserves the complete original while reducing repeated context. " * 180
      )
      compressed = call({
          "jsonrpc": "2.0",
          "id": 3,
          "method": "tools/call",
          "params": {
              "name": "headroom_compress",
              "arguments": {"content": content},
          },
      })
      compression = json.loads(compressed["result"]["content"][0]["text"])
      assert compression["hash"]

      retrieved = call({
          "jsonrpc": "2.0",
          "id": 4,
          "method": "tools/call",
          "params": {
              "name": "headroom_retrieve",
              "arguments": {"hash": compression["hash"]},
          },
      })
      retrieval = json.loads(retrieved["result"]["content"][0]["text"])
      assert retrieval["source"] == "local"
      assert retrieval["original_content"] == content
  finally:
      server.terminate()
      try:
          server.wait(timeout=10)
      except subprocess.TimeoutExpired:
          server.kill()
          server.wait()
      state_root.cleanup()
''
