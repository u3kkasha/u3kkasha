# Contract: Headroom MCP Server

- Server name: `headroom`
- Transport: stdio
- Command: immutable full Headroom package executable
- Arguments: `mcp`, `serve`
- Required credentials/listener: none
- Required tools: `headroom_compress`, `headroom_retrieve`, `headroom_stats`

The process must initialize without a proxy, list all required tools, compress a sufficiently large
supported input, and retrieve the exact original by returned hash. Diagnostic output must not
corrupt protocol output. Every enabled client receives an equivalent native representation on both
hosts. Package or linkage failure is fatal; no runtime installer or downloader may be substituted.
