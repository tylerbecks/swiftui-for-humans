#!/usr/bin/env python3
"""PostToolUse hook: lint the .swift file Claude just wrote or edited.

Reads the hook's JSON from stdin. For a .swift file, runs check_swift.py (next to this
file) at warning level and above. Findings go to stderr with exit status 2, which Claude
Code shows to Claude after the edit. Anything else, including a linter crash, exits 0 so
the hook never gets in the way.

Set SWIFTUI_LINT_TARGET (for example "iOS 17") to skip fixes your deployment target
can't use, and SWIFTUI_LINT_MIN_SEVERITY to info to include judgment calls.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0
    path = (event.get("tool_input") or {}).get("file_path") or ""
    if not path.endswith(".swift") or not Path(path).is_file():
        return 0
    cmd = [sys.executable, str(HERE / "check_swift.py"),
           "--min-severity", os.environ.get("SWIFTUI_LINT_MIN_SEVERITY", "warning")]
    if os.environ.get("SWIFTUI_LINT_TARGET"):
        cmd += ["--target", os.environ["SWIFTUI_LINT_TARGET"]]
    try:
        result = subprocess.run(cmd + [path], capture_output=True, text=True, timeout=25)
    except (OSError, subprocess.TimeoutExpired):
        return 0
    if result.returncode != 1 or not result.stdout.strip():
        return 0
    print("SwiftUI for Humans linter found outdated APIs or HIG smells in the file you just edited. "
          "Fix them, or add `// check-swift:ignore <id>` with a reason if one is deliberate:", file=sys.stderr)
    print(result.stdout.strip(), file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
