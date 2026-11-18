# /// script
# dependencies = []
# ///

import os
import subprocess
import sys
import tempfile
from pathlib import Path


ARGUMENTS = ["--option", "two words"]
ORIGINAL_CONFIG = "experimental-features = nix-command"
INJECTED_CONFIG = f"{ORIGINAL_CONFIG}\naccess-tokens = github.com=test-token"


def run_case(shell: str, wrapper: str, mode: str, temporary: Path) -> None:
    bin_dir = temporary / "bin"
    bin_dir.mkdir()
    gh = bin_dir / "gh"
    gh.write_text(
        "#!/bin/sh\n"
        'test "$1 $2" = "auth token" || exit 64\n'
        'case "$GH_MODE" in\n'
        '  token) printf "test-token\\n" ;;\n'
        '  empty) printf "  \\n" ;;\n'
        '  fail) exit 42 ;;\n'
        '  *) exit 64 ;;\n'
        "esac\n",
        encoding="utf-8",
    )
    gh.chmod(0o755)

    nix = bin_dir / "nix"
    nix.write_text(
        "#!/bin/sh\n"
        'printf "%s\\0" "$@" > "$NIX_ARGS_FILE"\n'
        'printf "%s" "${NIX_CONFIG-}" > "$NIX_CONFIG_FILE"\n',
        encoding="utf-8",
    )
    nix.chmod(0o755)

    caller_config = temporary / "caller-config"
    args_file = temporary / "args"
    child_config = temporary / "child-config"
    environment = os.environ | {
        "PATH": f"{bin_dir}:{os.environ['PATH']}",
        "WRAPPER": wrapper,
        "GH_MODE": mode,
        "NIX_CONFIG": ORIGINAL_CONFIG,
        "CALLER_CONFIG_FILE": str(caller_config),
        "NIX_ARGS_FILE": str(args_file),
        "NIX_CONFIG_FILE": str(child_config),
    }

    if shell == "bash":
        script = (
            'source "$WRAPPER"; nix --option "two words"; '
            'printf "%s" "${NIX_CONFIG-}" > "$CALLER_CONFIG_FILE"'
        )
        command = [os.environ["BASH"], "--noprofile", "--norc", "-c", script]
    else:
        script = (
            f'source "{wrapper}"; nix --option "two words"; '
            '($env.NIX_CONFIG? | default "") | save --raw --force $env.CALLER_CONFIG_FILE'
        )
        command = [os.environ["NU"], "--no-config-file", "-c", script]

    result = subprocess.run(command, env=environment, capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert args_file.read_bytes().split(b"\0")[:-1] == [b"--option", b"two words"]
    assert child_config.read_text(encoding="utf-8") == (
        INJECTED_CONFIG if mode == "token" else ORIGINAL_CONFIG
    )
    assert caller_config.read_text(encoding="utf-8") == ORIGINAL_CONFIG


def main() -> None:
    wrappers = {
        "bash": os.environ["BASH_WRAPPER"],
        "nu": os.environ["NU_WRAPPER"],
    }
    for shell, wrapper in wrappers.items():
        for mode in ("token", "empty", "fail"):
            with tempfile.TemporaryDirectory() as directory:
                run_case(shell, wrapper, mode, Path(directory))


if __name__ == "__main__":
    main()
