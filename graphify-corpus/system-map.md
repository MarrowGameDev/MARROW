# Marrow System Map

## Camera and controls

- `scripts/player_camera_controller.gd`

## Combat and enemies

- `scripts/arrow_projectile.gd`
- `scripts/attack_head.gd`
- `scripts/attack_hitbox.gd`
- `scripts/demo_enemy_camp.gd`
- `scripts/enemy.gd`
- `scripts/enemy_rock_projectile.gd`
- `scripts/head_only_enemy.gd`
- `scripts/heavy_crab_enemy.gd`

## Inventory, equipment, and bones

- `scripts/bone.gd`
- `scripts/bone_data_catalog.gd`
- `scripts/bone_database.gd`
- `scripts/bone_definition.gd`
- `scripts/bone_rules_service.gd`
- `scripts/bone_trial_gate.gd`
- `scripts/equipment_rules_service.gd`
- `scripts/inventory_preview_character.gd`
- `scripts/limb_bone_pickup.gd`
- `scripts/player_equipment_component.gd`
- `scripts/player_inventory_component.gd`
- `scripts/player_inventory_ui.gd`
- `scripts/ui_bone_item.gd`
- `scripts/ui_bone_slot.gd`
- `scripts/ui_inventory_empty_slot.gd`

## Player orchestration

- `scripts/player.gd`

## Rig and animation

- `scripts/rig/animated_character.gd`
- `scripts/rig/creature_walker.gd`
- `scripts/rig/modular_skeleton_rig.gd`

## Supporting gameplay

- `scripts/_ch.gd`
- `scripts/ballistics_service.gd`
- `scripts/body_dock.gd`
- `scripts/body_sentinel.gd`
- `scripts/charge_arc.gd`
- `scripts/cloth_verlet.gd`
- `scripts/combat_targeting_service.gd`
- `scripts/crab_scuttle.gd`
- `scripts/creature_walk_test.gd`
- `scripts/drop_pickup_rules_service.gd`
- `scripts/game_events.gd`
- `scripts/game_groups.gd`
- `scripts/head_only_controller.gd`
- `scripts/head_torso_test.gd`
- `scripts/heavy_crab_test.gd`
- `scripts/main_menu.gd`
- `scripts/part_pickup.gd`
- `scripts/player_health.gd`
- `scripts/player_stats_component.gd`
- `scripts/rock.gd`
- `scripts/target_box.gd`
- `scripts/terrain/beach_cliff_terrain.gd`
- `scripts/testing_environment.gd`
- `scripts/torso_pickup.gd`
- `scripts/trailing_part.gd`
- `scripts/training_dummy.gd`

## UI and guidance

- `scripts/guide_wisp.gd`
- `scripts/tuning_menu_ui.gd`
- `scripts/tutorial_island_builder.gd`

## World, goals, and progression

- `scripts/arena_goal_manager.gd`
- `scripts/exit_portal.gd`
- `scripts/open_world_stage.gd`
- `scripts/world_map_manager.gd`

## Scene Entry Points

- `scenes/_ch.tscn` composes `scripts/_ch.gd`.
- `scenes/attack_hitbox.tscn` composes `scripts/attack_hitbox.gd`.
- `scenes/beach_cliff_test.tscn` composes `scripts/terrain/beach_cliff_terrain.gd`.
- `scenes/bone.tscn` composes `scripts/bone.gd`.
- `scenes/bone_trial_gate.tscn` composes `scripts/bone_trial_gate.gd`.
- `scenes/crab.tscn` composes `scripts/crab_scuttle.gd`.
- `scenes/creature_walk_test.tscn` composes `scripts/creature_walk_test.gd`, `scripts/rig/creature_walker.gd`.
- `scenes/dummy_testing_environment.tscn` composes `scripts/testing_environment.gd`.
- `scenes/enemy.tscn` composes `scripts/enemy.gd`, `scripts/rig/modular_skeleton_rig.gd`, `scripts/rig/animated_character.gd`.
- `scenes/exit_portal.tscn` composes `scripts/exit_portal.gd`.
- `scenes/guide_wisp.tscn` composes `scripts/guide_wisp.gd`.
- `scenes/head_only_test.tscn` composes `scripts/creature_walk_test.gd`, `scripts/head_only_controller.gd`, `scripts/head_only_enemy.gd`, `scripts/player_health.gd`.
- `scenes/head_torso_test.tscn` composes `scripts/head_torso_test.gd`, `scripts/head_only_controller.gd`.
- `scenes/heavy_crab_enemy.tscn` composes `scripts/heavy_crab_enemy.gd`.
- `scenes/heavy_crab_test.tscn` composes `scripts/heavy_crab_test.gd`.
- `scenes/main.tscn` composes `scripts/arena_goal_manager.gd`, `scripts/world_map_manager.gd`, `scripts/tutorial_island_builder.gd`.
- `scenes/main_menu.tscn` composes `scripts/main_menu.gd`.
- `scenes/open_world_stage.tscn` composes `scripts/open_world_stage.gd`.
- `scenes/player.tscn` composes `scripts/player.gd`, `scripts/rig/modular_skeleton_rig.gd`, `scripts/rig/animated_character.gd`, `scripts/player_camera_controller.gd`, `scripts/tuning_menu_ui.gd`.
- `scenes/rock.tscn` composes `scripts/rock.gd`.
- `scenes/testing_environment.tscn` composes `scripts/testing_environment.gd`.
