# GDScript API Map

## _ch

- Source file: `scripts/_ch.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- `OUT`

### Key Variables
- `_f`
- `env`
- `we`
- `l`
- `g`
- `gm`
- `c`
- `ap`
- `cam`
- `f`

### Functions
- `_ready()`
- `_ap(n)`
- `_process(_d)`

### Resource Dependencies
- `assets/crab_head_character_optimized.glb`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

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
- `_spawn_position`
- `_has_spawn_position`
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

## attack_head

- Source file: `scripts/attack_head.gd`
- Extends: `Node3D`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- `part_name`

### Constants
- `GLB`

### Key Variables
- `_model`
- `skel`
- `mi`
- `arr`
- `verts`
- `bones`
- `wts`
- `skin`
- `mats`
- `b`
- `sum`
- `n`
- `step`
- `i`
- `sk`
- `per`
- `w`
- `r`

### Functions
- `_ready() -> void`
- `_show_only(n: Node) -> void`
- `_center_part() -> void`
- `_find_skel(n: Node) -> Skeleton3D`
- `_find_mesh(n: Node, want: String) -> MeshInstance3D`

### Resource Dependencies
- `assets/crab_head_character_optimized.glb`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## attack_hitbox

- Source file: `scripts/attack_hitbox.gd`
- Extends: `Area3D`
- System: Combat and enemies

### Signals
- `hit_confirmed(target: Node)`

### Exported Tuning
- `damage`
- `lifetime`
- `visual_enabled`
- `override_shape_type`
- `override_shape_size`
- `override_sphere_radius`

### Constants
- `ENEMY_BODY_HURTBOX_GROUP`
- `GROUND_CONTACT_TOLERANCE`

### Key Variables
- `owner_player`
- `follow_target`
- `follow_offset_provider`
- `follow_offset_method`
- `follow_direction`
- `follow_forward_offset`
- `follow_height`
- `already_hit`
- `contact_confirmed`
- `shape_node`
- `sphere`
- `box`
- `sphere_mesh`
- `box_mesh`
- `offset`
- `offset_value`
- `flat_direction`
- `base_material`
- `material`
- `tween`
- `top`
- `collider`
- `bounds`
- `world_bounds`
- `damage_owner`

### Functions
- `_ready() -> void`
- `_physics_process(_delta: float) -> void`
- `_apply_shape_override() -> void`
- `_override_sphere_radius() -> float`
- `_update_follow_position() -> void`
- `_apply_visual_state() -> void`
- `_start_fade() -> void`
- `_hit_current_overlaps() -> void`
- `_on_body_entered(body: Node) -> void`
- `_on_area_entered(area: Area3D) -> void`
- `_try_hit_body(body: Node) -> void`
- `_body_should_confirm_contact(body: Node) -> bool`
- `_is_ground_like_body(body: Node) -> bool`
- `_body_top_y(body: Node) -> float`
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
- `CollisionShape3D`

## BallisticsService

- Source file: `scripts/ballistics_service.gd`
- Extends: `unknown`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `arc_scale`
- `to_target`
- `horizontal`
- `distance`
- `travel_time`
- `launch`
- `height`
- `angle`
- `flight`
- `effective_gravity`
- `refined`
- `speed_sq`
- `discriminant`

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

## body_dock

- Source file: `scripts/body_dock.gd`
- Extends: `StaticBody3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `character_scale`
- `tint`
- `enemy_tint`
- `body_health`
- `body_attack_range`
- `body_attack_cd`
- `body_attack_power`

### Constants
- `GLB`
- `BODY_PARTS`

### Key Variables
- `_model`
- `_grounded`
- `_gframe`
- `_base_y`
- `_owner`
- `_head_mi`
- `_head_mat`
- `_sentinel`
- `ap`
- `cs`
- `cap`
- `skel`
- `arr`
- `verts`
- `bones`
- `wts`
- `skin`
- `mats`
- `b`
- `gt`
- `sum`
- `n`
- `min_y`
- `step`
- `i`
- `sk`
- `per`
- `w`
- `wpos`
- `c`
- `t`
- `head_on`
- `m`
- `mi`
- `bone_idx`
- `xf`
- `v`
- `r`
- `out`
- `f`

### Functions
- `_ready() -> void`
- `_process(_delta: float) -> void`
- `is_free() -> bool`
- `is_enemy_held() -> bool`
- `has_reattached() -> bool`
- `reattach() -> void`
- `detach() -> void`
- `reserve() -> void`
- `reservation_active() -> bool`
- `enemy_claim(by: Node = null) -> void`
- `release() -> void`
- `take_damage(amount: int, _from: Vector3 = Vector3.ZERO, _attacker: Node = null, _src: String = "") -> void`
- `socket_world() -> Vector3`
- `play_hit_flash() -> void`
- `play_chomp() -> void`
- `_apply_visibility(n: Node) -> void`
- `_tint_head(col: Color) -> void`
- `_untint_head() -> void`
- `_ground_body() -> void`
- `_skinned_min_y(mi: MeshInstance3D, skel: Skeleton3D) -> float`
- `_find_skel(n: Node) -> Skeleton3D`
- `_find_mesh(n: Node, want: String) -> MeshInstance3D`
- `_all_meshes(n: Node) -> Array`
- `_apply_tint(n: Node) -> void`
- `_find_ap(n: Node) -> AnimationPlayer`

### Resource Dependencies
- `assets/crab_head_character_optimized.glb`

### GameEvents Usage
- `body_possessed`
- `body_freed`

### Input Actions
- none

### Node Path Lookups
- none

## BodySentinel

- Source file: `scripts/body_sentinel.gd`
- Extends: `Node`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `_body`
- `_health`
- `_atk_range`
- `_atk_cd_max`
- `_atk_power`
- `_atk_cd`
- `pl`
- `to`

### Functions
- `setup(body: Node3D, health: int, atk_range: float, atk_cd: float, atk_power: int) -> void`
- `take_hit(amount: int) -> void`
- `_process(delta: float) -> void`

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
- `head_socket_offset`
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

## charge_arc

- Source file: `scripts/charge_arc.gd`
- Extends: `Control`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `arc_fraction`
- `radius`
- `thickness`

### Constants
- none

### Key Variables
- `ratio`
- `nr`
- `span`
- `start`
- `col`

### Functions
- `set_ratio(v: float) -> void`
- `_draw() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## cloth_verlet

- Source file: `scripts/cloth_verlet.gd`
- Extends: `Node`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `cloth_start`
- `grid_x`
- `grid_y`
- `grid_z`
- `gravity`
- `stiffness`
- `damping`
- `iterations`
- `max_offset`
- `floor_y`
- `floor_friction`

### Constants
- none

### Key Variables
- `_skel`
- `_mi`
- `_mesh`
- `_rest`
- `_out`
- `_normals`
- `_uvs`
- `_tangents`
- `_colors`
- `_indices`
- `_cloth`
- `_cloth_fw`
- `_corner`
- `_cw`
- `_grid_rest`
- `_pos`
- `_prev`
- `_pin`
- `_edges`
- `_mat`
- `_root`
- `_ok`
- `arr`
- `verts`
- `bones`
- `wts`
- `skin`
- `mats`
- `b`
- `n`
- `per`
- `ylo`
- `yhi`
- `sk`
- `w`
- `span`
- `mn`
- `mx`
- `t`
- `fw`

### Functions
- `setup(root: Node) -> void`
- `_build() -> void`
- `_write_surface() -> void`
- `_gk(x: int, y: int, z: int) -> int`
- `_process(delta: float) -> void`
- `_find_skel(n: Node) -> Skeleton3D`
- `_find_mesh(n: Node, want: String) -> MeshInstance3D`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## CombatTargetingService

- Source file: `scripts/combat_targeting_service.gd`
- Extends: `unknown`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- `DEFAULT_TARGET_RANGE`
- `DEFAULT_BEHIND_BIAS`

### Key Variables
- `best_index`
- `best_score`
- `flat_facing`
- `has_facing`
- `candidate`
- `to_target`
- `distance`
- `score`
- `alignment`

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

## crab_scuttle

- Source file: `scripts/crab_scuttle.gd`
- Extends: `CharacterBody3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `max_health`
- `contact_damage`
- `walk_speed`
- `aggro_range`
- `contact_range`
- `wander_radius`
- `turn_rate_deg`
- `gravity`
- `tint`

### Constants
- `WALK_SUBSTR`

### Key Variables
- `alive`
- `health`
- `_origin`
- `_dir`
- `_wander_off`
- `_repath`
- `_ap`
- `_mats`
- `_rng`
- `clip`
- `target`
- `player`
- `chasing`
- `to_t`
- `dir`
- `xaxis`
- `d`
- `face`
- `target_yaw`
- `move`
- `a`
- `r`
- `m`
- `players`
- `sources`
- `merged`
- `maxlen`
- `src`
- `ttype`
- `t`
- `time`
- `val`
- `lib`
- `f`
- `diff`

### Functions
- `_ready() -> void`
- `_physics_process(delta: float) -> void`
- `_pick_wander() -> void`
- `take_damage(amount: int, _hit_from: Vector3 = Vector3.ZERO, _attacker: Node = null, _damage_source: String = "") -> void`
- `die() -> void`
- `_flash() -> void`
- `_apply_tint(n: Node) -> void`
- `_find_player() -> Node3D`
- `_build_walk(ap: AnimationPlayer) -> String`
- `_find_ap(n: Node) -> AnimationPlayer`
- `_approach_angle(cur: float, target: float, max_step: float) -> float`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## creature_walk_test

- Source file: `scripts/creature_walk_test.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `move_speed`
- `sprint_multiplier`
- `crouch_speed_mult`
- `gravity`
- `reattach_range`

### Constants
- none

### Key Variables
- `_head`
- `_cam`
- `_cam_ctrl`
- `_charge_arc`
- `_dock`
- `_orbiting`
- `_detaching`
- `_reattached`
- `_r_prev`
- `_reattach_prompt`
- `_hp_fill`
- `_dmg_flash`
- `env`
- `we`
- `l`
- `gb`
- `gm`
- `mat`
- `cs`
- `pivot`
- `arm`
- `layer`
- `hp_bg`
- `r_now`
- `r_pressed`
- `iv`
- `dir`
- `sprinting`
- `spd`
- `gate`
- `vp`
- `show`
- `ratio`
- `t`
- `vr`
- `to`
- `land`
- `away`

### Functions
- `_ready() -> void`
- `_physics_process(delta: float) -> void`
- `_process(_delta: float) -> void`
- `_on_player_health(_player: Node, hp: int, max_hp: int) -> void`
- `_on_player_damaged(_player: Node, _amount: int, _source: Node) -> void`
- `_on_player_died(_player: Node) -> void`
- `_crab_to_dock() -> Vector3`
- `_reattach() -> void`
- `_detach() -> void`
- `_on_detach_done() -> void`

### Resource Dependencies
- `scripts/player_camera_controller.gd`
- `scripts/body_dock.gd`
- `scripts/charge_arc.gd`

### GameEvents Usage
- `player_health_changed`
- `player_damaged`
- `player_died`

### Input Actions
- `move_left`
- `sprint`

### Node Path Lookups
- `VisualRoot`

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
- `dummy_target_enabled`
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
- `gorilla_rock_throw_arc`
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
- `_update_dummy_target_physics(delta: float) -> void`
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
- `_apply_profile_collision_shape() -> void`
- `_apply_box_collision_shape(size_value: Vector3, offset_value: Vector3) -> void`
- `_apply_dummy_target_profile() -> void`
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
- `VisualRoot/AnimatedCharacter`
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
- `tumble_speed`

### Constants
- `PLAYER_BODY_HURTBOX_GROUP`

### Key Variables
- `velocity`
- `owner_enemy`
- `_has_hit`
- `_spawn_position`
- `_has_spawn_position`
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
- `player_health_changed(player: Node, hp: int, max_hp: int)`
- `player_damaged(player: Node, amount: int, source: Node)`
- `body_possessed(body: Node, by: Node)`
- `body_freed(body: Node)`
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

## GameGroups

- Source file: `scripts/game_groups.gd`
- Extends: `RefCounted`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- `PLAYER`
- `ENEMIES`
- `PLAYER_BODY`
- `BODY_CLAIMANT`

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

## head_only_controller

- Source file: `scripts/head_only_controller.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- `hit_landed()`
- `orbit_finished()`
- `detach_finished()`

### Exported Tuning
- `character_scale`
- `ground_offset`
- `settle_percentile`
- `visible_parts`
- `run_speed`
- `hop_height`
- `hop_height_variation`
- `hop_rate`
- `rise_frac`
- `lean_deg`
- `fall_tilt_deg`
- `jump_stretch`
- `land_squash`
- `hop_spring_frac`
- `hop_synced_move`
- `move_gate_floor`
- `wobble_deg`
- `idle_squash`
- `body_idle_squash_frac`
- `arm_react_gain`
- `arm_swing_stiffness`
- `arm_swing_damping`
- `arm_swing_deg`
- `arm_swing_dist`
- `arm_swing_hand_deg`
- `torso_tilt_scale`
- `torso_bend_air_deg`
- `torso_bend_land_deg`
- `torso_bend_lower_frac`
- `torso_bend_mid_frac`
- `torso_bend_smooth`
- `spine_head_stabilize`
- `squash_node_frac`
- `head_neck_close`
- `reground_dur`
- `reground_jump`
- `run_hop_height`
- `run_lean_deg`
- `run_stretch`
- `run_fall_tilt_deg`
- `run_gate_floor`
- `read_crouch_input`
- `crouch_wobble_deg`
- `crouch_bob_deg`
- `crouch_lean_deg`
- `crouch_sway`
- `crouch_wobble_rate`
- `crouch_jump_time`
- `crouch_jump_leap`
- `read_jump_input`
- `jump_height`
- `jump_duration`
- `jump_anticipate`
- `jump_recover`
- `jump_crouch`
- `jump_tilt_deg`
- `jump_tilt_start`
- `jump_rise_frac`
- `jump_stretch_hold`
- `jump_move_lean_deg`
- `jump_move_boost`
- `read_attack_input`
- `attack_duration`
- `attack_windup`
- `attack_reach`
- `attack_hop`
- `attack_flip_height`
- `attack_slam`
- `attack_charge_lift`
- `attack_coil`
- `attack_load`
- `attack_windup_tilt`
- `attack_stretch`
- `attack_chomp`
- `attack_lean_deg`
- `attack_forward_sign`
- `attack_damage`
- `attack_charge_time`
- `attack_min_power`
- `attack_hitstop`
- `attack_impact_crush`
- `attack_flip_turns`
- `attack_style_count`
- `combo_strike_time`
- `combo_recover_time`
- `combo_return_time`
- `head_ground_clear`
- `combo_leap`
- `combo_return_leap`
- `combo_max`
- `reattach_jump_dist`
- `head_walk_speed`
- `head_walk_hop`
- `head_walk_hop_rate`
- `head_walk_stretch`
- `head_walk_squash`
- `head_walk_lean`
- `head_catch_up_mult`
- `attack_aim_range`
- `attack_aim_cone_deg`
- `attack_aim_turn`
- `orbit_duration`
- `orbit_turns`
- `orbit_stretch`
- `orbit_ref_speed`
- `orbit_min_radius`
- `orbit_settle_duration`
- `orbit_recoil_dist`
- `orbit_recoil_squash`
- `orbit_recoil_wobbles`
- `orbit_lean_deg`
- `detach_duration`
- `detach_jump`
- `detach_turns`

### Constants
- `GLB`
- `POSE_CLIP`

### Key Variables
- `_model`
- `_ap`
- `_body`
- `_phase`
- `_jt`
- `_hop_amt`
- `_hop_vary`
- `_hop_h`
- `_jump_active`
- `_jump_t`
- `_jump_from_y`
- `_jump_from_pitch`
- `_jump_from_scale`
- `_jump_scale`
- `_jump_no_stretch`
- `_attack_active`
- `_attack_t`
- `_attack_from_y`
- `_attack_from_pitch`
- `_attack_from_scale`
- `_attack_contact_flip`
- `_attack_checked`
- `_attack_hit`
- `_attack_advance`
- `_attack_target`
- `_hitstop_t`
- `_attack_buffered`
- `_attack_style`
- `_aim_target`
- `_attack_head`
- `_attack_detached`
- `_datk`
- `_datk_t`
- `_datk_from`
- `_datk_anchor`
- `_head_pos`
- `_walk_phase`
- `_walk_body_spd`
- `_combo`
- `_datk_hit_done`

### Functions
- `_ready() -> void`
- `_apply_visibility(n: Node) -> void`
- `equip_part(part_name: String) -> bool`
- `has_part(part_name: String) -> bool`
- `part_socket_world(part_name: String) -> Vector3`
- `_process(delta: float) -> void`
- `set_move_intent(speed: float) -> void`
- `move_gate() -> float`
- `request_settle() -> void`
- `settle_to_floor() -> void`
- `_ground_head() -> void`
- `_compute_head_h() -> float`
- `_skinned_min_y(mi: MeshInstance3D, skel: Skeleton3D) -> float`
- `_find_skel(n: Node) -> Skeleton3D`
- `_find_mesh(n: Node, want: String) -> MeshInstance3D`
- `_roll_hop_vary() -> void`
- `set_crouch(on: bool) -> void`
- `is_crouching() -> bool`
- `_do_crouch(delta: float, moving: bool) -> void`
- `is_crouch_crawling() -> bool`
- `crouch_phase() -> float`
- `crouch_trail_parts() -> Array`
- `set_body_hidden(hidden: bool) -> void`
- `_apply_crouch_vis(n: Node, crawl: bool) -> void`
- `is_orbiting() -> bool`
- `is_detaching() -> bool`
- `trigger_detach(socket_world: Vector3) -> void`
- `_do_detach(delta: float) -> void`
- `trigger_orbit_return(center_world: Vector3, socket_world: Vector3, socket_yaw: float = 0.0) -> void`
- `_do_orbit_return(delta: float) -> void`
- `trigger_jump(scale_override: float = 0.0, no_stretch: bool = false) -> void`
- `_do_jump(delta: float) -> void`
- `is_charging() -> bool`
- `charge_ratio() -> float`
- `_begin_charge() -> void`
- `_do_charge(delta: float) -> void`
- `trigger_attack(charge: float = 1.0, skip_windup: bool = false) -> void`
- `_apply_attack_rotation(ang: float) -> void`
- `_attack_deform(f: float) -> Vector3`
- `_do_attack(delta: float) -> void`
- `is_attacking() -> bool`
- `_find_aim_target() -> Node3D`
- `_steer_to_aim(delta: float) -> void`
- `_do_attack_detached(delta: float) -> void`
- `_place_attack_head_spin(pos: Vector3, right: Vector3, fwd: Vector3, spin: float) -> void`
- `_combo_spin_axis(fwd: Vector3, right: Vector3) -> Vector3`
- `_ensure_attack_head() -> void`
- `_try_hit_detached() -> void`
- `_place_attack_head_face(pos: Vector3, dir: Vector3) -> void`
- `_place_attack_head_walk(pos: Vector3, dir: Vector3, s: float, pitch: float) -> void`
- `_end_detached_attack() -> void`
- `_set_head_hidden(hidden: bool) -> void`
- `_apply_head_vis(n: Node, hidden: bool) -> void`
- `_attack_world_fwd() -> Vector3`
- `_floor_y(from: Vector3) -> float`
- `_raycast_target() -> Node`
- `_do_spine_expr(delta: float) -> void`
- `_set_squash(s: float) -> void`
- `_cache_spine() -> void`
- `_update_seg_flag() -> void`
- `_cache_idle_arms() -> void`
- `_do_idle_arms(delta: float, active: bool) -> void`
- `_do_little_arms(delta: float) -> void`
- `_find_ap(n: Node) -> AnimationPlayer`
- `_find_body(n: Node) -> Node3D`

### Resource Dependencies
- `assets/crab_head_character_optimized.glb`
- `scripts/attack_head.gd`

### GameEvents Usage
- none

### Input Actions
- `jump`
- `attack`

### Node Path Lookups
- none

## head_only_enemy

- Source file: `scripts/head_only_enemy.gd`
- Extends: `CharacterBody3D`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- `health`
- `move_speed`
- `wander_radius`
- `pause_min`
- `pause_max`
- `character_scale`
- `tint`
- `gravity`
- `aggro_range`
- `attack_range`
- `chase_speed`
- `attack_cooldown`
- `attack_power`
- `body_seek_range`
- `takeover_dist`

### Constants
- `CONTROLLER`

### Key Variables
- `_ctrl`
- `_head_mat`
- `_alive`
- `_home`
- `_target`
- `_pausing`
- `_pause_t`
- `_atk_cd`
- `_dock`
- `_seeking`
- `_taking_over`
- `cs`
- `cap`
- `vr`
- `head`
- `player`
- `to_player`
- `pdist`
- `dir`
- `spd`
- `face`
- `attacking`
- `sock`
- `to_body`
- `ang`
- `rad`
- `to`
- `gate`
- `p`
- `d`
- `pl`
- `pd`
- `t`
- `r`

### Functions
- `_ready() -> void`
- `_tint_head() -> void`
- `_physics_process(delta: float) -> void`
- `_get_player() -> Node3D`
- `_update_seek() -> void`
- `_begin_takeover() -> void`
- `_on_took_over() -> void`
- `_stop_seeking() -> void`
- `take_damage(amount: int, _from: Vector3 = Vector3.ZERO, _attacker: Node = null, _src: String = "") -> void`
- `_flash() -> void`
- `_die() -> void`
- `_find_mesh(n: Node, want: String) -> MeshInstance3D`

### Resource Dependencies
- `scripts/head_only_controller.gd`

### GameEvents Usage
- `enemy_defeated`

### Input Actions
- none

### Node Path Lookups
- none

## head_torso_test

- Source file: `scripts/head_torso_test.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `head_move_speed`
- `body_move_speed`
- `sprint_multiplier`
- `gravity`
- `pickup_range`
- `assembly_jump_scale`
- `scatter_speed`
- `scatter_pop`

### Constants
- none

### Key Variables
- `move_speed`
- `_ctrl`
- `_cam_ctrl`
- `_hud`
- `_parts_total`
- `_parts_got`
- `_assembling`
- `_crawling`
- `_standing`
- `_trail_parts`
- `_asm_t`
- `_asm_jump_at`
- `_head_jumped`
- `env`
- `we`
- `l`
- `gb`
- `gm`
- `mat`
- `cs`
- `pivot`
- `arm`
- `cam`
- `scatter`
- `layer`
- `d`
- `p`
- `crawling`
- `crouching`
- `to`
- `shake`
- `orbit`
- `parts`
- `n`
- `brot`
- `pn`
- `tp`
- `a`
- `leader`
- `t`

### Functions
- `_ready() -> void`
- `_spawn_part(pn: String, pos: Vector3) -> void`
- `_process(delta: float) -> void`
- `_trigger_assembly(parts: Array) -> void`
- `_on_assembled(_part_name: String) -> void`
- `_start_crawl() -> void`
- `_update_crawl(_delta: float) -> void`
- `_end_crawl() -> void`
- `_begin_standup() -> void`
- `_update_standup() -> void`
- `_on_body_complete() -> void`
- `_update_hud() -> void`
- `_physics_process(delta: float) -> void`

### Resource Dependencies
- `scripts/player_camera_controller.gd`
- `scripts/training_dummy.gd`
- `scripts/part_pickup.gd`
- `scripts/trailing_part.gd`
- `scripts/cloth_verlet.gd`

### GameEvents Usage
- none

### Input Actions
- `move_left`
- `sprint`

### Node Path Lookups
- none

## heavy_crab_enemy

- Source file: `scripts/heavy_crab_enemy.gd`
- Extends: `CharacterBody3D`
- System: Combat and enemies

### Signals
- none

### Exported Tuning
- `character_scale`
- `max_health`
- `contact_damage`
- `move_speed`
- `aggro_range`
- `contact_range`
- `wander_radius`
- `turn_rate_deg`
- `gravity`
- `facing_offset_deg`
- `step_bob`
- `step_rate`
- `tint`

### Constants
- `GLB`
- `IDLE_CLIP`

### Key Variables
- `alive`
- `health`
- `_origin`
- `_wander_off`
- `_repath`
- `_model`
- `_ap`
- `_phase`
- `_base_y`
- `_grounded`
- `_gframe`
- `_mats`
- `_rng`
- `target`
- `player`
- `to_t`
- `moving`
- `dir`
- `target_yaw`
- `a`
- `r`
- `skel`
- `min_y`
- `mi`
- `arr`
- `verts`
- `bones`
- `wts`
- `skin`
- `mats`
- `bone_idx`
- `xf`
- `v`
- `sk`
- `per`
- `w`
- `m`
- `out`
- `f`
- `diff`

### Functions
- `_ready() -> void`
- `_physics_process(delta: float) -> void`
- `_pick_wander() -> void`
- `take_damage(amount: int, _hit_from: Vector3 = Vector3.ZERO, _attacker: Node = null, _damage_source: String = "") -> void`
- `die() -> void`
- `_flash() -> void`
- `_ground_model() -> void`
- `_skinned_min_y(mi: MeshInstance3D, skel: Skeleton3D) -> float`
- `_find_skel(n: Node) -> Skeleton3D`
- `_apply_tint(n: Node) -> void`
- `_all_meshes(n: Node) -> Array`
- `_find_player() -> Node3D`
- `_find_ap(n: Node) -> AnimationPlayer`
- `_approach_angle(cur: float, target: float, max_step: float) -> float`

### Resource Dependencies
- `assets/heavy_crab.glb`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## heavy_crab_test

- Source file: `scripts/heavy_crab_test.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- none

### Constants
- none

### Key Variables
- `env`
- `we`
- `l`
- `gb`
- `gm`
- `mat`
- `cs`
- `crab`
- `cam`

### Functions
- `_ready() -> void`

### Resource Dependencies
- `scenes/heavy_crab_enemy.tscn`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## inventory_preview_character

- Source file: `scripts/inventory_preview_character.gd`
- Extends: `Node3D`
- System: Inventory, equipment, and bones

### Signals
- none

### Exported Tuning
- `preview_scale`
- `preview_offset`

### Constants
- `CHARACTER`

### Key Variables
- `_model`
- `_by_slot`
- `model`
- `slot`
- `vis`
- `n`
- `out`

### Functions
- `_ready() -> void`
- `sync(equipped_slots: Array) -> void`
- `_slot_of(name: String) -> String`
- `_meshes(n: Node) -> Array`

### Resource Dependencies
- `assets/main_character.glb`

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
- `DUMMY_TESTING_SCENE_PATH`

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
- `_open_dummy_testing_environment() -> void`

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

## part_pickup

- Source file: `scripts/part_pickup.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- `assembled(part_name: String)`

### Exported Tuning
- `part_name`
- `scale_factor`
- `buried_y`
- `lay_pitch`
- `shake_dur`
- `shake_amp`
- `shake_rate`
- `orbit_dur`
- `orbit_turns`
- `orbit_stretch`
- `whirl_speed`

### Constants
- `GLB`

### Key Variables
- `_state`
- `_ctrl`
- `_model`
- `_centered`
- `_cframe`
- `_t`
- `_base_pos`
- `_shake_dir`
- `_shake_phase`
- `_shake_phase2`
- `_shake_rate_mul`
- `_shake_rate_mul2`
- `_r0`
- `_a0`
- `_lift0`
- `a`
- `f`
- `amp`
- `perp`
- `sa`
- `sb`
- `center`
- `off`
- `e`
- `socket`
- `angle`
- `radius`
- `spiral`
- `st`
- `inv`
- `m`
- `skel`
- `mi`
- `arr`
- `verts`
- `bones`
- `wts`
- `skin`
- `mats`
- `b`

### Functions
- `_ready() -> void`
- `begin_assembly(ctrl: Node) -> void`
- `part() -> String`
- `_process(delta: float) -> void`
- `_rig_center() -> Vector3`
- `_socket() -> Vector3`
- `_show_only(n: Node) -> void`
- `_center_part() -> void`
- `_find_skel(n: Node) -> Skeleton3D`
- `_find_mesh(n: Node, want: String) -> MeshInstance3D`

### Resource Dependencies
- `assets/crab_head_character_optimized.glb`

### GameEvents Usage
- none

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
- `body_collision_radius`
- `body_collision_height`
- `body_collision_offset_y`
- `show_body_hitbox`
- `base_attack_range`
- `base_attack_damage`
- `max_health`
- `damage_invuln_time`
- `damage_knockback_strength`
- `gravity`
- `attack_cooldown`
- `head_launch_attack_recovery`
- `head_only_attack_locks_movement`
- `attack_forward_offset`
- `attack_height`
- `noise_radius_normal`
- `noise_radius_sprinting`
- `head_launch_target_range`
- `head_only_attack_hitbox_lifetime`
- `head_only_attack_hitbox_height`
- `head_only_attack_hitbox_radius`
- `head_only_attack_hitbox_size`
- `torso_head_attack_hitbox_lifetime`
- `detached_head_reattach_range`
- `detached_head_reattach_hold_time`
- `detached_head_fallback_launch_distance`
- `detached_torso_ground_probe_height`
- `detached_torso_ground_probe_depth`
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
- `start_as_head`
- `torso_pickup_offset`
- `head_lunge_speed`
- `head_lunge_duration`

### Constants
- `ATTACK_HITBOX_SCENE`
- `ARROW_PROJECTILE_SCRIPT`
- `TORSO_PICKUP_SCRIPT`
- `COMBO_STEP_ARM_SWORD`

### Key Variables
- `_torso_assembled`
- `_lunge_timer`
- `_lunge_velocity`
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
- `finger_aiming`
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
- `head_launch_target`
- `head_launch_recovery_timer`
- `head_detached_from_torso`

### Functions
- `_ready() -> void`
- `_set_body_collision_radius(v: float) -> void`
- `_set_body_collision_height(v: float) -> void`
- `_set_body_collision_offset_y(v: float) -> void`
- `_set_show_body_hitbox(v: bool) -> void`
- `_apply_body_collision() -> void`
- `_spawn_torso_pickup_deferred() -> void`
- `_spawn_torso_pickup() -> void`
- `_on_bone_equipped(_bone_id: String, slot: String, who: Node) -> void`
- `_on_bone_unequipped(_bone_id: String, slot: String, who: Node) -> void`
- `_show_torso_body() -> void`
- `_revert_to_head() -> void`
- `_input(event: InputEvent) -> void`
- `_physics_process(delta: float) -> void`
- `_get_camera_relative_move_direction(input_vector: Vector2) -> Vector3`
- `_input_pressed(action: String) -> bool`
- `_input_just_pressed(action: String) -> bool`
- `_input_just_released(action: String) -> bool`
- `_get_move_input_vector() -> Vector2`
- `_get_camera_forward_direction() -> Vector3`
- `_try_attack() -> void`
- `_on_attack_hit_confirmed(_target: Node) -> void`
- `_acquire_head_launch_target() -> void`
- `_head_launch_target_aim() -> Vector3`
- `_push_head_launch_attack_aim() -> void`
- `_is_head_launch_combat_mode() -> bool`
- `_is_head_only_attack_locking_movement() -> bool`
- `_is_head_launch_attack_busy() -> bool`
- `_is_head_launch_attack_blocked() -> bool`
- `_head_launch_attack_input_blocked() -> bool`
- `_update_head_launch_recovery(delta: float) -> void`
- `_get_head_only_hitbox_follow_target() -> Node3D`
- `_is_head_only_combat_mode() -> bool`
- `_is_slot_equipped(slot: String) -> bool`
- `_has_any_arm_equipped() -> bool`
- `_is_torso_head_launch_combat_mode() -> bool`
- `_force_head_only_single_visual() -> void`
- `_try_bow_shot(charge_multiplier: float = 1.0, charge_ratio: float = 0.0) -> void`
- `_start_bow_aim() -> void`
- `_start_finger_aim() -> void`
- `_release_finger_shot() -> void`
- `_release_bow_shot() -> void`
- `_cancel_bow_aim() -> void`
- `_toggle_bow_equipped() -> void`
- `_set_bow_equipped(enabled: bool) -> void`
- `_can_use_bow() -> bool`
- `_fire_player_projectile(forward: Vector3, projectile_damage: int, projectile_speed: float, projectile_gravity: float, projectile_style: String) -> void`
- `_get_pointer_aim_point(start_position: Vector3, fallback_direction: Vector3) -> Vector3`
- `_aim_direction_to(start_position: Vector3, aim_point: Vector3, fallback_direction: Vector3) -> Vector3`
- `_try_stealth_finish() -> void`
- `_next_combo_animation_step() -> int`
- `_is_arm_sword_held() -> bool`
- `_has_both_arms_equipped() -> bool`
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
- `_apply_head_only_lunge_displacement(offset: Vector3) -> void`
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
- `is_head_detached_from_torso() -> bool`
- `_detach_head_from_torso_after_miss(detach_offset: Vector3, detached_body_transform: Transform3D = Transform3D.IDENTITY, use_detached_body_transform: bool = false) -> void`
- `_detached_head_ground_local_position(launch_offset: Vector3) -> Vector3`
- `_spawn_detached_torso_marker(body_bone_id: String, detached_body_transform: Transform3D = Transform3D.IDENTITY, use_detached_body_transform: bool = false) -> void`
- `_grounded_detached_torso_marker_position(anchor_position: Vector3, torso_height: float) -> Vector3`
- `_update_detached_torso_reattach(delta: float) -> bool`
- `_begin_detached_torso_reattach_animation() -> void`
- `_update_detached_torso_reattach_animation() -> void`
- `_cancel_detached_torso_reattach_animation() -> void`
- `_finish_reattach_head_to_detached_torso() -> void`
- `_current_head_world_position() -> Vector3`
- `_align_player_body_pose_to_detached_torso_marker() -> void`
- `_detached_torso_head_attach_offset() -> Vector3`
- `_clear_detached_torso_marker() -> void`
- `_set_detached_torso_marker_prompt_visible(is_visible: bool) -> void`
- `_as_vector3(value: Variant, fallback: Vector3) -> Vector3`
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
- `scripts/torso_pickup.gd`

### GameEvents Usage
- `inventory_changed`
- `bone_equipped`
- `bone_unequipped`
- `player_died`
- `inventory_open_changed`

### Input Actions
- `ui_cancel`
- `ui_focus_next`
- `inventory`
- `move_left`

### Node Path Lookups
- `VisualRoot/AnimatedCharacter`
- `CollisionShape3D`
- `MeshInstance3D`
- `DetachedTorsoPrompt`

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
- `restore_detached_body(bone_id: String) -> void`
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

## player_health

- Source file: `scripts/player_health.gd`
- Extends: `CharacterBody3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `max_health`
- `invuln_time`

### Constants
- none

### Key Variables
- `_hp`
- `_invuln`

### Functions
- `_ready() -> void`
- `_announce() -> void`
- `_process(delta: float) -> void`
- `take_damage(amount: int, _from: Vector3 = Vector3.ZERO, attacker: Node = null, _src: String = "") -> void`
- `heal_full() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- `player_health_changed`
- `player_damaged`
- `player_died`

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
- `scripts/inventory_preview_character.gd`

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

## AnimatedCharacter

- Source file: `scripts/rig/animated_character.gd`
- Extends: `Node3D`
- System: Rig and animation

### Signals
- none

### Exported Tuning
- `character_scale`
- `foot_offset_y`
- `hide_sibling_rig`
- `body_tint`
- `start_as_head`
- `head_only_y`
- `head_torso_y`

### Constants
- `CHARACTER`

### Key Variables
- `_model`
- `_skel`
- `_ap`
- `_body`
- `_disabled`
- `_head_meshes`
- `_torso_meshes`
- `_limb_meshes`
- `model`
- `clip`
- `a`
- `low`
- `f`
- `n`
- `out`
- `vr`
- `m`
- `p`

### Functions
- `_ready() -> void`
- `trigger_jump() -> void`
- `trigger_attack() -> void`
- `set_aiming(_enabled: bool) -> void`
- `skeleton() -> Skeleton3D`
- `_play_once(names: Array) -> void`
- `_native_clip(names: Array) -> String`
- `_find_ap(n: Node) -> AnimationPlayer`
- `_categorize_parts(model: Node) -> void`
- `show_only_head() -> void`
- `reveal_torso() -> void`
- `show_all_parts() -> void`
- `head_mesh_names() -> Array`
- `torso_mesh_names() -> Array`
- `_set_visible(meshes: Array, v: bool) -> void`
- `_all_meshes(n: Node) -> Array`
- `disable() -> void`
- `is_disabled() -> bool`
- `set_body_tint(c: Color) -> void`
- `_hide_old_rig() -> void`
- `_apply_tint(n: Node, c: Color) -> void`
- `_find_body(n: Node) -> Node3D`
- `_find_skeleton(n: Node) -> Skeleton3D`

### Resource Dependencies
- `assets/main_character.glb`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## creature_walker

- Source file: `scripts/rig/creature_walker.gd`
- Extends: `Node3D`
- System: Rig and animation

### Signals
- none

### Exported Tuning
- `character_scale`
- `run_speed`
- `step_rate`
- `stride_frac`
- `lift_frac`
- `forward_sign`
- `knee_pole_sign`
- `arm_swing_deg`
- `body_bob`
- `head_bob_deg`
- `head_sway_deg`

### Constants
- `GLB`
- `SKEL_PATH`
- `IDLE_CLIP`
- `L_ARM`
- `R_ARM`
- `L_HAND`
- `R_HAND`
- `NECK`
- `IDLE_STRIP`

### Key Variables
- `_model`
- `_skel`
- `_ap`
- `_body`
- `_phase`
- `_speed`
- `_base_y`
- `_leg_l`
- `_leg_r`
- `_up`
- `_side`
- `_forward`
- `_stride`
- `_step_h`
- `_idx`
- `_restg`
- `_restgp`
- `_pivot_l_arm`
- `_pivot_r_arm`
- `_neck_pivot`
- `_upper_clip`
- `hip_l`
- `hip_r`
- `ank_l`
- `ank_r`
- `leg_len`
- `b`
- `p`
- `src`
- `copy`
- `colon`
- `bone`
- `lib_name`
- `lib`
- `ui`
- `li`
- `ii`
- `fi`
- `upper_rg`
- `lower_rg`

### Functions
- `_ready() -> void`
- `_build_upper_idle() -> void`
- `_make_leg(upper: String, lower: String, ikbone: String, foot: String) -> Dictionary`
- `_process(delta: float) -> void`
- `_apply_gait(amt: float) -> void`
- `_drive_leg(leg: Dictionary, phase: float, amt: float) -> void`
- `_solve_knee(h: Vector3, t: Vector3, l1: float, l2: float, pole: Vector3) -> Array`
- `_aim(rest_global: Transform3D, rest_dir: Vector3, new_dir: Vector3, parent_global: Transform3D, new_origin: Vector3) -> Transform3D`
- `_set_pose(idx: int, local: Transform3D) -> void`
- `_rotate_about(b: int, pivot: Vector3, axis: Vector3, angle: float) -> void`
- `_rotate_about_basis(b: int, pivot: Vector3, rot: Basis) -> void`
- `_rest_origin(name: String) -> Vector3`
- `_find_ap(n: Node) -> AnimationPlayer`
- `_find_body(n: Node) -> Node3D`

### Resource Dependencies
- `assets/crab_head_character_optimized.glb`

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
- `head_model_scene`
- `head_model_scale`
- `head_model_offset`
- `head_model_rotation_deg`
- `head_model_keep_material`
- `use_split_limbs`
- `show_socket_markers`
- `socket_marker_radius`
- `socket_marker_color`
- `body_hitbox_scale`
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
- `ENEMY_HITBOX_ACCURACY_SCALE`

### Key Variables
- `_head_model_mesh`
- `_head_model_mesh_loaded`
- `socket_markers`
- `_waist_joint`
- `sockets`
- `base_visuals`
- `equipped_parts`
- `equipped_ids`
- `limb_joints`
- `body_hitboxes`
- `body_hitbox_shapes`
- `body_hitbox_configs`
- `body_hitbox_owner`
- `body_hitbox_damage_group`
- `body_progression_enabled`
- `socket`
- `limb`
- `lower_info`
- `upper`
- `joint`
- `lower_limb`
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

### Functions
- `_ready() -> void`
- `apply_gorilla_proportions() -> void`
- `apply_lizard_proportions() -> void`
- `_ensure_lizard_torso_block(block_name: String, size: Vector3, local_position: Vector3) -> void`
- `_set_socket_position(socket_key: String, new_position: Vector3) -> void`
- `_set_base_limb_shape(limb_key: String, new_size: Vector3, new_offset: Vector3) -> void`
- `_apply_gorilla_body_hitboxes() -> void`
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
- `set_head_only_visual_guard(enabled: bool) -> void`
- `_set_mesh_visibility_recursive(root: Node, is_visible: bool) -> void`
- `has_equipped_slot(slot_id: String) -> bool`
- `_make_limb(socket_key: String, color: Color, extra_scale: Vector3) -> MeshInstance3D`
- `_get_head_model_mesh() -> Mesh`
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
- `_apply_body_hitbox_shape(socket_key: String, size_value: Vector3, offset_value: Vector3, rotation_value: Vector3) -> void`
- `_set_body_hitbox_scale(v: float) -> void`
- `_refresh_body_hitbox_shapes() -> void`
- `_enemy_adjusted_hitbox_size(socket_key: String, size_value: Vector3) -> Vector3`
- `_refresh_body_hitbox_enabled() -> void`
- `_body_hitbox_should_be_enabled(socket_key: String) -> bool`
- `_clear_damage_hitbox_groups(area: Area3D) -> void`
- `_build_socket_markers() -> void`
- `_make_socket_marker(socket_key: String) -> MeshInstance3D`
- `get_waist_joint() -> Node3D`
- `get_socket_attach(socket_key: String) -> Node3D`
- `_build_waist_joint() -> void`
- `_socket_layout_for(socket_key: String) -> Vector3`
- `_limb_geo_for(socket_key: String) -> Dictionary`
- `_split_limbs_active() -> bool`
- `_foot_parent_key(leg_key: String) -> String`
- `limb_socket_group(key: String) -> Array[String]`
- `get_limb_meshes(key: String) -> Array[MeshInstance3D]`
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

## rock

- Source file: `scripts/rock.gd`
- Extends: `StaticBody3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `mesh_index`
- `give_collision`
- `target_width`

### Constants
- `CLUSTER`

### Key Variables
- `parts`
- `idx`
- `p`
- `mesh`
- `mi`
- `aabb`
- `center`
- `d`
- `cs`
- `box`
- `inst`
- `m`
- `out`

### Functions
- `_ready() -> void`
- `_parts() -> Array`
- `_find_meshes(n: Node) -> Array`

### Resource Dependencies
- `assets/rock_boulders.glb`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## target_box

- Source file: `scripts/target_box.gd`
- Extends: `StaticBody3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `health`
- `box_size`
- `tint`

### Constants
- none

### Key Variables
- `_mat`
- `_alive`
- `mesh`
- `bm`
- `cs`
- `bs`
- `t`

### Functions
- `_ready() -> void`
- `take_damage(amount: int, _from: Vector3 = Vector3.ZERO, _attacker: Node = null, _src: String = "") -> void`
- `_flash() -> void`
- `_die() -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## BeachCliffTerrain

- Source file: `scripts/terrain/beach_cliff_terrain.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `regenerate`
- `width`
- `depth`
- `resolution`
- `water_level`
- `shore_z`
- `beach_top`
- `cliff_start_z`
- `cliff_end_z`
- `cliff_height`
- `coast_wobble`
- `noise_seed`
- `noise_frequency`
- `noise_amplitude`
- `wet_sand`
- `dry_sand`
- `rock`
- `grass`
- `add_water`
- `water_color`

### Constants
- none

### Key Variables
- `_noise`
- `res`
- `n`
- `eps`
- `verts`
- `normals`
- `uvs`
- `colors`
- `x`
- `z`
- `y`
- `hx`
- `hz`
- `nrm`
- `idx`
- `indices`
- `a`
- `b`
- `c`
- `d`
- `arr`
- `mesh`
- `mi`
- `mat`
- `body`
- `col`
- `wm`
- `pm`
- `wmat`
- `shift`
- `s_z`
- `c0`
- `c1`
- `h`
- `t`
- `amp`

### Functions
- `_ready() -> void`
- `_set_regenerate(v: bool) -> void`
- `build() -> void`
- `_height(x: float, z: float) -> float`
- `_color(y: float, slope: float) -> Color`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

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
- `dummy_only_mode`

### Constants
- `MAIN_MENU_PATH`
- `PLAYER_SCENE`
- `ENEMY_SCENE`
- `NORMAL_LIMB_BONES`
- `EXTRA_TESTING_BONES`

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
- `_try_spawn_dummy() -> void`
- `_has_live_dummy() -> bool`
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

## torso_pickup

- Source file: `scripts/torso_pickup.gd`
- Extends: `Area3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `body_scale`
- `bury_depth`
- `tilt_deg`
- `loose_bone_count`

### Constants
- `CHARACTER`

### Key Variables
- `_model`
- `_collected`
- `_rng`
- `model`
- `ribs`
- `n`
- `is_torso`
- `col`
- `sh`
- `count`
- `src`
- `a`
- `center`
- `cont`
- `ang`
- `dist`
- `dup`
- `space`
- `q`
- `hit`
- `out`

### Functions
- `_ready() -> void`
- `_scatter_loose_bones(ribs: Array) -> void`
- `_snap_to_ground() -> void`
- `_on_body_entered(body: Node) -> void`
- `_meshes(n: Node) -> Array`

### Resource Dependencies
- `assets/main_character.glb`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## trailing_part

- Source file: `scripts/trailing_part.gd`
- Extends: `Node3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `part_name`
- `scale_factor`
- `follow_dist`
- `roll_radius`
- `ground_y`
- `tumble_frac`
- `gravity`
- `return_lift`
- `scatter_drag`

### Constants
- `GLB`

### Key Variables
- `_model`
- `_tumble_axis`
- `_tumble_dir`
- `_grounded`
- `_vel_y`
- `_scatter_vel`
- `_vis`
- `_low_pts`
- `_measured`
- `_from`
- `_from_rot`
- `rest_y`
- `fp`
- `target`
- `to`
- `d`
- `dir`
- `move`
- `spin`
- `axis`
- `gp`
- `e`
- `p`
- `q`
- `b`
- `lowest`
- `skel`
- `mi`
- `arr`
- `verts`
- `bones`
- `wts`
- `skin`
- `mats`
- `gi`
- `st`
- `step`
- `i`
- `sk`
- `per`

### Functions
- `_ready() -> void`
- `part() -> String`
- `follow(leader_pos: Vector3, delta: float) -> void`
- `face_body(q: Quaternion) -> void`
- `launch_scatter(horiz: Vector3, pop: float) -> void`
- `begin_return() -> void`
- `return_to(target: Vector3, target_rot: Quaternion, t: float) -> void`
- `_rest_y() -> float`
- `_vis_mesh() -> MeshInstance3D`
- `_measure_extent() -> void`
- `_show_only(n: Node) -> void`
- `_center_part() -> void`
- `_find_skel(n: Node) -> Skeleton3D`
- `_find_mesh(n: Node, want: String) -> MeshInstance3D`

### Resource Dependencies
- `assets/crab_head_character_optimized.glb`

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## training_dummy

- Source file: `scripts/training_dummy.gd`
- Extends: `StaticBody3D`
- System: Supporting gameplay

### Signals
- none

### Exported Tuning
- `height`
- `radius`
- `knock_deg`
- `stiffness`
- `damping`
- `full_damage`

### Constants
- `BASE`
- `HIT`

### Key Variables
- `_pivot`
- `_mat`
- `_tilt`
- `_tilt_vel`
- `_flash`
- `_hits`
- `col`
- `cap`
- `mi`
- `cm`
- `away`
- `mag`

### Functions
- `_ready() -> void`
- `take_damage(amount: int, from_pos: Vector3, _source: Object = null) -> void`
- `hits() -> int`
- `_process(delta: float) -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- none

## TuningMenuUI

- Source file: `scripts/tuning_menu_ui.gd`
- Extends: `CanvasLayer`
- System: UI and guidance

### Signals
- none

### Exported Tuning
- none

### Constants
- `TOGGLE_KEY`

### Key Variables
- `_player`
- `_animator`
- `_panel`
- `_rows`
- `_defaults`
- `_was_mouse_captured`
- `key_event`
- `stats`
- `slider`
- `label`
- `style`
- `box`
- `title`
- `reset`
- `hint`
- `name_label`
- `row`
- `value_label`

### Functions
- `_ready() -> void`
- `_unhandled_input(event: InputEvent) -> void`
- `set_open(open: bool) -> void`
- `_current_value(id: String) -> float`
- `_apply_value(id: String, value: float) -> void`
- `_capture_defaults() -> void`
- `_reset_defaults() -> void`
- `_refresh_all() -> void`
- `_update_value_label(id: String, value: float) -> void`
- `_build_ui() -> void`
- `_add_row(parent: VBoxContainer, id: String, text: String, min_v: float, max_v: float, step: float) -> void`

### Resource Dependencies
- none

### GameEvents Usage
- none

### Input Actions
- none

### Node Path Lookups
- `VisualRoot/ProceduralAnimator`

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
- `stack_count`
- `_label`
- `_slot_label`
- `_stack_label`
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
- `setup(id: String, player_ref: Node, quantity: int = 1) -> void`
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

