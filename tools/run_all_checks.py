#!/usr/bin/env python3
"""Run every automated check in the repository with a single command.

Two families of checks live in `tools/`, and until now each one had to be
invoked by hand, one line at a time:

  - `validate_*.py`      static contract validators, plain Python.
  - `headless_*_check.gd` behaviour checks, run by Godot with no window.

Both are discovered from disk rather than listed here on purpose: adding a
check should mean adding a file, not editing this runner and remembering to.

    python tools/run_all_checks.py

Exit code is 0 only when every check passed, so this is the single command CI
runs on a pull request.

Finding Godot: the engine is usually not on PATH on a developer machine. The
runner looks, in order, at `--godot`, `$GODOT_BIN`, then the usual names on
PATH. Set it once per machine instead of passing it every time:

    Windows   setx GODOT_BIN "C:\\path\\to\\Godot_v4.7-stable_win64_console.exe"
    Linux/mac export GODOT_BIN=/path/to/godot

On Windows use the *console* build. The plain `.exe` detaches from the terminal
and returns before the check has finished, so its exit code means nothing.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"

# Names a Godot 4 binary is plausibly installed under. The console build comes
# first: on Windows it is the only one whose exit code can be trusted.
GODOT_CANDIDATES = (
    "godot4",
    "godot",
    "Godot_v4.7-stable_win64_console.exe",
    "Godot_v4.7-stable_win64.exe",
)

DEFAULT_TIMEOUT = 300

PASS = "PASS"
FAIL = "FAIL"
SKIP = "SKIP"


@dataclass
class Check:
    name: str
    kind: str  # "validator" | "headless"
    path: Path


@dataclass
class Result:
    check: Check
    status: str
    seconds: float
    exit_code: int | None
    output: str
    note: str = ""


def discover() -> list[Check]:
    """Every check on disk, validators first because they are the fast ones.

    Running the cheap static checks before spinning up an engine means a typo in
    a data file is reported in a second instead of after the full suite.
    """
    checks: list[Check] = []
    for path in sorted(TOOLS.glob("validate_*.py")):
        checks.append(Check(path.stem, "validator", path))
    for path in sorted(TOOLS.glob("headless_*_check.gd")):
        checks.append(Check(path.stem, "headless", path))
    return checks


def resolve_godot(explicit: str | None) -> tuple[str | None, str]:
    """Locate a Godot binary. Returns (path, how_it_was_found)."""
    if explicit:
        resolved = shutil.which(explicit) or (explicit if Path(explicit).is_file() else None)
        if resolved is None:
            return None, f"--godot {explicit} is not an executable"
        return resolved, "--godot"

    from_env = os.environ.get("GODOT_BIN", "").strip()
    if from_env:
        resolved = shutil.which(from_env) or (from_env if Path(from_env).is_file() else None)
        if resolved is None:
            return None, f"$GODOT_BIN points at {from_env}, which is not an executable"
        return resolved, "$GODOT_BIN"

    for candidate in GODOT_CANDIDATES:
        resolved = shutil.which(candidate)
        if resolved:
            return resolved, f"PATH ({candidate})"

    return None, "not found in --godot, $GODOT_BIN or PATH"


def command_for(check: Check, godot: str | None) -> list[str]:
    if check.kind == "validator":
        return [sys.executable, str(check.path)]
    # --path keeps the engine anchored to the project so autoloads and res://
    # resolve; the script itself is passed project-relative, as the docs do.
    return [str(godot), "--headless", "--path", str(ROOT), "--script", f"tools/{check.path.name}"]


def run(check: Check, godot: str | None, timeout: int) -> Result:
    started = time.monotonic()
    try:
        completed = subprocess.run(
            command_for(check, godot),
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
        )
    except subprocess.TimeoutExpired as expired:
        elapsed = time.monotonic() - started
        partial = (expired.stdout or "") + (expired.stderr or "")
        if isinstance(partial, bytes):
            partial = partial.decode("utf-8", "replace")
        return Result(check, FAIL, elapsed, None, partial, f"timed out after {timeout}s")

    elapsed = time.monotonic() - started
    output = completed.stdout + completed.stderr
    status = PASS if completed.returncode == 0 else FAIL

    # Godot can report a script error and still exit 0. That is not a failure we
    # invent here -- the check's own verdict stands -- but it is worth surfacing,
    # because it usually means part of the check never ran.
    note = ""
    if status == PASS and "SCRIPT ERROR" in output:
        note = "passed, but the engine logged SCRIPT ERROR"

    return Result(check, status, elapsed, completed.returncode, output, note)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run every validator and headless check in tools/.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--godot", help="path to the Godot binary (overrides $GODOT_BIN and PATH)")
    parser.add_argument("--only", metavar="TEXT", help="run only checks whose name contains TEXT")
    parser.add_argument("--validators", action="store_true", help="run only the Python validators")
    parser.add_argument("--headless", action="store_true", help="run only the Godot headless checks")
    parser.add_argument("--list", action="store_true", help="list the checks that would run, then exit")
    parser.add_argument("--verbose", action="store_true", help="print the output of passing checks too")
    parser.add_argument(
        "--skip-missing-godot",
        action="store_true",
        help="report headless checks as SKIP instead of failing when Godot is unavailable",
    )
    parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT, help=f"seconds per check (default {DEFAULT_TIMEOUT})")
    args = parser.parse_args()

    checks = discover()
    if args.validators and not args.headless:
        checks = [c for c in checks if c.kind == "validator"]
    if args.headless and not args.validators:
        checks = [c for c in checks if c.kind == "headless"]
    if args.only:
        needle = args.only.lower()
        checks = [c for c in checks if needle in c.name.lower()]

    if not checks:
        print("No checks matched.", file=sys.stderr)
        return 1

    if args.list:
        for check in checks:
            print(f"{check.kind:9}  {check.name}")
        print(f"\n{len(checks)} check(s).")
        return 0

    needs_godot = any(c.kind == "headless" for c in checks)
    godot, how = resolve_godot(args.godot)
    if needs_godot and godot is None:
        message = f"Godot binary {how}."
        if not args.skip_missing_godot:
            print(f"ERROR: {message}", file=sys.stderr)
            print("Set GODOT_BIN or pass --godot. See the header of this file.", file=sys.stderr)
            return 1
        print(f"WARNING: {message} Headless checks will be skipped.\n")

    validators = sum(1 for c in checks if c.kind == "validator")
    headless = len(checks) - validators
    print(f"MARROW checks: {validators} validator(s), {headless} headless check(s)")
    if needs_godot and godot:
        print(f"Godot: {godot}  [{how}]")
    print()

    results: list[Result] = []
    width = max(len(c.name) for c in checks)
    started = time.monotonic()

    for index, check in enumerate(checks, start=1):
        prefix = f"[{index:>2}/{len(checks)}] {check.name:<{width}}"
        if check.kind == "headless" and godot is None:
            results.append(Result(check, SKIP, 0.0, None, "", "no Godot binary"))
            print(f"{prefix}  SKIP")
            continue

        print(f"{prefix}  ...", end="", flush=True)
        result = run(check, godot, args.timeout)
        results.append(result)
        print(f"\r{prefix}  {result.status}  {result.seconds:5.1f}s"
              + (f"  ({result.note})" if result.note else ""))

        if result.status == FAIL or args.verbose:
            body = result.output.strip()
            if body:
                print("".join(f"    | {line}\n" for line in body.splitlines()), end="")
            print()

    total = time.monotonic() - started
    passed = [r for r in results if r.status == PASS]
    failed = [r for r in results if r.status == FAIL]
    skipped = [r for r in results if r.status == SKIP]

    print("-" * (width + 24))
    print(f"{len(passed)} passed, {len(failed)} failed, {len(skipped)} skipped in {total:.1f}s")

    if failed:
        print("\nFailed:")
        for result in failed:
            detail = result.note or f"exit {result.exit_code}"
            print(f"  - {result.check.name} ({detail})")

    warned = [r for r in results if r.note and r.status == PASS]
    if warned:
        print("\nPassed with warnings:")
        for result in warned:
            print(f"  - {result.check.name}: {result.note}")

    # A skip is not a pass. Reporting green while a third of the suite never ran
    # is exactly the failure mode this runner exists to remove.
    return 1 if failed or skipped else 0


if __name__ == "__main__":
    sys.exit(main())
