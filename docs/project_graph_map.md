# Marrow Project Graph Map

This file exists so Graphify can index the current Godot/GDScript architecture.
The local Graphify extractor does not currently parse `.gd` files as code in
this workspace, so this map mirrors the important script relationships.

## Runtime Entry

`project.godot` runs `scenes/main_menu.tscn`.

`scenes/main_menu.tscn` can open:
- `scenes/main.tscn`
- `scenes/testing_environment.tscn`

`project.godot` autoloads `GameEvents` from `scripts/game_events.gd`.

## GameEvents

`GameEvents` is the global gameplay event bus.

Signals:
- `bone_collected(bone_id, collector)`
- `bone_equipped(bone_id, slot, player)`
- `bone_unequipped(bone_id, slot, player)`
- `inventory_changed(player, items, stats)`
- `inventory_open_changed(player, is_open)`
- `pickup_focus_changed(pickup, bone_id, player, in_range)`
- `pickup_collected(bone_id, pickup, collector)`
- `drop_spawned(bone_id, pickup, source)`
- `enemy_defeated(enemy, dropped_bone_id)`
- `player_died(player)`
- `trial_completed(trial_id, trial_name)`
- `exit_reached(player)`
- `stage_entered(stage)`
- `stage_exited(stage)`
- `objective_updated(source, objective_id, title, body)`
- `tutorial_hint_requested(source, hint_id, text, priority)`
- `camp_state_changed(camp, unlocked, opened, remaining_enemies)`
- `camp_chest_opened(camp, reward_bone_id, player)`

Event relationships:
- `Player.collect_bone` emits `GameEvents.bone_collected`.
- `Player.equip_bone` emits `GameEvents.bone_equipped`.
- `Player.unequip_slot` emits `GameEvents.bone_unequipped`.
- `Player._die_player` emits `GameEvents.player_died`.
- `BoneTrialGate._try_complete_with` emits `GameEvents.trial_completed`.
- `ExitPortal._reach_exit` emits `GameEvents.exit_reached`.
- `OpenWorldStage._on_body_entered` emits `GameEvents.stage_entered`.
- `OpenWorldStage._on_body_exited` emits `GameEvents.stage_exited`.
- `DemoEnemyCamp._open_chest` emits `GameEvents.camp_chest_opened`.
- `ArenaGoalManager` listens to `trial_completed`, `exit_reached`, and `player_died`.
- `WorldMapManager` listens to `stage_entered` and `stage_exited`.

## Player

`scripts/player.gd` owns player movement, combat input, inventory state,
equipment state, health state, and the inventory UI.

Important state:
- `bone_inventory` stores collected bone ids and allows duplicate ids as separate carried copies.
- `equipped` maps equipment slots to bone ids.
- `slot_widgets` maps UI slot names to `BoneSlotWidget` instances.
- `items_grid` contains `BoneItemTile` instances.
- `inventory_preview_rig` shows equipped bones in the inventory preview.

Important methods:
- `_physics_process` handles movement, inventory toggle, category cycling, and Q equip.
- `collect_bone` adds a bone to the inventory and emits `bone_collected`.
- `equip_bone` equips a bone in its database slot, recalculates stats, syncs preview, and emits `bone_equipped` only when the equipped slot changes.
- `unequip_slot` clears a slot, recalculates stats, syncs preview, and emits `bone_unequipped`.
- `_recalculate_stats` applies all equipped bone bonuses.
- `_build_inventory_ui` builds the full inventory screen.
- `_build_paper_doll` lays out the character preview and equipment slots.
- `_sync_inventory_preview` mirrors `equipped` into `ModularSkeletonRig`.

Player relationships:
- `Player` reads definitions from `BoneDatabase`.
- `Player` uses `BoneItemTile` for draggable inventory tiles.
- `Player` uses `BoneSlotWidget` for droppable equipment slots.
- `Player` uses `ModularSkeletonRig` for visual equipment.
- `Player` uses `ProceduralPlayerAnimator` for socket animation.
- `Player` uses `PlayerCameraController` for third-person mouse look.
- `Player` owns inventory and equipment rules; `PlayerInventoryUI` owns inventory presentation.
- `Player` spawns `AttackHitbox` for attacks.

## Player Camera

`scripts/player_camera_controller.gd` defines `PlayerCameraController`.

`PlayerCameraController`:
- lives on `Player/CameraPivot`.
- keeps `CameraPivot` as a top-level visual pivot that follows the player position.
- uses `Player/CameraPivot/SpringArm3D` for zoom distance and camera collision.
- uses `Player/CameraPivot/SpringArm3D/Camera3D` as the active camera.
- captures and hides the mouse during gameplay.
- supports Escape to release the mouse and click to recapture it.
- releases and shows the mouse while inventory is open.
- rotates camera yaw/pitch from `InputEventMouseMotion`.
- clamps pitch between configurable min/max angles.
- zooms with the mouse wheel between configurable min/max distances.
- smooths pivot follow and zoom distance in `_process`.
- exposes flat camera forward/right vectors for camera-relative movement.

`Player`:
- asks `PlayerCameraController` to capture/release mouse when inventory opens or closes.
- uses camera-relative movement so WASD follows the camera direction.
- uses camera forward for attacks while the player is standing still.
- freezes camera look while the inventory is open by releasing the mouse through the camera controller.

## Bone Data

`scripts/bone_data_catalog.gd` is the clean authoring source for hand-authored
bone definitions.

`scripts/bone_database.gd` is the compatibility API. It normalizes catalog data
into the flat fields current gameplay systems still expect.

Current bone ids:
- `arm_bone`
- `leg_bone`
- `heavy_bone`
- `dummy_bone`
- `rib_bone`

Each definition can include:
- `identity`: display name, quality, color, slot, tags, description.
- `player_stats`: player-facing stat bonuses.
- `enemy_stats`: enemy profile bonuses.
- `visual`: optional scale/weight visual data.

Consumers:
- `Player` uses stat bonuses and slot data through services/components.
- `Bone` and `LimbBonePickup` use slot-aware display names and colors.
- `Enemy` uses enemy bonuses, drop data, and slot-aware display names.
- `BoneTrialGate` uses required bone slot-aware display names and colors.
- Inventory UI widgets use slot-aware display names, colors, slot labels, and effect text.

Rule: gameplay and UI should not read `BoneDataCatalog` directly yet. Use
`BoneRulesService`, `EquipmentRulesService`, `DropPickupRulesService` or
`BoneDatabase` so generated limb bones and hand-authored bones stay compatible.

## Inventory UI

`scripts/ui_bone_item.gd` defines `BoneItemTile`.

`BoneItemTile`:
- displays a collected unequipped bone.
- starts drag data with `bone_id` and source `item`.
- shows hover details through `Player.show_bone_info`.
- accepts slot drag data to unequip a worn bone.

`scripts/ui_bone_slot.gd` defines `BoneSlotWidget`.

`BoneSlotWidget`:
- displays one equipment slot.
- accepts dropped bones only when `BoneDatabase.slot(bone_id)` matches `slot_name`.
- calls `Player.equip_bone` on drop.
- calls `Player.unequip_slot` on right click.
- shows worn bone details through `Player.show_bone_info`.

`scripts/player_inventory_ui.gd` defines `PlayerInventoryUI`.

`PlayerInventoryUI`:
- owns inventory UI layout, tabs, responsive sizing, settings screen, item grid, paper doll, and preview rig.
- renders the character preview inside an isolated `SubViewport` world with a dedicated room backdrop, separate from the playable world.
- receives inventory data through player snapshot methods instead of reaching into player state directly.
- calls player commands such as `equip_bone` and `unequip_slot` only when the user performs equip actions.
- filters equipped copies by count so duplicate bone ids can remain as separate inventory tiles.
- resets the visible category to `all` when the inventory opens.
- does not recalculate player stats; `Player` remains the owner of gameplay state.

## Pickups and Rewards

`scripts/bone.gd` defines a world pickup with hold-to-collect behavior.

`Bone`:
- tracks `player_in_range`.
- reserves the player's E interaction through `enter_bone_pickup_range`.
- calls `Player.collect_bone` after the hold timer completes.
- frees itself after collection.

`scripts/limb_bone_pickup.gd` is another pickup path for limb/body rewards.

`scripts/demo_enemy_camp.gd` defines `DemoEnemyCamp`.

`DemoEnemyCamp`:
- registers enemies.
- unlocks a chest when all registered enemies are cleared.
- calls `Player.collect_bone` for the reward.
- emits `GameEvents.camp_chest_opened`.

## Arena Goals

`scripts/bone_trial_gate.gd` defines `BoneTrialGate`.

`BoneTrialGate`:
- checks whether the player has the required bone equipped.
- marks the trial complete.
- emits `GameEvents.trial_completed(trial_id, trial_name)`.

`scripts/arena_goal_manager.gd` defines `ArenaGoalManager`.

`ArenaGoalManager`:
- tracks completed trials.
- listens to `GameEvents.trial_completed`.
- opens exits after `required_trials` are complete.
- listens to `GameEvents.exit_reached` to show the win screen.
- listens to `GameEvents.player_died` to show game over.

`scripts/exit_portal.gd` defines `ExitPortal`.

`ExitPortal`:
- opens when `ArenaGoalManager` calls `open_exit`.
- emits `GameEvents.exit_reached` when the player reaches an open exit.

## Open World Map

`scripts/open_world_stage.gd` defines `OpenWorldStage`.

`OpenWorldStage`:
- exposes stage metadata such as `stage_id`, `stage_name`, difficulty, recommended bone, and description.
- emits `GameEvents.stage_entered` and `GameEvents.stage_exited`.
- can rebuild collision from its stage mesh.

`scripts/world_map_manager.gd` defines `WorldMapManager`.

`WorldMapManager`:
- listens to stage enter/exit events.
- stores the current stage.
- updates the map UI from `OpenWorldStage.get_stage_summary`.

## Enemy and Combat

`scripts/enemy.gd` owns enemy behavior.

`Enemy`:
- finds the player by group.
- applies contact damage through `Player.take_player_damage`.
- can receive alerts from other enemies.
- validates stealth finishes by range and whether the player is behind the enemy facing direction.
- drops a bone pickup by setting `Bone.set_bone_id`.

`scripts/attack_hitbox.gd` defines a short-lived attack area.

`AttackHitbox`:
- is spawned by `Player`.
- ignores the owning player.
- calls `take_damage` on enemies it overlaps.
- frees itself after a short lifetime.

## Modular Rig

`scripts/rig/modular_skeleton_rig.gd` defines `ModularSkeletonRig`.

`ModularSkeletonRig`:
- creates sockets for body, head, arms, legs, and feet.
- maps gameplay slots to sockets through `SLOT_TO_SOCKETS`.
- equips a bone by hiding base visuals and adding colored parts to matching sockets.
- exposes `get_equipped_bone_defs` for animation weight response.

`scripts/rig/procedural_player_animator.gd` defines `ProceduralPlayerAnimator`.

`ProceduralPlayerAnimator`:
- animates the rig sockets based on velocity, facing, speed, and equipped bone defs.
- uses a lower body pose, stronger arm pulls, and tucked legs in crawl mode.
- responds to attack events.
- bends limb joints when rigged limb data exists.

## Generated World

`scripts/tutorial_island_builder.gd` builds the demo island layout.

It positions the player, creates or updates open world stages, places enemies,
registers camp enemies, and configures stage metadata for the playable loop.

## Guidance Docs

`docs/godot_signal_guidelines.md` defines signal naming and decoupling rules.

`docs/current_system_status.md` records the current inventory, combat, camera,
enemy, and rig boundaries before the component refactor.

`docs/open_world_map_layout.md` describes the demo island route and stage regions.

`docs/rig_notes.md` describes modular rig and procedural animation setup.
