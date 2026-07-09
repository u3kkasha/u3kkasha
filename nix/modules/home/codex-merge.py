#!/usr/bin/env python3

import os
import sys
import tempfile

import tomlkit


def merge(base_file: str, current_file: str) -> None:
    with open(base_file, encoding="utf-8") as stream:
        base = tomlkit.load(stream)

    with open(current_file, encoding="utf-8") as stream:
        current = tomlkit.load(stream)

    if "mcp_servers" in base:
        current["mcp_servers"] = base["mcp_servers"]
    else:
        current.pop("mcp_servers", None)

    file_descriptor, temporary_file = tempfile.mkstemp(
        dir=os.path.dirname(current_file),
        prefix=".config.toml.",
    )
    try:
        with os.fdopen(file_descriptor, "w", encoding="utf-8") as stream:
            tomlkit.dump(current, stream)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary_file, 0o600)
        os.replace(temporary_file, current_file)
    finally:
        if os.path.exists(temporary_file):
            os.unlink(temporary_file)


if __name__ == "__main__":
    merge(*sys.argv[1:])
