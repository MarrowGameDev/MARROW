# GDScript API Map

## _rt6

- Source file: `scripts/_rt6.gd`
- Extends: `SceneTree`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `main`
- `rig`
- `rarm`
- `arm_rot0`
- `anim`

### Functions
- `_initialize() -> void`

### Resource Dependencies
- `scenes/rig_test.tscn`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- `RigTestPlayer/VisualRoot/ModularSkeletonRig`
- `RigTestPlayer/VisualRoot/ProceduralAnimator`

## arena_goal_manager

- Source file: `scripts/arena_goal_manager.gd`
- Extends: `Node`
- System: World, goals, and progression

### Signals
- none

### Exported Tuning
- `required_trials`

### Constants
- `CONTROL_TUTORIAL_STEPS`

### Key Variables
- `completed_trials`
- `exit_open`
- `goal_label`
- `ended`
- `run_start_ms`
- `help_label`
- `win_root`
- `win_label`
- `current_tutorial_priority`
- `active_tutorial_hint`
- `control_tutorial_done`
- `is_moving`
- `canvas`
- `panel`
- `margin`
- `text`
- `minutes`
- `seconds`
- `collected`
- `swaps`
- `stats`
- `names_text`
- `marker`
- `backdrop`
- `center`

### Functions
- `_ready() -> void`
- `_process(_delta: float) -> void`
- `_unhandled_input(event: InputEvent) -> void`
- `register_trial_complete(trial_id: String, trial_name: String) -> void`
- `is_exit_open() -> bool`
- `_open_exit() -> void`
- `_build_goal_ui() -> void`
- `_update_goal_ui() -> void`
- `_emit_objective_updated() -> void`
- `_objective_body() -> String`
- `complete_level(player: Node) -> void`
- `game_over(_player: Node = null) -> void`
- `_on_trial_completed(trial_id: String, trial_name: String) -> void`
- `_on_exit_reached(player: Node) -> void`
- `_on_player_died(player: Node) -> void`
- `_on_objective_updated(source: Node, _objective_id: String, title: String, body: String) -> void`
- `_on_tutorial_hint_requested(_source: Node, _hint_id: String, text: String, _priority: int) -> void`
- `_on_bone_collected(bone_id: String, _collector: Node) -> void`
- `_on_bone_equipped(_bone_id: String, _slot: String, _player: Node) -> void`
- `_on_inventory_open_changed(_player: Node, is_open: bool) -> void`
- `_on_camp_state_changed(camp: Node, unlocked: bool, opened: bool, _remaining_enemies: int) -> void`
- `_show_win_screen(player: Node, elapsed_ms: int) -> void`
- `_build_help_ui() -> void`
- `_default_help_text() -> String`
- `_full_help_text() -> String`
- `_refresh_help_ui() -> void`
- `_reset_control_tutorial() -> void`
- `_complete_control_tutorial_step(step_id: String) -> void`
- `_control_tutorial_text() -> String`
- `_control_tutorial_line(step_id: String) -> String`
- `_control_tutorial_label(step_id: String) -> String`
- `_movement_binding_text() -> String`
- `_action_binding_text(action: String) -> String`
- `_build_win_ui() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `trial_completed`
- `exit_reached`
- `player_died`
- `objective_updated`
- `tutorial_hint_requested`
- `bone_collected`
- `bone_equipped`
- `inventory_open_changed`
- `camp_state_changed`

### Input Actions
- `move_forward`
- `move_back`
- `move_left`
- `move_right`
- `sprint`
- `jump`
- `attack`
- `toggle_bow`

### Node Path Lookups
- none

## ArrowProjectile

- Source file: `scripts/arrow_projectile.gd`
- Extends: `Area3D`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- `damage`
- `lifetime`
- `projectile_gravity`
- `radius`

### Constants
- `PLAYER_BODY_HURTBOX_GROUP`
- `ENEMY_BODY_HURTBOX_GROUP`

### Key Variables
- `arrow_velocity`
- `owner_body`
- `damages_player`
- `projectile_style`
- `_has_hit`
- `damage_owner`
- `call_args`
- `shape`
- `sphere`
- `visual`
- `material`
- `saliva_mesh`
- `finger_mesh`
- `arrow_mesh`

### Functions
- `_ready() -> void`
- `configure(start_position: Vector3, launch_velocity: Vector3, hit_damage: int, source_body: Node, should_damage_player: bool, gravity_value: float = 6.0, visual_style: String = "arrow") -> void`
- `_physics_process(delta: float) -> void`
- `_on_body_entered(body: Node) -> void`
- `_on_area_entered(area: Area3D) -> void`
- `_try_hit_body_part_area(area: Area3D, group_name: String, method_name: String, extra_args: Array) -> void`
- `_damage_owner_for_area(area: Area3D) -> Node`
- `_body_part_for_area(area: Area3D) -> String`
- `_build_visuals() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- `CollisionShape3D`
- `Visual`

## attack_hitbox

- Source file: `scripts/attack_hitbox.gd`
- Extends: `Area3D`
- System: Combat and enemies

### Signals
- `hit_confirmed(target: Node)`

### Exported Tuning
- `damage`
- `lifetime`

### Constants
- `ENEMY_BODY_HURTBOX_GROUP`

### Key Variables
- `owner_player`
- `already_hit`
- `contact_confirmed`
- `base_material`
- `material`
- `tween`
- `damage_owner`

### Functions
- `_ready() -> void`
- `_start_fade() -> void`
- `_hit_current_overlaps() -> void`
- `_on_body_entered(body: Node) -> void`
- `_on_area_entered(area: Area3D) -> void`
- `_try_hit_body(body: Node) -> void`
- `_try_hit_enemy_area(area: Area3D) -> void`
- `_damage_owner_for_area(area: Area3D) -> Node`
- `_body_part_for_area(area: Area3D) -> String`
- `_confirm_contact(target: Node) -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## bone

- Source file: `scripts/bone.gd`
- Extends: `Area3D`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- `bone_id`
- `pickup_hold_time`

### Constants
- none

### Key Variables
- `collected`
- `player_in_range`
- `hold_progress`
- `prompt_label`
- `bone_material`
- `marker_material`
- `was_holding`
- `next_progress`
- `raw_bone_material`
- `raw_marker_material`
- `color`

### Functions
- `_ready() -> void`
- `_process(delta: float) -> void`
- `set_bone_id(new_bone_id: String) -> void`
- `_on_body_entered(body: Node3D) -> void`
- `_on_body_exited(body: Node3D) -> void`
- `_collect() -> void`
- `_update_prompt() -> void`
- `_prepare_materials() -> void`
- `_update_appearance() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `pickup_focus_changed`
- `pickup_collected`

### Input Actions
- none

### Node Path Lookups
- `PromptLabel`

## BoneDataCatalog

- Source file: `scripts/bone_data_catalog.gd`
- Extends: `unknown`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- `RESOURCE_PATHS`
- `DEFINITIONS`

### Key Variables
- `ids`
- `clean_id`
- `resource`
- `definition`
- `result`
- `path`
- `loaded`

### Functions
- none

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## BoneDatabase

- Source file: `scripts/bone_database.gd`
- Extends: `unknown`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- `UNKNOWN_COLOR`

### Key Variables
- `base_name`
- `slot_label`
- `clean_name`
- `clean_lower`
- `slot_lower`
- `color_value`
- `value`
- `tags`
- `ids`
- `text`
- `move_bonus`
- `range_bonus`
- `damage_bonus`
- `health_bonus`

### Functions
- none

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## BoneDefinition

- Source file: `scripts/bone_definition.gd`
- Extends: `Resource`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- `bone_id`
- `display_name`
- `quality`
- `quality_rank`
- `quality_score`
- `quality_multiplier`
- `quality_color`
- `quality_damage_percent`
- `quality_speed_percent`
- `quality_health_percent`
- `quality_drop_percent`
- `quality_weight_percent`
- `rarity`
- `rarity_rank`
- `rarity_color`
- `rarity_drop_weight`
- `color`
- `slot`
- `tags`
- `description`
- `mutation_id`
- `mutation_family`
- `mutation_stage`
- `mutation_intensity`
- `mutation_tags`
- `attack_type`
- `attack_tags`
- `combo_family`
- `combo_step`
- `combo_window`
- `combo_tags`
- `combo_finisher`
- `set_id`
- `set_name`
- `set_piece_key`
- `set_tags`
- `synergy_ids`
- `synergy_tags`
- `synergy_score`
- `player_move_speed`
- `player_attack_range`
- `player_attack_damage`
- `player_max_health`
- `enemy_move_speed`
- `enemy_attack_range`
- `enemy_contact_damage`
- `enemy_max_health`
- `enemy_detection_range`
- `enemy_visual_scale`
- `enemy_flee_chance`
- `weight`
- `weight_class`
- `physical_weight`
- `equipment_weight`
- `inventory_weight`
- `visual_scale`
- `visual_offset`
- `visual_rotation`
- `hitbox_size`
- `hitbox_offset`
- `hitbox_scale`
- `hitbox_rotation`

### Constants
- `DEFAULT_COLOR`
- `QUALITY_SCRAP`
- `QUALITY_FRAGILE`
- `QUALITY_COMMON`
- `QUALITY_STRONG`
- `QUALITY_LEGENDARY`
- `RARITY_COMMON`
- `RARITY_CORRUPT`
- `RARITY_CURSED`
- `RARITY_SPECIAL`
- `RARITY_LEGENDARY`
- `MUTATION_NONE`
- `MUTATION_CORRUPT`
- `MUTATION_CURSED`
- `MUTATION_SPECIAL`
- `MUTATION_HYBRID`

### Key Variables
- `visual`
- `legacy`
- `definition`
- `identity`
- `quality_modifiers`
- `player_stats`
- `mutation`
- `attack_combo`
- `set_data`
- `synergy`
- `enemy_stats`
- `value`
- `dictionary_value`
- `result`
- `source`
- `color_value`
- `vector_value`

### Functions
- `to_clean_dictionary() -> Dictionary`
- `to_legacy_dictionary() -> Dictionary`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## BoneRulesService

- Source file: `scripts/bone_rules_service.gd`
- Extends: `unknown`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- `PLAYER_BONUS_DEFAULTS`
- `UNKNOWN_COLOR`

### Key Variables
- `definition`
- `color_value`
- `value`
- `tags`
- `ids`
- `text`
- `bonus`
- `move_bonus`
- `range_bonus`
- `damage_bonus`
- `health_bonus`
- `total`
- `bone_id`
- `keys`

### Functions
- none

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## bone_trial_gate

- Source file: `scripts/bone_trial_gate.gd`
- Extends: `Area3D`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- `trial_id`
- `trial_name`
- `required_bone_id`

### Constants
- none

### Key Variables
- `completed`
- `player_in_range`
- `gate_material`
- `raw_material`
- `required_name`

### Functions
- `_ready() -> void`
- `_process(_delta: float) -> void`
- `_on_body_entered(body: Node3D) -> void`
- `_on_body_exited(body: Node3D) -> void`
- `_try_complete_with(player: Node3D) -> void`
- `_prepare_material() -> void`
- `_update_appearance() -> void`
- `_update_label() -> void`
- `_set_gate_color(color: Color) -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `trial_completed`

### Input Actions
- none

### Node Path Lookups
- none

## DemoEnemyCamp

- Source file: `scripts/demo_enemy_camp.gd`
- Extends: `Node3D`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- `camp_name`
- `reward_bone_id`
- `chest_open_hold_time`

### Constants
- none

### Key Variables
- `enemies`
- `unlocked`
- `opened`
- `player_in_range`
- `interact_reserved`
- `hold_progress`
- `label`
- `chest_mesh`
- `flame_mesh`
- `chest_material`
- `flame_time`
- `pulse`
- `all_cleared`
- `fire_root`
- `log_mesh`
- `log_box`
- `flame`
- `chest_root`
- `box`
- `lid`
- `lid_box`
- `area`
- `shape_node`
- `sphere`
- `percent`
- `count`
- `material`

### Functions
- `_ready() -> void`
- `register_enemy(enemy: Node) -> void`
- `_process(delta: float) -> void`
- `_update_state() -> void`
- `_on_enemy_defeated(enemy: Node, _dropped_bone_id: String) -> void`
- `_emit_camp_state_changed() -> void`
- `_open_chest() -> void`
- `_on_chest_body_entered(body: Node3D) -> void`
- `_on_chest_body_exited(body: Node3D) -> void`
- `_reserve_player_interact_lock() -> void`
- `_release_player_interact_lock() -> void`
- `_build_visuals() -> void`
- `_build_campfire() -> void`
- `_build_chest() -> void`
- `_update_chest_visual() -> void`
- `_update_label() -> void`
- `_remaining_enemy_count() -> int`
- `_make_material(color: Color, glowing: bool = false) -> StandardMaterial3D`

### Resource Dependencies
- none

### GameEvents Usage
- `enemy_defeated`
- `camp_state_changed`
- `camp_chest_opened`

### Input Actions
- none

### Node Path Lookups
- none

## DropPickupRulesService

- Source file: `scripts/drop_pickup_rules_service.gd`
- Extends: `unknown`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- `PICKUP_ACTION`
- `DETACHABLE_LIMBS`
- `PICKUP_ELIGIBLE_LIMBS`
- `CORE_FALL_ORDER`

### Key Variables
- `display_name`
- `percent`
- `definition`
- `events`
- `event`
- `key_event`
- `key_name`
- `mouse_event`
- `keys`
- `slot_id`
- `candidates`
- `copy`

### Functions
- none

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## enemy

- Source file: `scripts/enemy.gd`
- Extends: `CharacterBody3D`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- `max_health`
- `move_speed`
- `detection_range`
- `vision_angle_degrees`
- `use_line_of_sight`
- `vision_check_interval`
- `vision_cone_segments`
- `attack_range`
- `contact_damage`
- `attack_cooldown`
- `search_duration`
- `search_stop_distance`
- `search_turn_speed`
- `search_rotation_smoothing`
- `search_sweep_angle_degrees`
- `arrow_hit_search_duration`
- `idle_wander_enabled`
- `idle_wander_radius`
- `idle_wander_interval`
- `hearing_investigation_time`
- `ally_alert_range`
- `ranged_attacker_enabled`
- `ranged_attack_min_range`
- `ranged_attack_range`
- `ranged_attack_cooldown`
- `ranged_attack_windup`
- `ranged_arrow_damage`
- `ranged_arrow_speed`
- `ranged_arrow_gravity`
- `low_health_flee_chance`
- `low_health_flee_ratio`
- `low_health_flee_duration`
- `flee_speed_multiplier`
- `flee_recover_distance`
- `crawl_speed_multiplier`
- `gorilla_profile_mode`
- `gorilla_profile_min_health`
- `gorilla_profile_min_damage`
- `gorilla_move_speed_multiplier`
- `gorilla_attack_cooldown_multiplier`
- `gorilla_health_bonus`
- `gorilla_damage_bonus`
- `gorilla_attack_range_bonus`
- `gorilla_knockback_bonus`
- `gorilla_can_throw_rocks`
- `gorilla_rock_throw_min_range`
- `gorilla_rock_throw_range`
- `gorilla_rock_throw_cooldown`
- `gorilla_rock_throw_windup`
- `gorilla_rock_throw_speed`
- `gorilla_rock_throw_upward_boost`
- `gorilla_rock_gravity`
- `gorilla_rock_damage`
- `lizard_profile_mode`
- `lizard_wall_phase_enabled`
- `lizard_sees_through_walls`
- `lizard_body_color`
- `lizard_move_speed_multiplier`
- `lizard_health_multiplier`
- `lizard_saliva_min_range`
- `lizard_saliva_range`
- `lizard_saliva_cooldown`
- `lizard_saliva_windup`
- `lizard_saliva_damage`
- `lizard_saliva_speed`
- `lizard_saliva_gravity`
- `lizard_wall_climb_probe_distance`
- `lizard_wall_climb_speed`
- `lizard_wall_climb_blend_speed`
- `bone_recovery_enabled`
- `bone_recovery_safe_delay`
- `bone_recovery_pickup_range`
- `bone_recovery_heal_per_part`
- `bone_recovery_move_speed_multiplier`
- `bone_recovery_safe_range`
- `bone_recovery_part_lifetime`
- `return_home_stop_distance`
- `obstacle_probe_distance`
- `obstacle_side_probe_angle_degrees`
- `obstacle_avoidance_hold_time`
- `gravity`
- `knockback_strength`
- `limb_detach_impulse`
- `detached_limb_lifetime`
- `death_limb_fall_spacing`
- `limb_pickup_drop_chance`
- `target_limb_loss_steps`
- `guarantee_limb_pickup_on_death`
- `stealth_finish_max_health`
- `stealth_finish_range`
- `stealth_behind_dot`
- `failed_stealth_damage_multiplier`
- `respawn_enabled`
- `near_respawn_delay`
- `far_respawn_delay`
- `near_respawn_distance`
- `respawn_visibility_check_interval`
- `dropped_bone_id`

### Constants
- `BONE_SCENE`
- `LIMB_BONE_PICKUP_SCRIPT`
- `ROCK_PROJECTILE_SCRIPT`
- `ARROW_PROJECTILE_SCRIPT`
- `HIT_COLOR`

### Key Variables
- `alive`
- `health`
- `attack_timer`
- `hit_flash_time_remaining`
- `knockback_velocity`
- `enemy_material`
- `vision_material`
- `normal_color`
- `facing_direction`
- `player_visible`
- `vision_check_timer`
- `cached_player`
- `search_timer`
- `search_look_time`
- `returning_to_spawn`
- `avoidance_timer`
- `avoidance_direction`
- `idle_wander_timer`
- `idle_wander_target`
- `fleeing_timer`
- `flees_when_low_health`
- `has_fled_low_health`
- `last_known_player_position`
- `spawn_transform`
- `spawn_scale`
- `spawn_facing_direction`
- `detached_limb_keys`
- `last_hit_from_position`
- `limb_pickup_spawned`
- `crawling_due_to_leg_loss`
- `gorilla_profile_active`
- `lizard_profile_active`
- `rock_throw_timer`
- `rock_throw_windup_timer`
- `rock_throw_target_position`
- `held_rock_visual`
- `saliva_spit_timer`
- `saliva_spit_windup_timer`
- `saliva_spit_target_position`
- `lizard_wall_climb_blend`

### Functions
- `_ready() -> void`
- `_process(delta: float) -> void`
- `_physics_process(delta: float) -> void`
- `_get_player() -> Node3D`
- `_player_is_dead(player: Node) -> bool`
- `_apply_enemy_movement() -> void`
- `_is_lizard_wall_climb_enabled() -> bool`
- `_apply_lizard_wall_climb_velocity() -> void`
- `_update_lizard_wall_climb_blend(delta: float) -> void`
- `_lizard_wall_probe_blocked() -> bool`
- `_try_attack_player(player: Node) -> void`
- `_can_start_saliva_spit(player: Node3D, distance_to_player: float) -> bool`
- `_start_saliva_spit(player: Node3D) -> void`
- `_update_saliva_spit_windup(delta: float, player: Node3D) -> void`
- `_fire_saliva_spit() -> void`
- `_can_start_ranged_attack(player: Node3D, distance_to_player: float) -> bool`
- `_start_ranged_attack(player: Node3D) -> void`
- `_update_ranged_attack_windup(delta: float, player: Node3D) -> void`
- `_fire_enemy_arrow() -> void`
- `_can_start_rock_throw(player: Node3D, distance_to_player: float) -> bool`
- `_start_rock_throw(player: Node3D) -> void`
- `_update_rock_throw_windup(delta: float, player: Node3D) -> void`
- `_throw_held_rock() -> void`
- `_show_held_rock() -> void`
- `_cancel_held_rock() -> void`
- `_get_held_rock_world_position() -> Vector3`
- `_get_rock_throw_socket() -> Node3D`
- `can_be_stealth_finished_by(player: Node3D) -> bool`
- `get_stealth_prompt_text() -> String`
- `get_drop_display_name() -> String`
- `_is_player_behind(player: Node3D) -> bool`
- `try_stealth_finish(player: Node3D, player_damage: int, hit_from: Vector3) -> bool`
- `_can_see_player(player: Node3D, to_player: Vector3, dist: float) -> bool`
- `_can_hear_player(player: Node, dist: float) -> bool`
- `_investigate_position(position: Vector3, duration: float) -> void`
- `receive_alert(position: Vector3) -> void`
- `_alert_nearby_allies(position: Vector3) -> void`
- `_turn_toward(direction: Vector3) -> void`
- `_build_vision_cone() -> void`
- `_set_player_visible(new_value: bool, force_visual: bool = false) -> void`
- `_get_search_move(delta: float) -> Vector3`
- `_scan_while_searching(base_direction: Vector3, delta: float) -> void`
- `_get_return_home_move() -> Vector3`
- `_get_idle_wander_move(delta: float) -> Vector3`
- `_get_flee_move(player: Node3D, dist: float) -> Vector3`
- `_update_bone_recovery_safety(delta: float, player: Node3D, distance_to_player: float) -> void`
- `_can_recover_bone_part() -> bool`
- `_get_bone_recovery_move() -> Vector3`
- `_get_recovering_limb_key() -> String`
- `_is_detached_limb_body_valid(limb_key: String) -> bool`
- `_recover_detached_limb(limb_key: String) -> void`
- `_recovery_group_key(limb_key: String) -> String`
- `_limb_recovery_group(limb_key: String) -> Array[String]`
- `_has_active_limb_pickup() -> bool`
- `_forget_detached_limb_body(limb_key: String) -> void`
- `_steer_around_obstacles(desired_direction: Vector3) -> Vector3`
- `_movement_blocked(direction: Vector3) -> bool`
- `_get_slide_around_obstacle(desired_direction: Vector3) -> Vector3`
- `_update_vision_visual(can_see_player: bool) -> void`
- `take_damage(amount: int, hit_from: Vector3 = Vector3.ZERO, attacker: Node = null, damage_source: String = "") -> void`
- `take_enemy_body_part_damage(body_part: String, amount: int, hit_from: Vector3 = Vector3.ZERO, attacker: Node = null, damage_source: String = "") -> void`
- `has_body_part_hitboxes() -> bool`
- `_react_to_arrow_hit(attacker: Node, hit_from: Vector3) -> void`
- `_apply_knockback(hit_from: Vector3) -> void`
- `take_hit(damage: int) -> void`
- `_maybe_start_low_health_flee() -> void`
- `_detach_limbs_for_damage(damage_taken: int, killing_hit: bool = false) -> void`
- `_limb_detach_count_for_damage(damage_taken: int, killing_hit: bool) -> int`
- `_next_attached_limb_key() -> String`
- `_preferred_detach_keys() -> Array[String]`
- `_detach_limb_group(limb_key: String, force_pickup: bool = false) -> void`
- `_spawn_detached_limb_piece(limb_key: String, force_pickup: bool = false) -> void`
- `_attach_pickup_to_detached_limb(body: RigidBody3D, pickup_bone_id: String) -> void`
- `_pickup_bone_id_for_limb(limb_key: String) -> String`
- `_pickup_source_profile() -> String`
- `_set_rig_limb_visible(limb_key: String, is_visible: bool) -> void`
- `_has_lizard_torso_blocks() -> bool`
- `_set_lizard_torso_blocks_visible(is_visible: bool) -> void`
- `_restore_attached_limbs() -> void`
- `_update_crawl_state(force_refresh: bool = false) -> void`
- `die() -> void`
- `_death_pop() -> void`
- `_hide_until_respawn() -> void`
- `_respawn_after_delay(delay_seconds: float) -> void`
- `_respawn() -> void`
- `_get_respawn_delay() -> float`
- `_spawn_is_out_of_perspective() -> bool`
- `_set_collision_enabled(enabled: bool) -> void`
- `_facing_from_rotation() -> Vector3`
- `_punch_scale() -> void`
- `_lunge() -> void`
- `_kill_scale_tween() -> void`
- `_drop_bone() -> void`
- `_drop_standard_bone_pickup() -> void`
- `_force_limb_pickup_drop() -> bool`
- `_next_pickup_limb_key() -> String`
- `_drop_remaining_limbs_on_death() -> void`
- `_choose_death_pickup_limb_key() -> String`
- `_update_health_label() -> void`
- `_flash_hit() -> void`
- `_set_enemy_color(new_color: Color) -> void`
- `_setup_procedural_character() -> void`
- `_update_procedural_animation(delta: float) -> void`
- `_get_effective_move_speed() -> float`
- `_setup_ranged_bow_visual() -> void`
- `_make_bow_piece(piece_name: String, size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D`
- `_set_rig_color(new_color: Color) -> void`
- `_apply_bone_identity() -> void`
- `_apply_lizard_profile() -> void`
- `_apply_gorilla_profile() -> void`
- `_should_use_gorilla_profile() -> bool`
- `_should_use_lizard_profile() -> bool`
- `_roll_low_health_personality() -> void`
- `_make_hit_blip() -> AudioStreamWAV`
- `_play_hit_sound() -> void`

### Resource Dependencies
- `scenes/bone.tscn`
- `scripts/limb_bone_pickup.gd`
- `scripts/enemy_rock_projectile.gd`
- `scripts/arrow_projectile.gd`

### GameEvents Usage
- `drop_spawned`
- `enemy_defeated`

### Input Actions
- none

### Node Path Lookups
- `LimbBonePickup`
- `LizardTorsoFront`
- `LizardTorsoRear`
- `LizardTail`

## EnemyRockProjectile

- Source file: `scripts/enemy_rock_projectile.gd`
- Extends: `Area3D`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- `damage`
- `lifetime`
- `projectile_gravity`
- `radius`

### Constants
- `PLAYER_BODY_HURTBOX_GROUP`

### Key Variables
- `velocity`
- `owner_enemy`
- `_has_hit`
- `damage_owner`
- `shape`
- `sphere`
- `visual`
- `mesh`
- `material`

### Functions
- `_ready() -> void`
- `configure(start_position: Vector3, launch_velocity: Vector3, hit_damage: int, source_enemy: Node, projectile_gravity: float = 24.0) -> void`
- `_physics_process(delta: float) -> void`
- `_on_body_entered(body: Node) -> void`
- `_on_area_entered(area: Area3D) -> void`
- `_damage_owner_for_area(area: Area3D) -> Node`
- `_body_part_for_area(area: Area3D) -> String`
- `_build_visuals() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- `CollisionShape3D`
- `Visual`

## EquipmentRulesService

- Source file: `scripts/equipment_rules_service.gd`
- Extends: `unknown`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- `UNKNOWN_COLOR`
- `PLAYER_BONUS_DEFAULTS`
- `SLOT_DISPLAY`
- `SLOT_TO_SOCKETS`
- `LIMB_TO_SLOT`
- `LIMB_DISPLAY`
- `SOURCE_DISPLAY`
- `SOURCE_COLOR`

### Key Variables
- `definition`
- `clean_source`
- `parsed`
- `source_profile`
- `limb_key`
- `slot_id`
- `source_name`
- `limb_name`
- `color_value`
- `color`
- `bonus`
- `prefix`
- `tags`
- `equipment_weight`
- `base_weight`

### Functions
- none

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## exit_portal

- Source file: `scripts/exit_portal.gd`
- Extends: `Area3D`
- System: World, goals, and progression

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `exit_open`
- `player_in_range`
- `portal_material`
- `raw_material`

### Functions
- `_ready() -> void`
- `_process(_delta: float) -> void`
- `open_exit() -> void`
- `_on_body_entered(body: Node3D) -> void`
- `_on_body_exited(body: Node3D) -> void`
- `_reach_exit(player: Node3D) -> void`
- `_prepare_material() -> void`
- `_update_visuals() -> void`
- `_set_portal_color(color: Color) -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `exit_reached`

### Input Actions
- none

### Node Path Lookups
- none

## game_events

- Source file: `scripts/game_events.gd`
- Extends: `Node`
- System: Supporting gameplay

### Signals
- `bone_collected(bone_id: String, collector: Node)`
- `bone_equipped(bone_id: String, slot: String, player: Node)`
- `bone_unequipped(bone_id: String, slot: String, player: Node)`
- `inventory_changed(player: Node, items: Array, stats: Dictionary)`
- `inventory_open_changed(player: Node, is_open: bool)`
- `pickup_focus_changed(pickup: Node, bone_id: String, player: Node, in_range: bool)`
- `pickup_collected(bone_id: String, pickup: Node, collector: Node)`
- `drop_spawned(bone_id: String, pickup: Node, source: Node)`
- `enemy_defeated(enemy: Node, dropped_bone_id: String)`
- `player_died(player: Node)`
- `trial_completed(trial_id: String, trial_name: String)`
- `exit_reached(player: Node)`
- `stage_entered(stage: Node)`
- `stage_exited(stage: Node)`
- `objective_updated(source: Node, objective_id: String, title: String, body: String)`
- `tutorial_hint_requested(source: Node, hint_id: String, text: String, priority: int)`
- `camp_state_changed(camp: Node, unlocked: bool, opened: bool, remaining_enemies: int)`
- `camp_chest_opened(camp: Node, reward_bone_id: String, player: Node)`

### Exported Tuning
- none

### Constants
- none

### Key Variables
- none

### Functions
- none

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## guide_wisp

- Source file: `scripts/guide_wisp.gd`
- Extends: `Node3D`
- System: UI and guidance

### Signals
- none

### Exported Tuning
- `follow_distance`
- `hover_height`
- `follow_speed`
- `enemy_avoid_radius`
- `enemy_avoid_strength`
- `target_scan_interval`

### Constants
- none

### Key Variables
- `player`
- `guide_target`
- `scan_timer`
- `float_time`
- `side`
- `desired`
- `avoid`
- `enemy_body`
- `away`
- `distance`
- `flat_target`
- `best`
- `best_distance`
- `material`

### Functions
- `_ready() -> void`
- `_process(delta: float) -> void`
- `_update_motion(delta: float) -> void`
- `_find_closest_enemy_target() -> Node3D`
- `_update_label() -> void`
- `_prepare_material() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## limb_bone_pickup

- Source file: `scripts/limb_bone_pickup.gd`
- Extends: `Area3D`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- `bone_id`
- `pickup_hold_time`

### Constants
- none

### Key Variables
- `collected`
- `player_in_range`
- `hold_progress`
- `prompt_label`
- `was_holding`
- `next_progress`
- `root`

### Functions
- `_ready() -> void`
- `_process(delta: float) -> void`
- `set_bone_id(new_bone_id: String) -> void`
- `_on_body_entered(body: Node3D) -> void`
- `_on_body_exited(body: Node3D) -> void`
- `_collect() -> void`
- `_update_prompt() -> void`
- `_update_prompt_color() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `pickup_focus_changed`
- `pickup_collected`

### Input Actions
- none

### Node Path Lookups
- `PromptLabel`

## main_menu

- Source file: `scripts/main_menu.gd`
- Extends: `Control`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- `DEMO_SCENE_PATH`
- `TESTING_SCENE_PATH`

### Key Variables
- `backdrop`
- `panel`
- `margin`
- `layout`
- `title`
- `subtitle`
- `hint`
- `button`

### Functions
- `_ready() -> void`
- `_build_menu() -> void`
- `_make_menu_button(text: String, callback: Callable) -> Button`
- `_open_demo() -> void`
- `_open_testing_environment() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## open_world_stage

- Source file: `scripts/open_world_stage.gd`
- Extends: `Node3D`
- System: World, goals, and progression

### Signals
- none

### Exported Tuning
- `stage_id`
- `stage_name`
- `difficulty`
- `recommended_bone`
- `description`
- `stage_color`
- `trigger_size`

### Constants
- none

### Key Variables
- `stage_material`
- `text`
- `trigger_shape`
- `raw_material`

### Functions
- `_ready() -> void`
- `refresh_runtime_mesh() -> void`
- `_on_body_entered(body: Node3D) -> void`
- `_on_body_exited(body: Node3D) -> void`
- `get_stage_summary() -> String`
- `_refresh_stage_from_mesh() -> void`
- `_prepare_material() -> void`
- `_update_label() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `stage_entered`
- `stage_exited`

### Input Actions
- none

### Node Path Lookups
- none

## player

- Source file: `scripts/player.gd`
- Extends: `CharacterBody3D`
- System: Player orchestration

### Signals
- none

### Exported Tuning
- `base_move_speed`
- `sprint_multiplier`
- `jump_velocity`
- `base_attack_range`
- `base_attack_damage`
- `max_health`
- `damage_invuln_time`
- `damage_knockback_strength`
- `gravity`
- `attack_cooldown`
- `attack_forward_offset`
- `attack_height`
- `stealth_prompt_scan_range`
- `bow_enabled`
- `start_with_bow_equipped`
- `bow_damage`
- `bow_cooldown`
- `bow_arrow_speed`
- `bow_arrow_gravity`
- `bow_arrow_spawn_height`
- `bow_aim_zoom_distance`
- `bow_aim_ray_distance`
- `bow_hand_offset`
- `bow_hand_rotation_degrees`
- `bow_full_charge_time`
- `bow_min_charge_multiplier`
- `bow_max_charge_multiplier`
- `finger_bone_damage`
- `finger_bone_cooldown`
- `finger_bone_throw_speed`
- `finger_bone_throw_gravity`

### Constants
- `ATTACK_HITBOX_SCENE`
- `ARROW_PROJECTILE_SCRIPT`

### Key Variables
- `move_speed`
- `attack_range`
- `attack_damage`
- `inventory_open`
- `inventory_ui`
- `inventory_component`
- `equipment_component`
- `stats_component`
- `nearby_bone_pickups`
- `can_attack`
- `can_shoot_bow`
- `last_facing_direction`
- `current_move_direction`
- `combo_animation_step`
- `combo_animation_timer`
- `bow_visual`
- `bow_equipped`
- `bow_aiming`
- `bow_charge_time`
- `aim_reticle_layer`
- `aim_reticle_root`
- `aim_reticle_dot`
- `aim_reticle_bars`
- `aim_reticle_charge_label`
- `health`
- `is_dead`
- `invuln_timer`
- `damage_knockback`
- `health_hud_label`
- `stealth_prompt_label`
- `stealth_target`
- `noise_timer`
- `sprinting_this_frame`
- `fallback_input_previous`
- `fallback_input_current`
- `input_vector`
- `direction`
- `aim_forward`
- `current_move_speed`
- `forward`

### Functions
- `_ready() -> void`
- `_input(event: InputEvent) -> void`
- `_physics_process(delta: float) -> void`
- `_get_camera_relative_move_direction(input_vector: Vector2) -> Vector3`
- `_reset_fallback_input_state() -> void`
- `_refresh_fallback_input_state() -> void`
- `_read_fallback_input_state() -> Dictionary`
- `_input_pressed(action: String) -> bool`
- `_input_just_pressed(action: String) -> bool`
- `_input_just_released(action: String) -> bool`
- `_get_move_input_vector() -> Vector2`
- `_get_camera_forward_direction() -> Vector3`
- `_try_attack() -> void`
- `_on_attack_hit_confirmed(_target: Node) -> void`
- `_try_bow_shot(charge_multiplier: float = 1.0, charge_ratio: float = 0.0) -> void`
- `_start_bow_aim() -> void`
- `_release_bow_shot() -> void`
- `_cancel_bow_aim() -> void`
- `_toggle_bow_equipped() -> void`
- `_fire_player_projectile(forward: Vector3, projectile_damage: int, projectile_speed: float, projectile_gravity: float, projectile_style: String) -> void`
- `_get_pointer_aim_direction(start_position: Vector3, fallback_direction: Vector3) -> Vector3`
- `_try_stealth_finish() -> void`
- `_next_combo_animation_step() -> int`
- `_combo_animation_window() -> float`
- `_flash_player_attack() -> void`
- `_setup_procedural_character() -> void`
- `_build_bow_visual() -> void`
- `_get_bow_visual_parent() -> Node3D`
- `_build_aim_reticle_ui() -> void`
- `_make_reticle_rect(rect_name: String, left: float, top: float, right: float, bottom: float, color: Color) -> ColorRect`
- `_set_aim_reticle_visible(visible: bool) -> void`
- `_update_aim_reticle_ui() -> void`
- `_get_bow_charge_ratio() -> float`
- `_get_bow_charge_multiplier() -> float`
- `_make_bow_piece(piece_name: String, size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D`
- `_update_procedural_animation(delta: float, max_speed: float) -> void`
- `_update_camera_animation_follow_offset() -> void`
- `collect_bone(bone_id: String) -> void`
- `get_equipped_bone_id() -> String`
- `has_bone_equipped(bone_id: String) -> bool`
- `get_run_stats() -> Dictionary`
- `get_inventory_items() -> Array`
- `get_equipment_state() -> Dictionary`
- `get_equipped_bone_for_slot(slot: String) -> String`
- `get_inventory_stats_snapshot() -> Dictionary`
- `take_player_damage(amount: int, from_position: Vector3 = Vector3.ZERO) -> void`
- `take_player_body_part_damage(body_part: String, amount: int, from_position: Vector3 = Vector3.ZERO) -> void`
- `has_body_part_hitboxes() -> bool`
- `is_player_dead() -> bool`
- `get_noise_radius() -> float`
- `_die_player() -> void`
- `_flash_player_damage() -> void`
- `_equip_next_bone() -> void`
- `equip_bone(bone_id: String) -> void`
- `unequip_slot(slot: String) -> void`
- `show_bone_info(bone_id: String) -> void`
- `clear_bone_info() -> void`
- `get_equipment_socket_for_slot(slot: String) -> Node3D`
- `recalculate_player_stats() -> void`
- `recalculate_inventory_stats() -> void`
- `_recalculate_stats() -> void`
- `_update_stealth_finish_prompt() -> void`
- `_find_stealth_target() -> Node3D`
- `enter_interact_range() -> void`
- `exit_interact_range() -> void`
- `enter_bone_pickup_range() -> void`
- `exit_bone_pickup_range() -> void`
- `get_inventory_tile_size() -> Vector2`
- `_build_health_ui() -> void`
- `_update_health_ui() -> void`
- `_build_stealth_ui() -> void`
- `_set_stealth_prompt(text: String) -> void`
- `_toggle_inventory() -> void`
- `_update_mouse_mode() -> void`

### Resource Dependencies
- `scenes/attack_hitbox.tscn`
- `scripts/arrow_projectile.gd`

### GameEvents Usage
- `inventory_changed`
- `player_died`
- `inventory_open_changed`

### Input Actions
- `ui_cancel`
- `ui_focus_next`
- `inventory`
- `move_left`

### Node Path Lookups
- `MeshInstance3D`

## PlayerCameraController

- Source file: `scripts/player_camera_controller.gd`
- Extends: `Node3D`
- System: Camera and controls

### Signals
- none

### Exported Tuning
- `spring_arm_path`
- `camera_path`
- `mouse_sensitivity`
- `min_vertical_angle`
- `max_vertical_angle`
- `min_zoom_distance`
- `max_zoom_distance`
- `initial_zoom_distance`
- `zoom_step`
- `zoom_smoothing`
- `follow_smoothing`
- `pivot_height`
- `spring_arm_margin`
- `spring_arm_collision_mask`
- `capture_mouse_on_ready`
- `animation_follow_smoothing`
- `aim_ray_distance`
- `aim_left_shoulder_offset`
- `aim_shoulder_height_offset`

### Constants
- none

### Key Variables
- `look_enabled`
- `yaw`
- `pitch`
- `target_zoom_distance`
- `camera`
- `spring_arm`
- `target`
- `aim_zoom_active`
- `pre_aim_zoom_distance`
- `animation_follow_offset`
- `target_animation_follow_offset`
- `collision_target`
- `animation_alpha`
- `follow_alpha`
- `alpha`
- `button`
- `motion`
- `forward`
- `right`
- `viewport`
- `screen_center`
- `ray_origin`
- `ray_direction`
- `ray_end`
- `space_state`
- `query`
- `result`
- `hit_position`
- `pivot_position`
- `shoulder_right`

### Functions
- `_ready() -> void`
- `_process(delta: float) -> void`
- `_unhandled_input(event: InputEvent) -> void`
- `capture_mouse() -> void`
- `release_mouse() -> void`
- `set_look_enabled(enabled: bool) -> void`
- `set_aim_zoom(enabled: bool, zoom_distance: float = 2.6) -> void`
- `set_animation_follow_offset(offset: Vector3) -> void`
- `get_flat_forward() -> Vector3`
- `get_flat_right() -> Vector3`
- `get_center_aim_point(max_distance: float = 90.0, exclude: Array[RID] = []) -> Vector3`
- `_apply_mouse_motion(relative: Vector2) -> void`
- `_zoom(amount: float) -> void`
- `_target_pivot_position() -> Vector3`
- `_apply_orbit_rotation() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## PlayerEquipmentComponent

- Source file: `scripts/player_equipment_component.gd`
- Extends: `Node`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- `EQUIPPED_BONE_SCENE`
- `CORE_HEAD_BONE_ID`
- `CORE_HEAD_SLOT`
- `CORE_TORSO_SLOT`
- `TORSO_REQUIRED_SLOTS`

### Key Variables
- `owner_player`
- `equipped`
- `equipped_visuals`
- `equip_swaps`
- `rig`
- `slot`
- `bone_id`
- `socket`
- `visual`
- `rig_value`
- `mesh`
- `material`
- `raw_material`

### Functions
- `setup(player: Node) -> void`
- `equip_starting_core() -> void`
- `equip_bone(bone_id: String) -> void`
- `unequip_slot(slot: String) -> void`
- `get_equipped_bone_id() -> String`
- `get_equipped_bone_for_slot(slot: String) -> String`
- `has_bone_equipped(bone_id: String) -> bool`
- `get_equipment_state() -> Dictionary`
- `get_swap_count() -> int`
- `_equip_bone_in_slot(bone_id: String, force_core: bool = false) -> bool`
- `_can_equip_slot(slot: String, bone_id: String) -> bool`
- `_emit_equipment_hint(hint_id: String, text: String) -> void`
- `_clear_equipped_visual(slot: String) -> void`
- `_get_socket_for_slot(slot: String) -> Node3D`
- `_get_player_rig() -> ModularSkeletonRig`
- `_recalculate_owner_stats() -> void`
- `_notify_equipment_changed() -> void`
- `_get_inventory_items() -> Array`
- `_get_run_stats() -> Dictionary`
- `_tint_visual(visual: Node3D, color: Color) -> void`
- `_tint_visual_mesh(visual: Node3D, mesh_name: String, color: Color) -> void`

### Resource Dependencies
- `scenes/equipped_bone.tscn`

### GameEvents Usage
- `bone_equipped`
- `bone_unequipped`
- `tutorial_hint_requested`
- `inventory_changed`

### Input Actions
- none

### Node Path Lookups
- none

## PlayerInventoryComponent

- Source file: `scripts/player_inventory_component.gd`
- Extends: `Node`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `owner_player`
- `equipment_component`
- `bone_inventory`
- `equip_cursor`
- `bone_id`

### Functions
- `setup(player: Node, equipment: PlayerEquipmentComponent = null) -> void`
- `collect_bone(bone_id: String) -> void`
- `equip_next_bone() -> void`
- `get_run_stats() -> Dictionary`
- `get_inventory_items() -> Array`
- `_get_equipment_swap_count() -> int`
- `_notify_inventory_changed() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `bone_collected`
- `inventory_changed`

### Input Actions
- none

### Node Path Lookups
- none

## PlayerInventoryUI

- Source file: `scripts/player_inventory_ui.gd`
- Extends: `Node`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- `INVENTORY_EMPTY_SLOT_SCRIPT`
- `CONTROL_SETTINGS_PATH`
- `CONTROL_BINDINGS`

### Key Variables
- `player`
- `equipped`
- `inventory_root`
- `inventory_label`
- `hover_info_label`
- `inventory_status_label`
- `inventory_category`
- `inventory_tab_buttons`
- `inventory_safe_area`
- `inventory_panel`
- `inventory_panel_margin`
- `inventory_scroll`
- `inventory_content_root`
- `inventory_header`
- `inventory_title_label`
- `inventory_tabs_container`
- `inventory_body`
- `inventory_left_panel`
- `inventory_grid_panel`
- `inventory_grid_margin`
- `inventory_sort_label`
- `inventory_right_panel`
- `inventory_preview_panel`
- `inventory_preview_area`
- `inventory_preview_container`
- `inventory_preview_viewport`
- `inventory_details_panel`
- `inventory_paper_doll`
- `inventory_footer`
- `settings_panel`
- `settings_box_panel`
- `settings_box_margin`
- `settings_controls_list`
- `settings_title_label`
- `settings_status_label`
- `settings_reset_button`
- `control_rows`
- `control_labels`
- `control_buttons`
- `rebinding_action`

### Functions
- `setup(owner_player: Node) -> void`
- `handle_input(event: InputEvent) -> void`
- `set_open(open: bool) -> void`
- `cycle_category() -> void`
- `notify_inventory_changed() -> void`
- `notify_equipment_changed() -> void`
- `_on_inventory_changed(event_player: Node, _items: Array, _stats: Dictionary) -> void`
- `_on_bone_equipped(_bone_id: String, _slot: String, event_player: Node) -> void`
- `_on_bone_unequipped(_bone_id: String, _slot: String, event_player: Node) -> void`
- `get_inventory_tile_size() -> Vector2`
- `has_bone_equipped(bone_id: String) -> bool`
- `equip_bone(bone_id: String) -> void`
- `unequip_slot(slot: String) -> void`
- `get_equipped_bone_for_slot(slot: String) -> String`
- `show_bone_info(bone_id: String) -> void`
- `clear_bone_info() -> void`
- `_build_inventory_ui() -> void`
- `_build_right_inventory_panel() -> void`
- `_build_inventory_blur_layer() -> ColorRect`
- `_build_inventory_tabs(parent: VBoxContainer) -> void`
- `_add_inventory_tab(parent: HBoxContainer, category: String, text: String) -> void`
- `_select_inventory_category(category: String) -> void`
- `_refresh_inventory_tabs() -> void`
- `_refresh_inventory_mode() -> void`
- `_queue_inventory_responsive_layout() -> void`
- `_apply_inventory_responsive_layout() -> void`
- `_apply_settings_responsive_layout(content_width: int, content_height: int, compact: bool, very_compact: bool) -> void`
- `_apply_paper_doll_responsive_layout(doll_scale: float) -> void`
- `_apply_footer_responsive_layout(content_width: int, very_compact: bool) -> void`
- `_set_margin(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void`
- `_build_settings_panel() -> ScrollContainer`
- `_build_control_binding_row(action: String, label_text: String) -> Control`
- `_add_footer_hint(parent: HBoxContainer, key_text: String, action_text: String) -> void`
- `_make_rule() -> ColorRect`
- `_make_inventory_style(bg: Color, border: Color, border_width: int = 1, radius: int = 0) -> StyleBoxFlat`
- `_make_empty_inventory_slot() -> Control`
- `_build_character_preview_panel() -> Control`
- `_build_preview_room(parent: Node3D) -> void`
- `_make_preview_room_box(name: String, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D`
- `sync_preview() -> void`
- `_build_paper_doll() -> Control`
- `_place_slot(doll: Control, slot: String, short_name: String, pos: Vector2, slot_size: Vector2) -> void`
- `_begin_rebinding(action: String, button: Button) -> void`
- `_cancel_rebinding() -> void`
- `_apply_control_binding(action: String, raw_event: InputEvent) -> void`
- `_is_bindable_control_event(event: InputEvent) -> bool`
- `_clean_control_event(raw_event: InputEvent) -> InputEvent`
- `_remove_control_event_from_other_actions(target_action: String, event: InputEvent) -> void`
- `_control_events_match(a: InputEvent, b: InputEvent) -> bool`
- `_find_control_event_owner(event: InputEvent, target_action: String) -> String`
- `_refresh_control_buttons() -> void`
- `_binding_text(action: String) -> String`
- `_event_text(event: InputEvent) -> String`
- `_control_label(action: String) -> String`
- `_save_control_settings() -> void`
- `_load_control_settings() -> void`
- `_event_from_config(config: ConfigFile, action: String) -> InputEvent`
- `_control_event_is_usable(event: InputEvent) -> bool`
- `_ensure_required_control_bindings() -> void`
- `_ensure_default_control_key(action: String, keycode: int) -> void`
- `_ensure_default_control_mouse(action: String, button_index: int) -> void`
- `_action_has_usable_event(action: String) -> bool`
- `_reset_control_defaults() -> void`
- `_set_default_control_key(action: String, keycode: int) -> void`
- `_set_default_control_mouse(action: String, button_index: int) -> void`
- `rebuild_item_tiles() -> void`
- `_bone_matches_inventory_category(bone_id: String) -> bool`
- `update_inventory_ui() -> void`
- `_bone_inventory() -> Array`
- `_equipment_state() -> Dictionary`
- `_equipped_bone_counts() -> Dictionary`
- `_inventory_stats_snapshot() -> Dictionary`

### Resource Dependencies
- `scripts/ui_inventory_empty_slot.gd`

### GameEvents Usage
- `inventory_changed`
- `bone_equipped`
- `bone_unequipped`

### Input Actions
- none

### Node Path Lookups
- `CenterFrame`
- `CenterRing`

## PlayerStatsComponent

- Source file: `scripts/player_stats_component.gd`
- Extends: `Node`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `base_move_speed`
- `base_attack_range`
- `base_attack_damage`
- `base_max_health`
- `calculated_stats`
- `new_max_health`
- `new_health`

### Functions
- `setup(initial_move_speed: float, initial_attack_range: float, initial_attack_damage: int, initial_max_health: int) -> void`
- `calculate(equipment_state: Dictionary, current_health: int, current_max_health: int) -> Dictionary`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## ModularSkeletonRig

- Source file: `scripts/rig/modular_skeleton_rig.gd`
- Extends: `Node3D`
- System: Rig and animation

### Signals
- none

### Exported Tuning
- `use_skeleton_model`
- `skeleton_model_scene`
- `skeleton_scale`
- `skeleton_rotation_deg`
- `skeleton_offset`
- `show_torso`
- `show_head`
- `use_rigged_limbs`
- `rigged_model_scene`
- `rigged_limb_scale`
- `rigged_limb_rotation_deg`

### Constants
- `BASE_COLOR`
- `BODY_HITBOX_GROUP`
- `PLAYER_BODY_HITBOX_GROUP`
- `ENEMY_BODY_HITBOX_GROUP`
- `DAMAGE_HITBOX_GROUPS`
- `MIN_HITBOX_SIZE`

### Key Variables
- `sockets`
- `base_visuals`
- `equipped_parts`
- `equipped_ids`
- `limb_joints`
- `body_hitboxes`
- `body_hitbox_shapes`
- `body_hitbox_owner`
- `body_hitbox_damage_group`
- `body_progression_enabled`
- `socket`
- `limb`
- `info`
- `leg`
- `foot`
- `foot_limb`
- `body_visual`
- `tail`
- `mesh`
- `material`
- `body`
- `block`
- `box`
- `wrapper`
- `model`
- `cfg`
- `part`
- `skel`
- `limb_scale`
- `dir_skel`
- `length_axis`
- `r`
- `fref`
- `from_b`
- `tlen`
- `tref`
- `to_b`
- `n`
- `area`
- `shape_node`

### Functions
- `_ready() -> void`
- `apply_gorilla_proportions() -> void`
- `apply_lizard_proportions() -> void`
- `_ensure_lizard_torso_block(block_name: String, size: Vector3, local_position: Vector3) -> void`
- `_set_socket_position(socket_key: String, new_position: Vector3) -> void`
- `_set_base_limb_shape(limb_key: String, new_size: Vector3, new_offset: Vector3) -> void`
- `_apply_skeleton_model() -> void`
- `_apply_rigged_limbs() -> void`
- `_find_skeleton(n: Node) -> Skeleton3D`
- `_hang_basis(l: Vector3) -> Basis`
- `_top_ancestor_under(node: Node, ancestor: Node) -> Node`
- `get_socket(socket_key: String) -> Node3D`
- `set_body_progression_enabled(enabled: bool) -> void`
- `set_body_hitbox_owner(owner_body: Node, damage_group: String = PLAYER_BODY_HITBOX_GROUP) -> void`
- `has_body_part_hitboxes() -> bool`
- `set_body_part_hitbox_enabled(socket_key: String, enabled: bool) -> void`
- `has_equipped_slot(slot_id: String) -> bool`
- `_make_limb(socket_key: String, color: Color, extra_scale: Vector3) -> MeshInstance3D`
- `equip_bone(bone_id: String, bone_def: Dictionary) -> void`
- `unequip_slot(slot_id: String) -> void`
- `get_equipped_bone_defs() -> Array`
- `_refresh_body_progression_visibility() -> void`
- `_base_socket_should_show(socket_key: String) -> bool`
- `_socket_is_equipped(socket_key: String) -> bool`
- `_ensure_body_hitboxes() -> void`
- `_make_body_hitbox(socket_key: String) -> void`
- `_body_hitbox_name(socket_key: String) -> String`
- `_configure_body_hitbox_owner(socket_key: String) -> void`
- `_apply_default_body_hitbox(socket_key: String) -> void`
- `_apply_equipped_body_hitbox(socket_key: String, explicit_size: Vector3, scale_value: Vector3, extra_offset: Vector3, rotation_value: Vector3) -> void`
- `_apply_body_hitbox(socket_key: String, size_value: Vector3, offset_value: Vector3, rotation_value: Vector3) -> void`
- `_refresh_body_hitbox_enabled() -> void`
- `_body_hitbox_should_be_enabled(socket_key: String) -> bool`
- `_clear_damage_hitbox_groups(area: Area3D) -> void`
- `_limb_geo_for(socket_key: String) -> Dictionary`
- `_as_vector3(value: Variant, fallback: Vector3) -> Vector3`
- `_scale_vector3(size_value: Vector3, scale_value: Vector3) -> Vector3`
- `_positive_vector3(value: Vector3, fallback: Vector3) -> Vector3`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- `LizardTail`

## ProceduralEnemyAnimator

- Source file: `scripts/rig/procedural_enemy_animator.gd`
- Extends: `ProceduralPlayerAnimator`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- none

### Functions
- `_ready() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## ProceduralPlayerAnimator

- Source file: `scripts/rig/procedural_player_animator.gd`
- Extends: `Node3D`
- System: Rig and animation

### Signals
- none

### Exported Tuning
- `rig`
- `turn_target`
- `player_body_progression_enabled`
- `walk_cycle_speed`
- `body_bob_amount`
- `body_sway_amount`
- `torso_lean_amount`
- `arm_swing_amount`
- `leg_swing_amount`
- `turn_smoothing`
- `idle_breath_amount`
- `speed_smoothing`
- `heavy_weight_swing_slowdown`
- `crawl_mode`
- `crawl_body_drop`
- `crawl_body_pitch`
- `crawl_pull_amount`
- `crawl_arm_drop`
- `crawl_head_lift`
- `crawl_forward_offset`
- `crawl_arm_reach`
- `crawl_leg_tuck`
- `crawl_shoulder_roll`
- `lizard_torso_flex_amount`
- `lizard_wall_climb_lift`
- `lizard_wall_climb_pitch`
- `lizard_wall_climb_head_lift`
- `lizard_wall_climb_limb_reach`
- `head_only_hop_amount`
- `head_only_roll_amount`
- `head_only_roll_radius`
- `head_only_ground_socket_y`
- `torso_spring_hop_amount`
- `torso_spring_compress_amount`
- `torso_spring_forward_offset`
- `torso_spring_tilt_amount`
- `torso_spring_ground_socket_y`
- `torso_spring_head_offset`
- `torso_spring_head_pop_amount`
- `torso_spring_head_pop_delay`
- `joint_bend_base`
- `joint_bend_swing`
- `wobble_enabled`
- `wobble_rotation`
- `wobble_slide`
- `wobble_speed`
- `env_reaction_enabled`
- `slope_influence`
- `object_lean`
- `object_range`
- `env_smoothing`
- `attack_overlay_duration`
- `attack_overlay_blend_speed`
- `attack_arm_forward`
- `attack_torso_twist`
- `attack_lunge`
- `head_only_attack_duration`
- `head_only_attack_charge_portion`
- `head_only_attack_lunge`
- `head_only_attack_arc`
- `head_only_attack_charge_squash`
- `head_only_attack_roll`
- `combo_left_arm_forward`
- `combo_finisher_arm_forward`
- `combo_finisher_torso_twist`
- `combo_finisher_lunge`
- `aim_overlay_blend_speed`
- `aim_right_arm_forward`
- `aim_left_arm_forward`
- `aim_right_arm_draw`
- `aim_left_arm_brace`
- `aim_torso_lean`
- `aim_head_dip`
- `foot_placement_enabled`
- `foot_raycast_up`
- `foot_raycast_down`
- `foot_lift`
- `foot_smoothing`
- `foot_align_to_normal`

### Constants
- `ANIMATED_KEYS`
- `FOOT_KEYS`

### Key Variables
- `walk_time`
- `_time`
- `speed_ratio`
- `total_equipped_weight`
- `_attack_timer`
- `_attack_blend`
- `_attack_duration_current`
- `_attack_combo_step`
- `_head_only_attack_contacted`
- `_head_only_attack_forward_offset`
- `_aim_requested`
- `_aim_blend`
- `_lizard_wall_climb_blend`
- `_head_only_roll_angle`
- `_rest_pos`
- `_rest_rot`
- `_captured`
- `_body`
- `horizontal`
- `target_ratio`
- `roll_radius`
- `weight_slowdown`
- `s`
- `value`
- `w`
- `sway`
- `bob`
- `breath`
- `body`
- `head`
- `hop`
- `rest`
- `phase`
- `airborne`
- `contact`
- `compression`
- `forward_shove`
- `spring_tilt`
- `body_rest`
- `head_phase`

### Functions
- `update_from_player(delta: float, velocity: Vector3, max_speed: float, facing_direction: Vector3, equipped_defs: Array) -> void`
- `trigger_attack(combo_step: int = 0) -> void`
- `set_aiming(enabled: bool) -> void`
- `confirm_head_only_attack_contact() -> void`
- `get_head_only_attack_forward_offset() -> float`
- `set_crawl_mode(enabled: bool) -> void`
- `set_lizard_wall_climb_blend(blend: float) -> void`
- `set_player_body_progression_enabled(enabled: bool) -> void`
- `_capture_rest() -> void`
- `_get_rest_pos(key: String) -> Vector3`
- `_get_rest_rot(key: String) -> Vector3`
- `_calculate_weight(equipped_defs: Array) -> float`
- `_animate_body() -> void`
- `_is_head_only() -> bool`
- `_is_torso_spring_only() -> bool`
- `_animate_head_only(sway: float, breath: float) -> void`
- `_animate_torso_spring(sway: float, breath: float) -> void`
- `_animate_limbs() -> void`
- `_animate_crawl_body() -> void`
- `_animate_crawl_limbs() -> void`
- `_apply_lizard_wall_climb_limb_pose() -> void`
- `_animate_lizard_torso_blocks(sway: float, breath: float, base_pitch: float) -> void`
- `_swing(key: String, angle: float) -> void`
- `_animate_joints() -> void`
- `_joint_phase(key: String) -> float`
- `_animate_wobble() -> void`
- `_wobble_phase(key: String) -> float`
- `_update_aim_overlay(delta: float) -> void`
- `_apply_aim_overlay() -> void`
- `_update_attack_overlay(delta: float) -> void`
- `_apply_attack_overlay() -> void`
- `_attack_pose_strength() -> float`
- `_attack_phase() -> float`
- `_apply_head_only_attack_pose() -> void`
- `_apply_right_combo_pose(strength: float) -> void`
- `_apply_left_combo_pose(strength: float) -> void`
- `_apply_finisher_combo_pose(strength: float) -> void`
- `_animate_feet(delta: float) -> void`
- `_place_foot(space: PhysicsDirectSpaceState3D, key: String, delta: float) -> void`
- `_find_body() -> Node3D`
- `_animate_facing(delta: float, facing_direction: Vector3) -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- `LizardTorsoFront`
- `LizardTorsoRear`

## rig_test_player

- Source file: `scripts/rig/rig_test_player.gd`
- Extends: `CharacterBody3D`
- System: Rig and animation

### Signals
- none

### Exported Tuning
- `move_speed`
- `gravity`

### Constants
- none

### Key Variables
- `facing_direction`
- `equipped_ids`
- `_equip_cycle`
- `_equip_index`
- `input_vector`
- `direction`
- `bone_id`

### Functions
- `_ready() -> void`
- `_physics_process(delta: float) -> void`
- `_cycle_equip() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- `equip`
- `attack`
- `move_left`

### Node Path Lookups
- none

## testing_environment

- Source file: `scripts/testing_environment.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `spawn_player_on_ready`
- `spawn_initial_enemies`
- `keep_enemy_respawn_disabled`

### Constants
- `MAIN_MENU_PATH`
- `PLAYER_SCENE`
- `ENEMY_SCENE`

### Key Variables
- `player`
- `enemy_spawn_root`
- `live_enemies`
- `spawn_cursor`
- `enemy_serial`
- `status_label`
- `environment`
- `env`
- `sun`
- `body`
- `mesh_instance`
- `mesh`
- `collision`
- `shape`
- `material`
- `marker`
- `profile`
- `markers`
- `spawn_position`
- `enemy`
- `enemy_body`
- `canvas`
- `panel`
- `margin`
- `alive_count`

### Functions
- `_ready() -> void`
- `_unhandled_input(event: InputEvent) -> void`
- `_build_world() -> void`
- `_make_box(box_name: String, pos: Vector3, size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO) -> StaticBody3D`
- `_make_material(color: Color) -> StandardMaterial3D`
- `_find_or_create_spawn_root() -> void`
- `_add_spawn_marker(marker_name: String, pos: Vector3, profile: String) -> void`
- `_spawn_player() -> void`
- `_seed_testing_inventory() -> void`
- `_spawn_initial_enemy_set() -> void`
- `_spawn_enemy_at_next_marker(profile: String) -> void`
- `_spawn_markers() -> Array[Marker3D]`
- `_spawn_enemy(profile: String, pos: Vector3) -> void`
- `_apply_profile(enemy: Node, profile: String) -> void`
- `_bone_for_profile(profile: String) -> String`
- `_remove_latest_enemy() -> void`
- `_on_enemy_defeated(_enemy: Node, _dropped_bone_id: String) -> void`
- `_build_ui() -> void`
- `_update_status() -> void`

### Resource Dependencies
- `scenes/player.tscn`
- `scenes/enemy.tscn`

### GameEvents Usage
- `enemy_defeated`

### Input Actions
- none

### Node Path Lookups
- `EnemySpawnPoints`

## tutorial_island_builder

- Source file: `scripts/tutorial_island_builder.gd`
- Extends: `Node3D`
- System: UI and guidance

### Signals
- none

### Exported Tuning
- `enabled`
- `spawn_extra_enemy_packs`

### Constants
- `ENEMY_SCENE`
- `BONE_PICKUP_SCENE`
- `CAMP_SCRIPT`

### Key Variables
- `material_cache`
- `ground_mesh`
- `ground_collision`
- `player`
- `wisp`
- `scene_root`
- `pickup`
- `pickup_body`
- `stage`
- `stage_mesh`
- `mesh`
- `stage_label`
- `sight_walls`
- `node`
- `old`
- `root`
- `path_color`
- `mountain_color`
- `x`
- `height`
- `z`
- `camps_root`
- `camp`
- `enemy_name`
- `offset`
- `bone_id`
- `overrides`
- `enemy`
- `value`
- `enemy_body`
- `host`
- `body`
- `mesh_instance`
- `collision_shape`
- `shape`
- `tree`
- `trunk`
- `trunk_mesh`
- `crown`
- `crown_mesh`

### Functions
- `_ready() -> void`
- `_build_demo_island() -> void`
- `_resize_base_ground() -> void`
- `_place_player_start() -> void`
- `_spawn_starter_torso_pickup() -> void`
- `_layout_stage_regions() -> void`
- `_configure_stage(node_name: String, pos: Vector3, trigger_size: Vector3, stage_name: String, difficulty: int, recommended: String, description: String, color: Color) -> void`
- `_layout_story_nodes() -> void`
- `_move_node(path: String, pos: Vector3) -> void`
- `_build_island_visuals() -> void`
- `_build_ocean_and_river(root: Node3D) -> void`
- `_build_paths(root: Node3D) -> void`
- `_build_landmarks(root: Node3D) -> void`
- `_build_mountain_wall(root: Node3D) -> void`
- `_build_tree_belts(root: Node3D) -> void`
- `_spawn_tutorial_enemy_packs() -> void`
- `_build_enemy_camps(root: Node3D) -> void`
- `_create_enemy_camp(parent: Node3D, camp_name: String, pos: Vector3, reward_bone_id: String, enemy_defs: Array) -> void`
- `_make_camp_ring(parent: Node3D, ring_name: String, pos: Vector3) -> void`
- `_dict_vector3(data: Dictionary, key: String, fallback: Vector3) -> Vector3`
- `_dict_dictionary(data: Dictionary, key: String) -> Dictionary`
- `_spawn_enemy(enemy_name: String, pos: Vector3, bone_id: String, overrides: Dictionary) -> Node`
- `_make_box(parent: Node, box_name: String, pos: Vector3, size: Vector3, color: Color, collision: bool, yaw: float = 0.0) -> Node3D`
- `_make_tree(parent: Node, tree_name: String, pos: Vector3) -> void`
- `_get_material(color: Color) -> StandardMaterial3D`

### Resource Dependencies
- `scenes/enemy.tscn`
- `scenes/bone.tscn`
- `scripts/demo_enemy_camp.gd`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- `../Ground/MeshInstance3D`
- `../Ground/CollisionShape3D`
- `../Player`
- `../GuideWisp`
- `StarterTorsoPickup`
- `StageBody/StageMesh`
- `StageLabel`
- `../SightTestWalls`
- `GeneratedTutorialIsland`

## BoneItemTile

- Source file: `scripts/ui_bone_item.gd`
- Extends: `Control`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `bone_id`
- `player`
- `_label`
- `_slot_label`
- `tile_size`
- `requested_size`
- `x_scale`
- `y_scale`
- `frame`
- `top_rule`
- `glow`
- `core`
- `slot_text`
- `wrap`
- `rect`
- `style`

### Functions
- `setup(id: String, player_ref: Node) -> void`
- `_on_mouse_entered() -> void`
- `_on_mouse_exited() -> void`
- `refresh() -> void`
- `_get_drag_data(_at_position: Vector2) -> Variant`
- `_make_preview() -> Control`
- `_make_tile_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat`
- `_can_drop_data(_at_position: Vector2, data: Variant) -> bool`
- `_drop_data(_at_position: Vector2, data: Variant) -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## BoneSlotWidget

- Source file: `scripts/ui_bone_slot.gd`
- Extends: `Control`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `slot_name`
- `short_name`
- `player`
- `_box`
- `_label`
- `_slot_label`
- `_slot_size`
- `x_scale`
- `y_scale`
- `min_scale`
- `frame`
- `diamond_back`
- `bone_id`
- `wrap`
- `rect`
- `preview_size`
- `style`
- `equipped_value`
- `equipped`

### Functions
- `_on_mouse_entered() -> void`
- `_on_mouse_exited() -> void`
- `refresh() -> void`
- `_get_drag_data(_at_position: Vector2) -> Variant`
- `_can_drop_data(_at_position: Vector2, data: Variant) -> bool`
- `_drop_data(_at_position: Vector2, data: Variant) -> void`
- `_gui_input(event: InputEvent) -> void`
- `_make_slot_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat`
- `_equipped_bone_id() -> String`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## InventoryEmptySlot

- Source file: `scripts/ui_inventory_empty_slot.gd`
- Extends: `Control`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `inventory_owner`
- `slot_size`
- `frame`
- `diamond`
- `diamond_inner`
- `drop`
- `style`

### Functions
- `setup(owner_ref: Node, requested_size: Vector2) -> void`
- `_can_drop_data(_at_position: Vector2, data: Variant) -> bool`
- `_drop_data(_at_position: Vector2, data: Variant) -> void`
- `_make_slot_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## world_map_manager

- Source file: `scripts/world_map_manager.gd`
- Extends: `Node`
- System: World, goals, and progression

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `current_stage`
- `map_label`
- `canvas`
- `panel`
- `margin`

### Functions
- `_ready() -> void`
- `enter_stage(stage: Node) -> void`
- `exit_stage(stage: Node) -> void`
- `_on_stage_entered(stage: Node) -> void`
- `_on_stage_exited(stage: Node) -> void`
- `_on_objective_updated(source: Node, objective_id: String, title: String, body: String) -> void`
- `_build_map_ui() -> void`
- `_update_map_ui() -> void`
- `_emit_region_objective() -> void`
- `_region_body() -> String`

### Resource Dependencies
- none

### GameEvents Usage
- `stage_entered`
- `stage_exited`
- `objective_updated`
- `tutorial_hint_requested`

### Input Actions
- none

### Node Path Lookups
- none

