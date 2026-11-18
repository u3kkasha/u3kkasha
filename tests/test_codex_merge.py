# /// script
# dependencies = ["tomlkit"]
# ///

import subprocess
import sys
import tempfile
from pathlib import Path

import tomlkit


def load_toml(path: Path):
    with path.open(encoding="utf-8") as stream:
        return tomlkit.load(stream)


def run_merge(script: Path, base: Path, current: Path, *, success: bool) -> None:
    result = subprocess.run(
        [sys.executable, str(script), str(base), str(current)],
        capture_output=True,
        check=False,
        text=True,
    )
    assert (result.returncode == 0) is success, result.stderr


def main() -> None:
    script = Path(sys.argv[1])
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        base = root / "base.toml"
        current = root / "config.toml"

        base.write_text(
            '[mcp_servers.managed]\ncommand = "/nix/store/server/bin/mcp"\n',
            encoding="utf-8",
        )
        current.write_text(
            'model = "user-choice"\n'
            '[user_preferences]\ncolor = "blue"\n'
            '[mcp_servers.stale]\ncommand = "npx"\n',
            encoding="utf-8",
        )
        run_merge(script, base, current, success=True)
        merged = load_toml(current)
        assert merged["model"] == "user-choice"
        assert merged["user_preferences"]["color"] == "blue"
        assert list(merged["mcp_servers"]) == ["managed"]
        assert merged["mcp_servers"]["managed"]["command"] == "/nix/store/server/bin/mcp"

        base.write_text('model = "user-choice"\n', encoding="utf-8")
        current.write_text(
            'model = "another-choice"\n[mcp_servers.stale]\ncommand = "npx"\n',
            encoding="utf-8",
        )
        run_merge(script, base, current, success=True)
        merged = load_toml(current)
        assert merged["model"] == "another-choice"
        assert "mcp_servers" not in merged

        base.write_text("this is not valid TOML = [\n", encoding="utf-8")
        original = current.read_bytes()
        run_merge(script, base, current, success=False)
        assert current.read_bytes() == original


if __name__ == "__main__":
    main()
