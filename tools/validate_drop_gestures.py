#!/usr/bin/env python3
"""Validate the drag & drop gesture contract.

Locks the three pieces that make the in-game gesture work end to end. Each of
these was a real, user-visible failure ("el drop no funciona"):

1. Dragging a worn piece out of an equip slot must unequip when released
   anywhere on the items panel -- not only pixel-perfect on a tile. The panel
   background forwards slot-sourced drops to unequip_slot.
2. The testing-scene guide overlay sits on CanvasLayer 20, ABOVE the inventory
   (layer 5). Every control in it must be click-through (IGNORE), or it
   swallows clicks and drags over the item grid.
3. The attack input reads the raw action, so it must be gated on
   inventory_open -- otherwise every click on the inventory UI (selecting a
   tile, starting a drag) also swings in the world behind the menu.

Read-only source check: these are wiring facts a headless run cannot exercise
(GUI hit-testing needs a real window), so they are pinned here instead.
"""

from __future__ import annotations

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]

# (file, fragment, why it must stay)
PINNED = [
    (
        "scripts/player_inventory_ui.gd",
        "inventory_grid_panel.set_drag_forwarding(Callable(), _can_drop_unequip_on_items_panel, _drop_unequip_on_items_panel)",
        "items panel background accepts slot-sourced drops (drag-out unequip)",
    ),
    (
        "scripts/player_inventory_ui.gd",
        'return str(drop.get("source", "")) == "slot" and str(drop.get("slot", "")) != ""',
        "panel drop target only accepts pieces dragged out of an equip slot",
    ),
    (
        "scripts/player_inventory_ui.gd",
        'unequip_slot(str((data as Dictionary).get("slot", "")))',
        "dropping a worn piece on the items panel unequips its slot",
    ),
    (
        "scripts/ui_bone_item.gd",
        'return typeof(data) == TYPE_DICTIONARY and data.get("source", "") == "slot"',
        "filled tiles keep accepting drag-out drops",
    ),
    (
        "scripts/ui_inventory_empty_slot.gd",
        'return drop.get("source", "") == "slot" and drop.get("slot", "") != ""',
        "empty placeholder tiles keep accepting drag-out drops",
    ),
    (
        "scripts/testing_environment.gd",
        "panel.mouse_filter = Control.MOUSE_FILTER_IGNORE",
        "guide overlay panel is click-through",
    ),
    (
        "scripts/testing_environment.gd",
        "margin.mouse_filter = Control.MOUSE_FILTER_IGNORE",
        "guide overlay margin is click-through",
    ),
    (
        "scripts/testing_environment.gd",
        "content.mouse_filter = Control.MOUSE_FILTER_IGNORE",
        "guide overlay content column is click-through",
    ),
    (
        "scripts/player.gd",
        'if _input_just_pressed("attack") and not inventory_open and not detached_torso_reattaching and not _is_backstab_executing():',
        "attack input is gated while the inventory is open",
    ),
    (
        "scripts/player_inventory_ui.gd",
        "hover_info_label.text = reason",
        "a refused equip shows its reason in the details panel (was console-only)",
    ),
    (
        "scripts/player_inventory_ui.gd",
        "inventory_details_scroll = ScrollContainer.new()",
        "details panel has fixed height with internal scroll (no layout jumps)",
    ),
    (
        "scripts/ui_bone_item.gd",
        'player.call_deferred("drop_bone", bone_id)',
        "right-click on a tile drops the piece, DEFERRED so the grid rebuild "
        "cannot free the tile mid-dispatch (one click once dropped three bones)",
    ),
    (
        "scripts/ui_bone_item.gd",
        'player.call_deferred("equip_bone", bone_id)',
        "double-click equip is deferred for the same freed-mid-dispatch reason",
    ),
    (
        "scripts/player.gd",
        "if not inventory_component.can_remove_bone(instance_id):",
        "the drop-to-ground path honours the lock gate",
    ),
]


def main() -> int:
    failures: list[str] = []
    for rel_path, fragment, why in PINNED:
        source = (ROOT / rel_path).read_text(encoding="utf-8")
        if fragment not in source:
            failures.append(f"{rel_path}: missing pinned fragment ({why}):\n    {fragment}")

    if failures:
        print("DROP GESTURES: FAIL")
        for failure in failures:
            print("  " + failure)
        return 1

    print(f"DROP GESTURES: PASS ({len(PINNED)} pinned fragments)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
