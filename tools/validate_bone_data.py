#!/usr/bin/env python3
"""Read-only validation for Marrow BoneDefinition resources."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


CANONICAL_SLOTS = {"head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"}
# Mirrors EquipmentRulesService.LEGACY_SLOT_ALIASES. Only aliases with a real
# consumer in data/bones/*.tres belong here (verified by grep across
# scripts/, data/, docs/); do not add speculative aliases back.
LEGACY_SLOT_ALIASES = {
    "body": "torso",
    "legs": "right_leg",
}
VALID_SLOTS = CANONICAL_SLOTS | set(LEGACY_SLOT_ALIASES)
VALID_WEIGHT_CLASSES = {"light", "medium", "heavy"}
REQUIRED_RESOURCE_FIELDS = {
    "bone_id",
    "display_name",
    "quality",
    "quality_rank",
    "quality_score",
    "quality_multiplier",
    "rarity",
    "rarity_rank",
    "rarity_drop_weight",
    "durability_max",
    "durability_start",
    "durability_repair_cost",
    "durability_tags",
    "slot",
    "description",
    "weight",
    "weight_class",
    "physical_weight",
    "equipment_weight",
    "inventory_weight",
}


@dataclass(frozen=True)
class TresResource:
    path: Path
    header: str
    fields: dict[str, str]


class ValidationReport:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warning(self, message: str) -> None:
        self.warnings.append(message)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate BoneDefinition .tres resources and catalog paths."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Project root. Defaults to the parent of tools/.",
    )
    args = parser.parse_args()

    root = args.root.resolve()
    report = ValidationReport()

    catalog_path = root / "scripts" / "bone_data_catalog.gd"
    definition_path = root / "scripts" / "bone_definition.gd"
    bones_dir = root / "data" / "bones"

    resource_paths = parse_resource_paths(catalog_path)
    fallback_ids = parse_catalog_definition_ids(catalog_path)
    constants = parse_definition_constants(definition_path)
    resources = load_tres_resources(bones_dir)

    rules_path = root / "scripts" / "equipment_rules_service.gd"
    rules_text = rules_path.read_text(encoding="utf-8")

    validate_catalog_paths(root, resource_paths, resources, report)
    validate_resource_files(resource_paths, resources, constants, report)
    validate_fallback_overlap(resource_paths, fallback_ids, report)
    validate_equipment_slot_contract(rules_text, report)

    print_report(report, resource_paths, fallback_ids, resources)
    return 1 if report.errors else 0


def parse_resource_paths(catalog_path: Path) -> dict[str, str]:
    text = catalog_path.read_text(encoding="utf-8")
    body = extract_const_dictionary_body(text, "RESOURCE_PATHS")
    return {
        match.group("id"): match.group("path")
        for match in re.finditer(
            r'"(?P<id>[^"]+)"\s*:\s*"(?P<path>res://[^"]+)"', body
        )
    }


def parse_catalog_definition_ids(catalog_path: Path) -> set[str]:
    text = catalog_path.read_text(encoding="utf-8")
    body = extract_const_dictionary_body(text, "DEFINITIONS")
    ids: set[str] = set()
    depth = 0
    for line in body.splitlines():
        if depth == 0:
            match = re.match(r'\s*"(?P<id>[^"]+)"\s*:\s*\{', line)
            if match:
                ids.add(match.group("id"))
        depth += dictionary_depth_delta(line)

    return ids


def dictionary_depth_delta(line: str) -> int:
    delta = 0
    in_string = False
    escaped = False
    for char in line:
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue

        if char == '"':
            in_string = True
        elif char == "{":
            delta += 1
        elif char == "}":
            delta -= 1
    return delta


def parse_definition_constants(definition_path: Path) -> dict[str, set[str]]:
    text = definition_path.read_text(encoding="utf-8")
    values: dict[str, set[str]] = {
        "quality": set(),
        "rarity": set(),
        "mutation_family": set(),
    }
    for match in re.finditer(
        r'const\s+(?P<name>[A-Z_]+)\s*:=\s*"(?P<value>[^"]*)"', text
    ):
        name = match.group("name")
        value = match.group("value")
        if name.startswith("QUALITY_"):
            values["quality"].add(value)
        elif name.startswith("RARITY_"):
            values["rarity"].add(value)
        elif name.startswith("MUTATION_"):
            values["mutation_family"].add(value)
    return values


def extract_const_dictionary_body(text: str, const_name: str) -> str:
    marker = f"const {const_name} :="
    start = text.find(marker)
    if start == -1:
        raise SystemExit(f"Missing {marker}")

    opening = text.find("{", start)
    if opening == -1:
        raise SystemExit(f"Missing opening dictionary for {const_name}")

    depth = 0
    in_string = False
    escaped = False
    for index in range(opening, len(text)):
        char = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue

        if char == '"':
            in_string = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[opening + 1 : index]

    raise SystemExit(f"Missing closing dictionary for {const_name}")


def load_tres_resources(bones_dir: Path) -> dict[Path, TresResource]:
    resources: dict[Path, TresResource] = {}
    for path in sorted(bones_dir.glob("*.tres")):
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
        header = lines[0].strip() if lines else ""
        fields: dict[str, str] = {}
        for line in lines:
            if line.startswith("[") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            fields[key.strip()] = value.strip()
        resources[path.resolve()] = TresResource(path.resolve(), header, fields)
    return resources


def validate_catalog_paths(
    root: Path,
    resource_paths: dict[str, str],
    resources: dict[Path, TresResource],
    report: ValidationReport,
) -> None:
    seen_paths: dict[Path, str] = {}
    for bone_id, res_path in sorted(resource_paths.items()):
        if not res_path.startswith("res://data/bones/"):
            report.error(
                f"{bone_id}: catalog path must stay under res://data/bones/: {res_path}"
            )
            continue

        absolute_path = (root / res_path.removeprefix("res://")).resolve()
        if absolute_path in seen_paths:
            report.error(
                f"{bone_id}: catalog path duplicates {seen_paths[absolute_path]}: {res_path}"
            )
        seen_paths[absolute_path] = bone_id

        if absolute_path not in resources:
            report.error(f"{bone_id}: catalog path does not exist: {res_path}")

    referenced_paths = set(seen_paths)
    for path in sorted(resources):
        if path not in referenced_paths:
            report.error(
                f"{relative(path, root)}: .tres file is not referenced by RESOURCE_PATHS"
            )


def validate_resource_files(
    resource_paths: dict[str, str],
    resources: dict[Path, TresResource],
    constants: dict[str, set[str]],
    report: ValidationReport,
) -> None:
    id_to_path: dict[str, Path] = {}
    uid_to_path: dict[str, Path] = {}
    path_by_catalog_id = {
        Path(res_path.removeprefix("res://")).name: bone_id
        for bone_id, res_path in resource_paths.items()
    }

    for resource in resources.values():
        label = resource.path.name
        fields = resource.fields

        if 'script_class="BoneDefinition"' not in resource.header:
            report.error(f"{label}: header must declare script_class=\"BoneDefinition\"")
        if fields.get("script") != 'ExtResource("1_bonedef")':
            report.error(f"{label}: script must reference res://scripts/bone_definition.gd")

        uid_match = re.search(r'uid="(?P<uid>[^"]+)"', resource.header)
        if uid_match:
            uid = uid_match.group("uid")
            if uid in uid_to_path:
                report.error(f"{label}: uid duplicates {uid_to_path[uid].name}: {uid}")
            uid_to_path[uid] = resource.path
        else:
            report.warning(f"{label}: resource has no uid in header")

        missing = sorted(REQUIRED_RESOURCE_FIELDS - set(fields))
        if missing:
            report.error(f"{label}: missing required fields: {', '.join(missing)}")

        bone_id = string_value(fields.get("bone_id", ""))
        if not bone_id:
            report.error(f"{label}: bone_id cannot be empty")
        elif bone_id in id_to_path:
            report.error(
                f"{label}: bone_id duplicates {id_to_path[bone_id].name}: {bone_id}"
            )
        else:
            id_to_path[bone_id] = resource.path

        expected_id = path_by_catalog_id.get(label)
        if expected_id and bone_id != expected_id:
            report.error(
                f"{label}: bone_id {bone_id!r} does not match catalog id {expected_id!r}"
            )

        validate_identity_fields(label, fields, constants, report)
        validate_numeric_fields(label, fields, report)
        validate_durability_fields(label, fields, report)
        validate_synergy_fields(label, fields, report)


def validate_identity_fields(
    label: str,
    fields: dict[str, str],
    constants: dict[str, set[str]],
    report: ValidationReport,
) -> None:
    display_name = string_value(fields.get("display_name", ""))
    description = string_value(fields.get("description", ""))
    quality = string_value(fields.get("quality", ""))
    rarity = string_value(fields.get("rarity", ""))
    slot = string_value(fields.get("slot", ""))
    mutation_family = string_value(fields.get("mutation_family", '""'))
    weight_class = string_value(fields.get("weight_class", ""))

    if not display_name:
        report.error(f"{label}: display_name cannot be empty")
    if not description:
        report.warning(f"{label}: description is empty")
    if quality not in constants["quality"]:
        report.error(f"{label}: unknown quality {quality!r}")
    if rarity not in constants["rarity"]:
        report.error(f"{label}: unknown rarity {rarity!r}")
    if slot not in VALID_SLOTS:
        report.error(f"{label}: unknown slot {slot!r}")
    elif slot in LEGACY_SLOT_ALIASES:
        report.warning(
            f"{label}: legacy slot {slot!r} must normalize to {LEGACY_SLOT_ALIASES[slot]!r}"
        )
    if mutation_family not in constants["mutation_family"]:
        report.error(f"{label}: unknown mutation_family {mutation_family!r}")
    if weight_class not in VALID_WEIGHT_CLASSES:
        report.error(f"{label}: unknown weight_class {weight_class!r}")


def validate_numeric_fields(
    label: str, fields: dict[str, str], report: ValidationReport
) -> None:
    positive_fields = ["quality_score", "quality_multiplier"]
    non_negative_fields = [
        "quality_rank",
        "rarity_rank",
        "rarity_drop_weight",
        "durability_max",
        "durability_start",
        "durability_repair_cost",
        "weight",
        "physical_weight",
        "equipment_weight",
        "inventory_weight",
        "combo_step",
        "combo_window",
        "mutation_stage",
        "synergy_score",
        "enemy_visual_scale",
    ]
    ratio_fields = ["mutation_intensity", "enemy_flee_chance"]

    for field in positive_fields:
        if field in fields and numeric_value(fields[field]) <= 0.0:
            report.error(f"{label}: {field} must be greater than 0")
    for field in non_negative_fields:
        if field in fields and numeric_value(fields[field]) < 0.0:
            report.error(f"{label}: {field} cannot be negative")
    for field in ratio_fields:
        if field in fields:
            value = numeric_value(fields[field])
            if value < 0.0 or value > 1.0:
                report.error(f"{label}: {field} must be between 0 and 1")

    if "visual_scale" in fields:
        validate_vector3_positive(label, "visual_scale", fields["visual_scale"], report)
    if "hitbox_scale" in fields:
        validate_vector3_positive(label, "hitbox_scale", fields["hitbox_scale"], report)


def validate_durability_fields(
    label: str, fields: dict[str, str], report: ValidationReport
) -> None:
    maximum = int(numeric_value(fields.get("durability_max", "0")))
    start = int(numeric_value(fields.get("durability_start", "0")))
    repair_cost = int(numeric_value(fields.get("durability_repair_cost", "0")))

    if maximum <= 0:
        report.error(f"{label}: durability_max must be greater than 0")
    if start <= 0:
        report.error(f"{label}: durability_start must be greater than 0")
    if start > maximum:
        report.error(f"{label}: durability_start cannot exceed durability_max")
    if repair_cost < 0:
        report.error(f"{label}: durability_repair_cost cannot be negative")
    if "durability_tags" in fields and not fields["durability_tags"].startswith("Array[String]("):
        report.error(f"{label}: durability_tags must be an Array[String]")


def validate_synergy_fields(
    label: str, fields: dict[str, str], report: ValidationReport
) -> None:
    set_id = string_value(fields.get("set_id", ""))
    set_name = string_value(fields.get("set_name", ""))
    set_piece_key = string_value(fields.get("set_piece_key", ""))
    if set_id and not set_name:
        report.error(f"{label}: set_name is required when set_id is present")
    if set_id and not set_piece_key:
        report.error(f"{label}: set_piece_key is required when set_id is present")
    if "synergy_ids" in fields and not fields["synergy_ids"].startswith("Array[String]("):
        report.error(f"{label}: synergy_ids must be an Array[String]")
    if "synergy_tags" in fields and not fields["synergy_tags"].startswith("Array[String]("):
        report.error(f"{label}: synergy_tags must be an Array[String]")


def validate_fallback_overlap(
    resource_paths: dict[str, str], fallback_ids: set[str], report: ValidationReport
) -> None:
    resource_ids = set(resource_paths)
    fallback_only = sorted(fallback_ids - resource_ids)
    if fallback_only:
        report.warning(
            "Fallback definitions without Resource paths: " + ", ".join(fallback_only)
        )


def validate_equipment_slot_contract(rules_text: str, report: ValidationReport) -> None:
    required_fragments = [
        "const SLOT_HEAD := \"head\"",
        "const SLOT_TORSO := \"torso\"",
        "const SLOT_LEFT_ARM := \"left_arm\"",
        "const SLOT_RIGHT_ARM := \"right_arm\"",
        "const SLOT_LEFT_LEG := \"left_leg\"",
        "const SLOT_RIGHT_LEG := \"right_leg\"",
        "const CANONICAL_BODY_SLOTS",
        "const LEGACY_SLOT_ALIASES",
        "static func normalize_slot_id(slot_id: String) -> String:",
        "static func compatible_slots_for_bone(bone_id: String) -> Array[String]:",
        "static func slot_sort_index(slot_id: String) -> int:",
    ]
    for fragment in required_fragments:
        if fragment not in rules_text:
            report.error(
                f"EquipmentRulesService missing canonical slot contract fragment: {fragment}"
            )


def validate_vector3_positive(
    label: str, field: str, value: str, report: ValidationReport
) -> None:
    match = re.match(r"Vector3\((?P<body>[^)]*)\)", value)
    if not match:
        report.error(f"{label}: {field} must be a Vector3 value")
        return

    parts = [part.strip() for part in match.group("body").split(",")]
    if len(parts) != 3:
        report.error(f"{label}: {field} must have 3 components")
        return

    for part in parts:
        if numeric_value(part) <= 0.0:
            report.error(f"{label}: {field} components must be greater than 0")
            return


def numeric_value(raw: str) -> float:
    try:
        return float(raw)
    except ValueError:
        raise SystemExit(f"Expected numeric value, got {raw!r}") from None


def string_value(raw: str) -> str:
    match = re.match(r'"(?P<value>.*)"$', raw)
    if match:
        return match.group("value")
    return raw


def relative(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def print_report(
    report: ValidationReport,
    resource_paths: dict[str, str],
    fallback_ids: Iterable[str],
    resources: dict[Path, TresResource],
) -> None:
    print("Bone data validation")
    print(f"- catalog resource paths: {len(resource_paths)}")
    print(f"- catalog fallback ids: {len(set(fallback_ids))}")
    print(f"- .tres resources: {len(resources)}")
    print(f"- canonical body slots: {len(CANONICAL_SLOTS)}")

    if report.warnings:
        print("\nWarnings:")
        for warning in report.warnings:
            print(f"- {warning}")

    if report.errors:
        print("\nErrors:")
        for error in report.errors:
            print(f"- {error}")
        print(f"\nFAILED: {len(report.errors)} error(s), {len(report.warnings)} warning(s)")
    else:
        print(f"\nOK: 0 errors, {len(report.warnings)} warning(s)")


if __name__ == "__main__":
    sys.exit(main())
