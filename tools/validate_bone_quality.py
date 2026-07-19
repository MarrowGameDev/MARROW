#!/usr/bin/env python3
"""Static checks for the bone quality table.

Verifies without running Godot that:
  * the five canonical qualities exist,
  * their probabilities total exactly 100,
  * every multiplier sits inside the authored 0.85..1.15 band,
  * the ladder's ranks are unique and ordered with the multipliers,
  * every pre-rename Spanish id still maps onto a canonical id,
  * quality never leaks into categorical fields.

Run: python -B tools/validate_bone_quality.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
QUALITY_SERVICE = REPO_ROOT / "scripts" / "bone_quality_service.gd"
INSTANCE_SERVICE = REPO_ROOT / "scripts" / "bone_instance_service.gd"

EXPECTED = {
    "frail": {"multiplier": 0.85, "probability": 2.5, "rank": 0},
    "worn": {"multiplier": 0.925, "probability": 12.5, "rank": 1},
    "normal": {"multiplier": 1.0, "probability": 70.0, "rank": 2},
    "strong": {"multiplier": 1.075, "probability": 12.5, "rank": 3},
    "pristine": {"multiplier": 1.15, "probability": 2.5, "rank": 4},
}

MULTIPLIER_MIN = 0.85
MULTIPLIER_MAX = 1.15


def parse_table(text: str) -> dict[str, dict[str, float]]:
    """Pull each quality entry out of QUALITY_TABLE."""
    table_match = re.search(
        r"const\s+QUALITY_TABLE\s*:=\s*\{(?P<body>.*?)\n\}", text, re.S
    )
    if not table_match:
        return {}

    body = table_match.group("body")
    entries: dict[str, dict[str, float]] = {}
    # Entries are keyed by the QUALITY_* constant, so resolve those first.
    consts = dict(
        re.findall(r'const\s+(QUALITY_[A-Z_]+)\s*:=\s*"([^"]+)"', text)
    )
    for match in re.finditer(
        r"(?P<key>QUALITY_[A-Z_]+)\s*:\s*\{(?P<fields>.*?)\}", body, re.S
    ):
        quality_id = consts.get(match.group("key"))
        if quality_id is None:
            continue
        fields: dict[str, float] = {}
        for field, value in re.findall(
            r'"(\w+)"\s*:\s*(-?\d+(?:\.\d+)?)', match.group("fields")
        ):
            fields[field] = float(value)
        entries[quality_id] = fields
    return entries


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    if not QUALITY_SERVICE.exists():
        print(f"FAILED: missing {QUALITY_SERVICE}")
        return 1

    text = QUALITY_SERVICE.read_text(encoding="utf-8")
    table = parse_table(text)

    if not table:
        print("FAILED: could not parse QUALITY_TABLE")
        return 1

    missing = set(EXPECTED) - set(table)
    if missing:
        errors.append(f"missing qualities: {sorted(missing)}")
    extra = set(table) - set(EXPECTED)
    if extra:
        warnings.append(f"qualities beyond the specified five: {sorted(extra)}")

    total = 0.0
    for quality_id, expected in EXPECTED.items():
        entry = table.get(quality_id)
        if entry is None:
            continue
        for field, want in expected.items():
            got = entry.get(field)
            if got is None:
                errors.append(f"{quality_id}: missing {field}")
            elif abs(got - want) > 1e-9:
                errors.append(f"{quality_id}: {field} is {got}, expected {want}")

    for quality_id, entry in table.items():
        probability = entry.get("probability", 0.0)
        total += probability
        multiplier = entry.get("multiplier", 1.0)
        if not (MULTIPLIER_MIN - 1e-9 <= multiplier <= MULTIPLIER_MAX + 1e-9):
            errors.append(
                f"{quality_id}: multiplier {multiplier} outside "
                f"{MULTIPLIER_MIN}..{MULTIPLIER_MAX}"
            )
        if probability < 0:
            errors.append(f"{quality_id}: negative probability {probability}")

    if abs(total - 100.0) > 1e-9:
        errors.append(f"probabilities total {total}, expected exactly 100")

    ranks = [(entry.get("rank", -1), qid) for qid, entry in table.items()]
    if len({rank for rank, _ in ranks}) != len(ranks):
        errors.append("duplicate quality ranks")
    # A higher rank must never be worth less than a lower one.
    ordered = [qid for _, qid in sorted(ranks)]
    multipliers = [table[qid].get("multiplier", 1.0) for qid in ordered]
    if multipliers != sorted(multipliers):
        errors.append(
            f"multipliers are not monotonic with rank: {list(zip(ordered, multipliers))}"
        )

    aliases = re.search(
        r"const\s+LEGACY_QUALITY_ALIASES\s*:=\s*\{(?P<body>[^}]*)\}", text, re.S
    )
    if not aliases:
        errors.append("LEGACY_QUALITY_ALIASES missing: pre-rename data would break")
    else:
        mapped = re.findall(
            r'"(?P<legacy>[^"]+)"\s*:\s*(?P<target>QUALITY_[A-Z_]+)', aliases.group("body")
        )
        consts = dict(re.findall(r'const\s+(QUALITY_[A-Z_]+)\s*:=\s*"([^"]+)"', text))
        for legacy, target in mapped:
            resolved = consts.get(target)
            if resolved not in EXPECTED:
                errors.append(f"legacy alias {legacy} maps to unknown {target}")
        for legacy in ("chatarra", "fragil", "comun", "fuerte", "legendario"):
            if legacy not in {pair[0] for pair in mapped}:
                errors.append(f"legacy quality id {legacy!r} lost its alias")

    # Quality must not be encoded into instance identity.
    if INSTANCE_SERVICE.exists():
        instance_text = INSTANCE_SERVICE.read_text(encoding="utf-8")
        prefix = re.search(r'const\s+INSTANCE_PREFIX\s*:=\s*"([^"]+)"', instance_text)
        if prefix is None:
            errors.append("INSTANCE_PREFIX missing")
        for quality_id in EXPECTED:
            if re.search(rf'INSTANCE_PREFIX\s*\+.*{quality_id}', instance_text):
                errors.append(
                    f"instance ids appear to embed the quality {quality_id!r}; "
                    "identity, definition and quality must stay separate"
                )
        if "quality_multiplier" in instance_text or '"multiplier"' in instance_text:
            errors.append(
                "the instance record stores a multiplier; it must be derived "
                "from the quality table instead"
            )

    print("Bone quality table")
    print(f"- qualities: {len(table)}")
    print(f"- probability total: {total}")
    for quality_id in sorted(table, key=lambda q: table[q].get("rank", 0)):
        entry = table[quality_id]
        print(
            f"  {quality_id:<9} x{entry.get('multiplier')}  "
            f"{entry.get('probability')}%  rank {int(entry.get('rank', 0))}"
        )

    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print(f"- {warning}")

    if errors:
        print("\nErrors:")
        for error in errors:
            print(f"- {error}")
        print(f"\nFAILED: {len(errors)} error(s)")
        return 1

    print("\nPASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
