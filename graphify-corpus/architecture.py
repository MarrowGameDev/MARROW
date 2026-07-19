"""Generated architecture map for Graphify code-only extraction.

This file is generated from Godot GDScript, scenes, docs, and project metadata.
Do not edit by hand; run tools/build_graphify_corpus.py instead.
"""

class Rt6:
    """Godot script: scripts/_rt6.gd
    class_name: none
    extends: SceneTree
    system: Supporting gameplay
    """
    source_file = 'scripts/_rt6.gd'
    godot_class_name = ''
    godot_extends = 'SceneTree'
    gameplay_system = 'Supporting gameplay'

    def gd_func__initialize(self):
        """GDScript function: _initialize() -> void"""
        pass

    def depends_on_SceneRigTest(self):
        """Relationship: loads resource."""
        return SceneRigTest

    def depends_on_ModularSkeletonRig(self):
        """Relationship: references class ModularSkeletonRig."""
        return ModularSkeletonRig

class ArenaGoalManager:
    """Godot script: scripts/arena_goal_manager.gd
    class_name: none
    extends: Node
    system: World, goals, and progression
    """
    source_file = 'scripts/arena_goal_manager.gd'
    godot_class_name = ''
    godot_extends = 'Node'
    gameplay_system = 'World, goals, and progression'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(_delta: float) -> void"""
        pass

    def gd_func__unhandled_input(self):
        """GDScript function: _unhandled_input(event: InputEvent) -> void"""
        pass

    def gd_func_register_trial_complete(self):
        """GDScript function: register_trial_complete(trial_id: String, trial_name: String) -> void"""
        pass

    def gd_func_is_exit_open(self):
        """GDScript function: is_exit_open() -> bool"""
        pass

    def gd_func__open_exit(self):
        """GDScript function: _open_exit() -> void"""
        pass

    def gd_func__build_goal_ui(self):
        """GDScript function: _build_goal_ui() -> void"""
        pass

    def gd_func__update_goal_ui(self):
        """GDScript function: _update_goal_ui() -> void"""
        pass

    def gd_func__emit_objective_updated(self):
        """GDScript function: _emit_objective_updated() -> void"""
        pass

    def gd_func__objective_body(self):
        """GDScript function: _objective_body() -> String"""
        pass

    def gd_func_complete_level(self):
        """GDScript function: complete_level(player: Node) -> void"""
        pass

    def gd_func_game_over(self):
        """GDScript function: game_over(_player: Node = null) -> void"""
        pass

    def gd_func__on_trial_completed(self):
        """GDScript function: _on_trial_completed(trial_id: String, trial_name: String) -> void"""
        pass

    def gd_func__on_exit_reached(self):
        """GDScript function: _on_exit_reached(player: Node) -> void"""
        pass

    def gd_func__on_player_died(self):
        """GDScript function: _on_player_died(player: Node) -> void"""
        pass

    def gd_func__on_objective_updated(self):
        """GDScript function: _on_objective_updated(source: Node, _objective_id: String, title: String, body: String) -> void"""
        pass

    def gd_func__on_tutorial_hint_requested(self):
        """GDScript function: _on_tutorial_hint_requested(_source: Node, _hint_id: String, text: String, _priority: int) -> void"""
        pass

    def gd_func__on_bone_collected(self):
        """GDScript function: _on_bone_collected(bone_id: String, _collector: Node) -> void"""
        pass

    def gd_func__on_bone_equipped(self):
        """GDScript function: _on_bone_equipped(_bone_id: String, _slot: String, _player: Node) -> void"""
        pass

    def gd_func__on_inventory_open_changed(self):
        """GDScript function: _on_inventory_open_changed(_player: Node, is_open: bool) -> void"""
        pass

    def gd_func__on_camp_state_changed(self):
        """GDScript function: _on_camp_state_changed(camp: Node, unlocked: bool, opened: bool, _remaining_enemies: int) -> void"""
        pass

    def gd_func__show_win_screen(self):
        """GDScript function: _show_win_screen(player: Node, elapsed_ms: int) -> void"""
        pass

    def gd_func__build_help_ui(self):
        """GDScript function: _build_help_ui() -> void"""
        pass

    def gd_func__default_help_text(self):
        """GDScript function: _default_help_text() -> String"""
        pass

    def gd_func__full_help_text(self):
        """GDScript function: _full_help_text() -> String"""
        pass

    def gd_func__refresh_help_ui(self):
        """GDScript function: _refresh_help_ui() -> void"""
        pass

    def gd_func__reset_control_tutorial(self):
        """GDScript function: _reset_control_tutorial() -> void"""
        pass

    def gd_func__complete_control_tutorial_step(self):
        """GDScript function: _complete_control_tutorial_step(step_id: String) -> void"""
        pass

    def gd_func__control_tutorial_text(self):
        """GDScript function: _control_tutorial_text() -> String"""
        pass

    def gd_func__control_tutorial_line(self):
        """GDScript function: _control_tutorial_line(step_id: String) -> String"""
        pass

    def gd_func__control_tutorial_label(self):
        """GDScript function: _control_tutorial_label(step_id: String) -> String"""
        pass

    def gd_func__movement_binding_text(self):
        """GDScript function: _movement_binding_text() -> String"""
        pass

    def gd_func__action_binding_text(self):
        """GDScript function: _action_binding_text(action: String) -> String"""
        pass

    def gd_func__build_win_ui(self):
        """GDScript function: _build_win_ui() -> void"""
        pass

    def uses_game_event_trial_completed(self):
        """Uses GameEvents.trial_completed."""
        pass

    def uses_game_event_exit_reached(self):
        """Uses GameEvents.exit_reached."""
        pass

    def uses_game_event_player_died(self):
        """Uses GameEvents.player_died."""
        pass

    def uses_game_event_objective_updated(self):
        """Uses GameEvents.objective_updated."""
        pass

    def uses_game_event_tutorial_hint_requested(self):
        """Uses GameEvents.tutorial_hint_requested."""
        pass

    def uses_game_event_bone_collected(self):
        """Uses GameEvents.bone_collected."""
        pass

    def uses_game_event_bone_equipped(self):
        """Uses GameEvents.bone_equipped."""
        pass

    def uses_game_event_inventory_open_changed(self):
        """Uses GameEvents.inventory_open_changed."""
        pass

    def uses_game_event_camp_state_changed(self):
        """Uses GameEvents.camp_state_changed."""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

class ArrowProjectile:
    """Godot script: scripts/arrow_projectile.gd
    class_name: ArrowProjectile
    extends: Area3D
    system: Combat and enemies
    """
    source_file = 'scripts/arrow_projectile.gd'
    godot_class_name = 'ArrowProjectile'
    godot_extends = 'Area3D'
    gameplay_system = 'Combat and enemies'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func_configure(self):
        """GDScript function: configure(start_position: Vector3, launch_velocity: Vector3, hit_damage: int, source_body: Node, should_damage_player: bool, gravity_value: float = 6.0, visual_style: String = "arrow") -> void"""
        pass

    def gd_func__physics_process(self):
        """GDScript function: _physics_process(delta: float) -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node) -> void"""
        pass

    def gd_func__on_area_entered(self):
        """GDScript function: _on_area_entered(area: Area3D) -> void"""
        pass

    def gd_func__try_hit_body_part_area(self):
        """GDScript function: _try_hit_body_part_area(area: Area3D, group_name: String, method_name: String, extra_args: Array) -> void"""
        pass

    def gd_func__damage_owner_for_area(self):
        """GDScript function: _damage_owner_for_area(area: Area3D) -> Node"""
        pass

    def gd_func__body_part_for_area(self):
        """GDScript function: _body_part_for_area(area: Area3D) -> String"""
        pass

    def gd_func__build_visuals(self):
        """GDScript function: _build_visuals() -> void"""
        pass

class AttackHitbox:
    """Godot script: scripts/attack_hitbox.gd
    class_name: none
    extends: Area3D
    system: Combat and enemies
    """
    source_file = 'scripts/attack_hitbox.gd'
    godot_class_name = ''
    godot_extends = 'Area3D'
    gameplay_system = 'Combat and enemies'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__physics_process(self):
        """GDScript function: _physics_process(_delta: float) -> void"""
        pass

    def gd_func__apply_shape_override(self):
        """GDScript function: _apply_shape_override() -> void"""
        pass

    def gd_func__override_sphere_radius(self):
        """GDScript function: _override_sphere_radius() -> float"""
        pass

    def gd_func__update_follow_position(self):
        """GDScript function: _update_follow_position() -> void"""
        pass

    def gd_func__apply_visual_state(self):
        """GDScript function: _apply_visual_state() -> void"""
        pass

    def gd_func__start_fade(self):
        """GDScript function: _start_fade() -> void"""
        pass

    def gd_func__hit_current_overlaps(self):
        """GDScript function: _hit_current_overlaps() -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node) -> void"""
        pass

    def gd_func__on_area_entered(self):
        """GDScript function: _on_area_entered(area: Area3D) -> void"""
        pass

    def gd_func__try_hit_body(self):
        """GDScript function: _try_hit_body(body: Node) -> void"""
        pass

    def gd_func__body_should_confirm_contact(self):
        """GDScript function: _body_should_confirm_contact(body: Node) -> bool"""
        pass

    def gd_func__is_ground_like_body(self):
        """GDScript function: _is_ground_like_body(body: Node) -> bool"""
        pass

    def gd_func__body_top_y(self):
        """GDScript function: _body_top_y(body: Node) -> float"""
        pass

    def gd_func__try_hit_enemy_area(self):
        """GDScript function: _try_hit_enemy_area(area: Area3D) -> void"""
        pass

    def gd_func__damage_owner_for_area(self):
        """GDScript function: _damage_owner_for_area(area: Area3D) -> Node"""
        pass

    def gd_func__body_part_for_area(self):
        """GDScript function: _body_part_for_area(area: Area3D) -> String"""
        pass

    def gd_func__confirm_contact(self):
        """GDScript function: _confirm_contact(target: Node) -> void"""
        pass

    def signal_hit_confirmed(self):
        """Godot signal: hit_confirmed(target: Node)"""
        pass

class BackstabRulesService:
    """Godot script: scripts/backstab_rules_service.gd
    class_name: BackstabRulesService
    extends: unknown
    system: Supporting gameplay
    """
    source_file = 'scripts/backstab_rules_service.gd'
    godot_class_name = 'BackstabRulesService'
    godot_extends = ''
    gameplay_system = 'Supporting gameplay'

    pass

class BallisticsService:
    """Godot script: scripts/ballistics_service.gd
    class_name: BallisticsService
    extends: unknown
    system: Supporting gameplay
    """
    source_file = 'scripts/ballistics_service.gd'
    godot_class_name = 'BallisticsService'
    godot_extends = ''
    gameplay_system = 'Supporting gameplay'

    pass

class Bone:
    """Godot script: scripts/bone.gd
    class_name: none
    extends: Area3D
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/bone.gd'
    godot_class_name = ''
    godot_extends = 'Area3D'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(delta: float) -> void"""
        pass

    def gd_func_set_bone_id(self):
        """GDScript function: set_bone_id(new_bone_id: String) -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node3D) -> void"""
        pass

    def gd_func__on_body_exited(self):
        """GDScript function: _on_body_exited(body: Node3D) -> void"""
        pass

    def gd_func__collect(self):
        """GDScript function: _collect() -> void"""
        pass

    def gd_func__update_prompt(self):
        """GDScript function: _update_prompt() -> void"""
        pass

    def gd_func__prepare_materials(self):
        """GDScript function: _prepare_materials() -> void"""
        pass

    def gd_func__update_appearance(self):
        """GDScript function: _update_appearance() -> void"""
        pass

    def uses_game_event_pickup_focus_changed(self):
        """Uses GameEvents.pickup_focus_changed."""
        pass

    def uses_game_event_pickup_collected(self):
        """Uses GameEvents.pickup_collected."""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

class BoneDataCatalog:
    """Godot script: scripts/bone_data_catalog.gd
    class_name: BoneDataCatalog
    extends: unknown
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/bone_data_catalog.gd'
    godot_class_name = 'BoneDataCatalog'
    godot_extends = ''
    gameplay_system = 'Inventory, equipment, and bones'

    def depends_on_BoneDatabase(self):
        """Relationship: references class BoneDatabase."""
        return BoneDatabase

    def depends_on_BoneDefinition(self):
        """Relationship: references class BoneDefinition."""
        return BoneDefinition

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

class BoneDatabase:
    """Godot script: scripts/bone_database.gd
    class_name: BoneDatabase
    extends: unknown
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/bone_database.gd'
    godot_class_name = 'BoneDatabase'
    godot_extends = ''
    gameplay_system = 'Inventory, equipment, and bones'

    def depends_on_BoneDataCatalog(self):
        """Relationship: references class BoneDataCatalog."""
        return BoneDataCatalog

    def depends_on_BoneDefinition(self):
        """Relationship: references class BoneDefinition."""
        return BoneDefinition

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

class BoneDefinition:
    """Godot script: scripts/bone_definition.gd
    class_name: BoneDefinition
    extends: Resource
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/bone_definition.gd'
    godot_class_name = 'BoneDefinition'
    godot_extends = 'Resource'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_to_clean_dictionary(self):
        """GDScript function: to_clean_dictionary() -> Dictionary"""
        pass

    def gd_func_to_legacy_dictionary(self):
        """GDScript function: to_legacy_dictionary() -> Dictionary"""
        pass

    def depends_on_BoneDatabase(self):
        """Relationship: references class BoneDatabase."""
        return BoneDatabase

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

class BoneRulesService:
    """Godot script: scripts/bone_rules_service.gd
    class_name: BoneRulesService
    extends: unknown
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/bone_rules_service.gd'
    godot_class_name = 'BoneRulesService'
    godot_extends = ''
    gameplay_system = 'Inventory, equipment, and bones'

    def depends_on_BoneDatabase(self):
        """Relationship: references class BoneDatabase."""
        return BoneDatabase

    def depends_on_BoneDefinition(self):
        """Relationship: references class BoneDefinition."""
        return BoneDefinition

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

class BoneTrialGate:
    """Godot script: scripts/bone_trial_gate.gd
    class_name: none
    extends: Area3D
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/bone_trial_gate.gd'
    godot_class_name = ''
    godot_extends = 'Area3D'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(_delta: float) -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node3D) -> void"""
        pass

    def gd_func__on_body_exited(self):
        """GDScript function: _on_body_exited(body: Node3D) -> void"""
        pass

    def gd_func__try_complete_with(self):
        """GDScript function: _try_complete_with(player: Node3D) -> void"""
        pass

    def gd_func__prepare_material(self):
        """GDScript function: _prepare_material() -> void"""
        pass

    def gd_func__update_appearance(self):
        """GDScript function: _update_appearance() -> void"""
        pass

    def gd_func__update_label(self):
        """GDScript function: _update_label() -> void"""
        pass

    def gd_func__set_gate_color(self):
        """GDScript function: _set_gate_color(color: Color) -> void"""
        pass

    def uses_game_event_trial_completed(self):
        """Uses GameEvents.trial_completed."""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

class CombatTargetingService:
    """Godot script: scripts/combat_targeting_service.gd
    class_name: CombatTargetingService
    extends: unknown
    system: Supporting gameplay
    """
    source_file = 'scripts/combat_targeting_service.gd'
    godot_class_name = 'CombatTargetingService'
    godot_extends = ''
    gameplay_system = 'Supporting gameplay'

    pass

class DemoEnemyCamp:
    """Godot script: scripts/demo_enemy_camp.gd
    class_name: DemoEnemyCamp
    extends: Node3D
    system: Combat and enemies
    """
    source_file = 'scripts/demo_enemy_camp.gd'
    godot_class_name = 'DemoEnemyCamp'
    godot_extends = 'Node3D'
    gameplay_system = 'Combat and enemies'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func_register_enemy(self):
        """GDScript function: register_enemy(enemy: Node) -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(delta: float) -> void"""
        pass

    def gd_func__update_state(self):
        """GDScript function: _update_state() -> void"""
        pass

    def gd_func__on_enemy_defeated(self):
        """GDScript function: _on_enemy_defeated(enemy: Node, _dropped_bone_id: String) -> void"""
        pass

    def gd_func__emit_camp_state_changed(self):
        """GDScript function: _emit_camp_state_changed() -> void"""
        pass

    def gd_func__open_chest(self):
        """GDScript function: _open_chest() -> void"""
        pass

    def gd_func__on_chest_body_entered(self):
        """GDScript function: _on_chest_body_entered(body: Node3D) -> void"""
        pass

    def gd_func__on_chest_body_exited(self):
        """GDScript function: _on_chest_body_exited(body: Node3D) -> void"""
        pass

    def gd_func__reserve_player_interact_lock(self):
        """GDScript function: _reserve_player_interact_lock() -> void"""
        pass

    def gd_func__release_player_interact_lock(self):
        """GDScript function: _release_player_interact_lock() -> void"""
        pass

    def gd_func__build_visuals(self):
        """GDScript function: _build_visuals() -> void"""
        pass

    def gd_func__build_campfire(self):
        """GDScript function: _build_campfire() -> void"""
        pass

    def gd_func__build_chest(self):
        """GDScript function: _build_chest() -> void"""
        pass

    def gd_func__update_chest_visual(self):
        """GDScript function: _update_chest_visual() -> void"""
        pass

    def gd_func__update_label(self):
        """GDScript function: _update_label() -> void"""
        pass

    def gd_func__remaining_enemy_count(self):
        """GDScript function: _remaining_enemy_count() -> int"""
        pass

    def gd_func__make_material(self):
        """GDScript function: _make_material(color: Color, glowing: bool = false) -> StandardMaterial3D"""
        pass

    def uses_game_event_enemy_defeated(self):
        """Uses GameEvents.enemy_defeated."""
        pass

    def uses_game_event_camp_state_changed(self):
        """Uses GameEvents.camp_state_changed."""
        pass

    def uses_game_event_camp_chest_opened(self):
        """Uses GameEvents.camp_chest_opened."""
        pass

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

class DropPickupRulesService:
    """Godot script: scripts/drop_pickup_rules_service.gd
    class_name: DropPickupRulesService
    extends: unknown
    system: Supporting gameplay
    """
    source_file = 'scripts/drop_pickup_rules_service.gd'
    godot_class_name = 'DropPickupRulesService'
    godot_extends = ''
    gameplay_system = 'Supporting gameplay'

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

class Enemy:
    """Godot script: scripts/enemy.gd
    class_name: none
    extends: CharacterBody3D
    system: Combat and enemies
    """
    source_file = 'scripts/enemy.gd'
    godot_class_name = ''
    godot_extends = 'CharacterBody3D'
    gameplay_system = 'Combat and enemies'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(delta: float) -> void"""
        pass

    def gd_func__physics_process(self):
        """GDScript function: _physics_process(delta: float) -> void"""
        pass

    def gd_func__get_player(self):
        """GDScript function: _get_player() -> Node3D"""
        pass

    def gd_func__player_is_dead(self):
        """GDScript function: _player_is_dead(player: Node) -> bool"""
        pass

    def gd_func__update_dummy_target_physics(self):
        """GDScript function: _update_dummy_target_physics(delta: float) -> void"""
        pass

    def gd_func__apply_enemy_movement(self):
        """GDScript function: _apply_enemy_movement() -> void"""
        pass

    def gd_func__is_lizard_wall_climb_enabled(self):
        """GDScript function: _is_lizard_wall_climb_enabled() -> bool"""
        pass

    def gd_func__apply_lizard_wall_climb_velocity(self):
        """GDScript function: _apply_lizard_wall_climb_velocity() -> void"""
        pass

    def gd_func__update_lizard_wall_climb_blend(self):
        """GDScript function: _update_lizard_wall_climb_blend(delta: float) -> void"""
        pass

    def gd_func__lizard_wall_probe_blocked(self):
        """GDScript function: _lizard_wall_probe_blocked() -> bool"""
        pass

    def gd_func__try_attack_player(self):
        """GDScript function: _try_attack_player(player: Node) -> void"""
        pass

    def gd_func__can_start_saliva_spit(self):
        """GDScript function: _can_start_saliva_spit(player: Node3D, distance_to_player: float) -> bool"""
        pass

    def gd_func__start_saliva_spit(self):
        """GDScript function: _start_saliva_spit(player: Node3D) -> void"""
        pass

    def gd_func__update_saliva_spit_windup(self):
        """GDScript function: _update_saliva_spit_windup(delta: float, player: Node3D) -> void"""
        pass

    def gd_func__fire_saliva_spit(self):
        """GDScript function: _fire_saliva_spit() -> void"""
        pass

    def gd_func__can_start_ranged_attack(self):
        """GDScript function: _can_start_ranged_attack(player: Node3D, distance_to_player: float) -> bool"""
        pass

    def gd_func__start_ranged_attack(self):
        """GDScript function: _start_ranged_attack(player: Node3D) -> void"""
        pass

    def gd_func__update_ranged_attack_windup(self):
        """GDScript function: _update_ranged_attack_windup(delta: float, player: Node3D) -> void"""
        pass

    def gd_func__fire_enemy_arrow(self):
        """GDScript function: _fire_enemy_arrow() -> void"""
        pass

    def gd_func__can_start_rock_throw(self):
        """GDScript function: _can_start_rock_throw(player: Node3D, distance_to_player: float) -> bool"""
        pass

    def gd_func__start_rock_throw(self):
        """GDScript function: _start_rock_throw(player: Node3D) -> void"""
        pass

    def gd_func__update_rock_throw_windup(self):
        """GDScript function: _update_rock_throw_windup(delta: float, player: Node3D) -> void"""
        pass

    def gd_func__throw_held_rock(self):
        """GDScript function: _throw_held_rock() -> void"""
        pass

    def gd_func__show_held_rock(self):
        """GDScript function: _show_held_rock() -> void"""
        pass

    def gd_func__cancel_held_rock(self):
        """GDScript function: _cancel_held_rock() -> void"""
        pass

    def gd_func__get_held_rock_world_position(self):
        """GDScript function: _get_held_rock_world_position() -> Vector3"""
        pass

    def gd_func__get_rock_throw_socket(self):
        """GDScript function: _get_rock_throw_socket() -> Node3D"""
        pass

    def gd_func_can_be_stealth_finished_by(self):
        """GDScript function: can_be_stealth_finished_by(player: Node3D) -> bool"""
        pass

    def gd_func_get_stealth_prompt_text(self):
        """GDScript function: get_stealth_prompt_text() -> String"""
        pass

    def gd_func_get_drop_display_name(self):
        """GDScript function: get_drop_display_name() -> String"""
        pass

    def gd_func__is_player_behind(self):
        """GDScript function: _is_player_behind(player: Node3D) -> bool"""
        pass

    def gd_func_try_stealth_finish(self):
        """GDScript function: try_stealth_finish(player: Node3D, player_damage: int, hit_from: Vector3) -> bool"""
        pass

    def gd_func_apply_stealth_finish_impact(self):
        """GDScript function: apply_stealth_finish_impact(player: Node3D, player_damage: int, hit_from: Vector3) -> bool"""
        pass

    def gd_func_finish_stealth_execution(self):
        """GDScript function: finish_stealth_execution(player: Node3D) -> void"""
        pass

    def gd_func_cancel_stealth_execution(self):
        """GDScript function: cancel_stealth_execution(player: Node3D) -> void"""
        pass

    def gd_func__begin_stealth_execution(self):
        """GDScript function: _begin_stealth_execution(player: Node3D, hit_from: Vector3) -> void"""
        pass

    def gd_func__clear_stealth_execution(self):
        """GDScript function: _clear_stealth_execution() -> void"""
        pass

    def gd_func__update_stealth_execution_hold(self):
        """GDScript function: _update_stealth_execution_hold() -> bool"""
        pass

    def gd_func__can_see_player(self):
        """GDScript function: _can_see_player(player: Node3D, to_player: Vector3, dist: float) -> bool"""
        pass

    def gd_func__can_hear_player(self):
        """GDScript function: _can_hear_player(player: Node, dist: float) -> bool"""
        pass

    def gd_func__investigate_position(self):
        """GDScript function: _investigate_position(position: Vector3, duration: float) -> void"""
        pass

    def gd_func_receive_alert(self):
        """GDScript function: receive_alert(position: Vector3) -> void"""
        pass

    def gd_func__alert_nearby_allies(self):
        """GDScript function: _alert_nearby_allies(position: Vector3) -> void"""
        pass

    def gd_func__turn_toward(self):
        """GDScript function: _turn_toward(direction: Vector3) -> void"""
        pass

    def gd_func__build_vision_cone(self):
        """GDScript function: _build_vision_cone() -> void"""
        pass

    def gd_func__set_player_visible(self):
        """GDScript function: _set_player_visible(new_value: bool, force_visual: bool = false) -> void"""
        pass

    def gd_func__get_search_move(self):
        """GDScript function: _get_search_move(delta: float) -> Vector3"""
        pass

    def gd_func__scan_while_searching(self):
        """GDScript function: _scan_while_searching(base_direction: Vector3, delta: float) -> void"""
        pass

    def gd_func__get_return_home_move(self):
        """GDScript function: _get_return_home_move() -> Vector3"""
        pass

    def gd_func__get_idle_wander_move(self):
        """GDScript function: _get_idle_wander_move(delta: float) -> Vector3"""
        pass

    def gd_func__get_flee_move(self):
        """GDScript function: _get_flee_move(player: Node3D, dist: float) -> Vector3"""
        pass

    def gd_func__update_bone_recovery_safety(self):
        """GDScript function: _update_bone_recovery_safety(delta: float, player: Node3D, distance_to_player: float) -> void"""
        pass

    def gd_func__can_recover_bone_part(self):
        """GDScript function: _can_recover_bone_part() -> bool"""
        pass

    def gd_func__get_bone_recovery_move(self):
        """GDScript function: _get_bone_recovery_move() -> Vector3"""
        pass

    def gd_func__get_recovering_limb_key(self):
        """GDScript function: _get_recovering_limb_key() -> String"""
        pass

    def gd_func__is_detached_limb_body_valid(self):
        """GDScript function: _is_detached_limb_body_valid(limb_key: String) -> bool"""
        pass

    def gd_func__recover_detached_limb(self):
        """GDScript function: _recover_detached_limb(limb_key: String) -> void"""
        pass

    def gd_func__recovery_group_key(self):
        """GDScript function: _recovery_group_key(limb_key: String) -> String"""
        pass

    def gd_func__limb_recovery_group(self):
        """GDScript function: _limb_recovery_group(limb_key: String) -> Array[String]"""
        pass

    def gd_func__has_active_limb_pickup(self):
        """GDScript function: _has_active_limb_pickup() -> bool"""
        pass

    def gd_func__forget_detached_limb_body(self):
        """GDScript function: _forget_detached_limb_body(limb_key: String) -> void"""
        pass

    def gd_func__steer_around_obstacles(self):
        """GDScript function: _steer_around_obstacles(desired_direction: Vector3) -> Vector3"""
        pass

    def gd_func__movement_blocked(self):
        """GDScript function: _movement_blocked(direction: Vector3) -> bool"""
        pass

    def gd_func__get_slide_around_obstacle(self):
        """GDScript function: _get_slide_around_obstacle(desired_direction: Vector3) -> Vector3"""
        pass

    def gd_func__update_vision_visual(self):
        """GDScript function: _update_vision_visual(can_see_player: bool) -> void"""
        pass

    def gd_func_take_damage(self):
        """GDScript function: take_damage(amount: int, hit_from: Vector3 = Vector3.ZERO, attacker: Node = null, damage_source: String = "") -> void"""
        pass

    def gd_func_take_enemy_body_part_damage(self):
        """GDScript function: take_enemy_body_part_damage(body_part: String, amount: int, hit_from: Vector3 = Vector3.ZERO, attacker: Node = null, damage_source: String = "") -> void"""
        pass

    def gd_func_has_body_part_hitboxes(self):
        """GDScript function: has_body_part_hitboxes() -> bool"""
        pass

    def gd_func__react_to_arrow_hit(self):
        """GDScript function: _react_to_arrow_hit(attacker: Node, hit_from: Vector3) -> void"""
        pass

    def gd_func__apply_knockback(self):
        """GDScript function: _apply_knockback(hit_from: Vector3) -> void"""
        pass

    def gd_func_take_hit(self):
        """GDScript function: take_hit(damage: int) -> void"""
        pass

    def gd_func__maybe_start_low_health_flee(self):
        """GDScript function: _maybe_start_low_health_flee() -> void"""
        pass

    def gd_func__detach_limbs_for_damage(self):
        """GDScript function: _detach_limbs_for_damage(damage_taken: int, killing_hit: bool = false) -> void"""
        pass

    def gd_func__limb_detach_count_for_damage(self):
        """GDScript function: _limb_detach_count_for_damage(damage_taken: int, killing_hit: bool) -> int"""
        pass

    def gd_func__next_attached_limb_key(self):
        """GDScript function: _next_attached_limb_key() -> String"""
        pass

    def gd_func__preferred_detach_keys(self):
        """GDScript function: _preferred_detach_keys() -> Array[String]"""
        pass

    def gd_func__detach_limb_group(self):
        """GDScript function: _detach_limb_group(limb_key: String, force_pickup: bool = false) -> void"""
        pass

    def gd_func__spawn_detached_limb_piece(self):
        """GDScript function: _spawn_detached_limb_piece(limb_key: String, force_pickup: bool = false) -> void"""
        pass

    def gd_func__attach_pickup_to_detached_limb(self):
        """GDScript function: _attach_pickup_to_detached_limb(body: RigidBody3D, pickup_bone_id: String) -> void"""
        pass

    def gd_func__pickup_bone_id_for_limb(self):
        """GDScript function: _pickup_bone_id_for_limb(limb_key: String) -> String"""
        pass

    def gd_func__pickup_source_profile(self):
        """GDScript function: _pickup_source_profile() -> String"""
        pass

    def gd_func__set_rig_limb_visible(self):
        """GDScript function: _set_rig_limb_visible(limb_key: String, is_visible: bool) -> void"""
        pass

    def gd_func__has_lizard_torso_blocks(self):
        """GDScript function: _has_lizard_torso_blocks() -> bool"""
        pass

    def gd_func__set_lizard_torso_blocks_visible(self):
        """GDScript function: _set_lizard_torso_blocks_visible(is_visible: bool) -> void"""
        pass

    def gd_func__restore_attached_limbs(self):
        """GDScript function: _restore_attached_limbs() -> void"""
        pass

    def gd_func__update_crawl_state(self):
        """GDScript function: _update_crawl_state(force_refresh: bool = false) -> void"""
        pass

    def gd_func_die(self):
        """GDScript function: die() -> void"""
        pass

    def gd_func__death_pop(self):
        """GDScript function: _death_pop() -> void"""
        pass

    def gd_func__hide_until_respawn(self):
        """GDScript function: _hide_until_respawn() -> void"""
        pass

    def gd_func__respawn_after_delay(self):
        """GDScript function: _respawn_after_delay(delay_seconds: float) -> void"""
        pass

    def gd_func__respawn(self):
        """GDScript function: _respawn() -> void"""
        pass

    def gd_func__get_respawn_delay(self):
        """GDScript function: _get_respawn_delay() -> float"""
        pass

    def gd_func__spawn_is_out_of_perspective(self):
        """GDScript function: _spawn_is_out_of_perspective() -> bool"""
        pass

    def gd_func__set_collision_enabled(self):
        """GDScript function: _set_collision_enabled(enabled: bool) -> void"""
        pass

    def gd_func__facing_from_rotation(self):
        """GDScript function: _facing_from_rotation() -> Vector3"""
        pass

    def gd_func__punch_scale(self):
        """GDScript function: _punch_scale() -> void"""
        pass

    def gd_func__lunge(self):
        """GDScript function: _lunge() -> void"""
        pass

    def gd_func__kill_scale_tween(self):
        """GDScript function: _kill_scale_tween() -> void"""
        pass

    def gd_func__drop_bone(self):
        """GDScript function: _drop_bone() -> void"""
        pass

    def gd_func__drop_standard_bone_pickup(self):
        """GDScript function: _drop_standard_bone_pickup() -> void"""
        pass

    def gd_func__force_limb_pickup_drop(self):
        """GDScript function: _force_limb_pickup_drop() -> bool"""
        pass

    def gd_func__next_pickup_limb_key(self):
        """GDScript function: _next_pickup_limb_key() -> String"""
        pass

    def gd_func__drop_remaining_limbs_on_death(self):
        """GDScript function: _drop_remaining_limbs_on_death() -> void"""
        pass

    def gd_func__choose_death_pickup_limb_key(self):
        """GDScript function: _choose_death_pickup_limb_key() -> String"""
        pass

    def gd_func__update_health_label(self):
        """GDScript function: _update_health_label() -> void"""
        pass

    def gd_func__flash_hit(self):
        """GDScript function: _flash_hit() -> void"""
        pass

    def gd_func__set_enemy_color(self):
        """GDScript function: _set_enemy_color(new_color: Color) -> void"""
        pass

    def gd_func__setup_procedural_character(self):
        """GDScript function: _setup_procedural_character() -> void"""
        pass

    def gd_func__update_procedural_animation(self):
        """GDScript function: _update_procedural_animation(delta: float) -> void"""
        pass

    def gd_func__get_effective_move_speed(self):
        """GDScript function: _get_effective_move_speed() -> float"""
        pass

    def gd_func__setup_ranged_bow_visual(self):
        """GDScript function: _setup_ranged_bow_visual() -> void"""
        pass

    def gd_func__make_bow_piece(self):
        """GDScript function: _make_bow_piece(piece_name: String, size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D"""
        pass

    def gd_func__set_rig_color(self):
        """GDScript function: _set_rig_color(new_color: Color) -> void"""
        pass

    def gd_func__apply_bone_identity(self):
        """GDScript function: _apply_bone_identity() -> void"""
        pass

    def gd_func__apply_lizard_profile(self):
        """GDScript function: _apply_lizard_profile() -> void"""
        pass

    def gd_func__apply_gorilla_profile(self):
        """GDScript function: _apply_gorilla_profile() -> void"""
        pass

    def gd_func__apply_profile_collision_shape(self):
        """GDScript function: _apply_profile_collision_shape() -> void"""
        pass

    def gd_func__apply_box_collision_shape(self):
        """GDScript function: _apply_box_collision_shape(size_value: Vector3, offset_value: Vector3) -> void"""
        pass

    def gd_func__apply_dummy_target_profile(self):
        """GDScript function: _apply_dummy_target_profile() -> void"""
        pass

    def gd_func__should_use_gorilla_profile(self):
        """GDScript function: _should_use_gorilla_profile() -> bool"""
        pass

    def gd_func__should_use_lizard_profile(self):
        """GDScript function: _should_use_lizard_profile() -> bool"""
        pass

    def gd_func__roll_low_health_personality(self):
        """GDScript function: _roll_low_health_personality() -> void"""
        pass

    def gd_func__make_hit_blip(self):
        """GDScript function: _make_hit_blip() -> AudioStreamWAV"""
        pass

    def gd_func__play_hit_sound(self):
        """GDScript function: _play_hit_sound() -> void"""
        pass

    def uses_game_event_drop_spawned(self):
        """Uses GameEvents.drop_spawned."""
        pass

    def uses_game_event_enemy_defeated(self):
        """Uses GameEvents.enemy_defeated."""
        pass

    def depends_on_SceneBone(self):
        """Relationship: loads resource."""
        return SceneBone

    def depends_on_LimbBonePickup(self):
        """Relationship: loads resource."""
        return LimbBonePickup

    def depends_on_EnemyRockProjectile(self):
        """Relationship: loads resource."""
        return EnemyRockProjectile

    def depends_on_ArrowProjectile(self):
        """Relationship: loads resource."""
        return ArrowProjectile

    def depends_on_BackstabRulesService(self):
        """Relationship: references class BackstabRulesService."""
        return BackstabRulesService

    def depends_on_BallisticsService(self):
        """Relationship: references class BallisticsService."""
        return BallisticsService

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

    def depends_on_ModularSkeletonRig(self):
        """Relationship: references class ModularSkeletonRig."""
        return ModularSkeletonRig

    def depends_on_ProceduralPlayerAnimator(self):
        """Relationship: references class ProceduralPlayerAnimator."""
        return ProceduralPlayerAnimator

class EnemyRockProjectile:
    """Godot script: scripts/enemy_rock_projectile.gd
    class_name: EnemyRockProjectile
    extends: Area3D
    system: Combat and enemies
    """
    source_file = 'scripts/enemy_rock_projectile.gd'
    godot_class_name = 'EnemyRockProjectile'
    godot_extends = 'Area3D'
    gameplay_system = 'Combat and enemies'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func_configure(self):
        """GDScript function: configure(start_position: Vector3, launch_velocity: Vector3, hit_damage: int, source_enemy: Node, projectile_gravity: float = 24.0) -> void"""
        pass

    def gd_func__physics_process(self):
        """GDScript function: _physics_process(delta: float) -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node) -> void"""
        pass

    def gd_func__on_area_entered(self):
        """GDScript function: _on_area_entered(area: Area3D) -> void"""
        pass

    def gd_func__damage_owner_for_area(self):
        """GDScript function: _damage_owner_for_area(area: Area3D) -> Node"""
        pass

    def gd_func__body_part_for_area(self):
        """GDScript function: _body_part_for_area(area: Area3D) -> String"""
        pass

    def gd_func__build_visuals(self):
        """GDScript function: _build_visuals() -> void"""
        pass

class EquipmentRulesService:
    """Godot script: scripts/equipment_rules_service.gd
    class_name: EquipmentRulesService
    extends: unknown
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/equipment_rules_service.gd'
    godot_class_name = 'EquipmentRulesService'
    godot_extends = ''
    gameplay_system = 'Inventory, equipment, and bones'

    def depends_on_BoneDatabase(self):
        """Relationship: references class BoneDatabase."""
        return BoneDatabase

    def depends_on_BoneDefinition(self):
        """Relationship: references class BoneDefinition."""
        return BoneDefinition

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

class ExitPortal:
    """Godot script: scripts/exit_portal.gd
    class_name: none
    extends: Area3D
    system: World, goals, and progression
    """
    source_file = 'scripts/exit_portal.gd'
    godot_class_name = ''
    godot_extends = 'Area3D'
    gameplay_system = 'World, goals, and progression'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(_delta: float) -> void"""
        pass

    def gd_func_open_exit(self):
        """GDScript function: open_exit() -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node3D) -> void"""
        pass

    def gd_func__on_body_exited(self):
        """GDScript function: _on_body_exited(body: Node3D) -> void"""
        pass

    def gd_func__reach_exit(self):
        """GDScript function: _reach_exit(player: Node3D) -> void"""
        pass

    def gd_func__prepare_material(self):
        """GDScript function: _prepare_material() -> void"""
        pass

    def gd_func__update_visuals(self):
        """GDScript function: _update_visuals() -> void"""
        pass

    def gd_func__set_portal_color(self):
        """GDScript function: _set_portal_color(color: Color) -> void"""
        pass

    def uses_game_event_exit_reached(self):
        """Uses GameEvents.exit_reached."""
        pass

class GameEvents:
    """Godot script: scripts/game_events.gd
    class_name: none
    extends: Node
    system: Supporting gameplay
    """
    source_file = 'scripts/game_events.gd'
    godot_class_name = ''
    godot_extends = 'Node'
    gameplay_system = 'Supporting gameplay'

    def signal_bone_collected(self):
        """Godot signal: bone_collected(bone_id: String, collector: Node)"""
        pass

    def signal_bone_equipped(self):
        """Godot signal: bone_equipped(bone_id: String, slot: String, player: Node)"""
        pass

    def signal_bone_unequipped(self):
        """Godot signal: bone_unequipped(bone_id: String, slot: String, player: Node)"""
        pass

    def signal_inventory_changed(self):
        """Godot signal: inventory_changed(player: Node, items: Array, stats: Dictionary)"""
        pass

    def signal_inventory_open_changed(self):
        """Godot signal: inventory_open_changed(player: Node, is_open: bool)"""
        pass

    def signal_pickup_focus_changed(self):
        """Godot signal: pickup_focus_changed(pickup: Node, bone_id: String, player: Node, in_range: bool)"""
        pass

    def signal_pickup_collected(self):
        """Godot signal: pickup_collected(bone_id: String, pickup: Node, collector: Node)"""
        pass

    def signal_drop_spawned(self):
        """Godot signal: drop_spawned(bone_id: String, pickup: Node, source: Node)"""
        pass

    def signal_enemy_defeated(self):
        """Godot signal: enemy_defeated(enemy: Node, dropped_bone_id: String)"""
        pass

    def signal_player_died(self):
        """Godot signal: player_died(player: Node)"""
        pass

    def signal_trial_completed(self):
        """Godot signal: trial_completed(trial_id: String, trial_name: String)"""
        pass

    def signal_exit_reached(self):
        """Godot signal: exit_reached(player: Node)"""
        pass

    def signal_stage_entered(self):
        """Godot signal: stage_entered(stage: Node)"""
        pass

    def signal_stage_exited(self):
        """Godot signal: stage_exited(stage: Node)"""
        pass

    def signal_objective_updated(self):
        """Godot signal: objective_updated(source: Node, objective_id: String, title: String, body: String)"""
        pass

    def signal_tutorial_hint_requested(self):
        """Godot signal: tutorial_hint_requested(source: Node, hint_id: String, text: String, priority: int)"""
        pass

    def signal_camp_state_changed(self):
        """Godot signal: camp_state_changed(camp: Node, unlocked: bool, opened: bool, remaining_enemies: int)"""
        pass

    def signal_camp_chest_opened(self):
        """Godot signal: camp_chest_opened(camp: Node, reward_bone_id: String, player: Node)"""
        pass

class GuideWisp:
    """Godot script: scripts/guide_wisp.gd
    class_name: none
    extends: Node3D
    system: UI and guidance
    """
    source_file = 'scripts/guide_wisp.gd'
    godot_class_name = ''
    godot_extends = 'Node3D'
    gameplay_system = 'UI and guidance'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(delta: float) -> void"""
        pass

    def gd_func__update_motion(self):
        """GDScript function: _update_motion(delta: float) -> void"""
        pass

    def gd_func__find_closest_enemy_target(self):
        """GDScript function: _find_closest_enemy_target() -> Node3D"""
        pass

    def gd_func__update_label(self):
        """GDScript function: _update_label() -> void"""
        pass

    def gd_func__prepare_material(self):
        """GDScript function: _prepare_material() -> void"""
        pass

class LimbBonePickup:
    """Godot script: scripts/limb_bone_pickup.gd
    class_name: none
    extends: Area3D
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/limb_bone_pickup.gd'
    godot_class_name = ''
    godot_extends = 'Area3D'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(delta: float) -> void"""
        pass

    def gd_func_set_bone_id(self):
        """GDScript function: set_bone_id(new_bone_id: String) -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node3D) -> void"""
        pass

    def gd_func__on_body_exited(self):
        """GDScript function: _on_body_exited(body: Node3D) -> void"""
        pass

    def gd_func__collect(self):
        """GDScript function: _collect() -> void"""
        pass

    def gd_func__update_prompt(self):
        """GDScript function: _update_prompt() -> void"""
        pass

    def gd_func__update_prompt_color(self):
        """GDScript function: _update_prompt_color() -> void"""
        pass

    def uses_game_event_pickup_focus_changed(self):
        """Uses GameEvents.pickup_focus_changed."""
        pass

    def uses_game_event_pickup_collected(self):
        """Uses GameEvents.pickup_collected."""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

class MainMenu:
    """Godot script: scripts/main_menu.gd
    class_name: none
    extends: Control
    system: Supporting gameplay
    """
    source_file = 'scripts/main_menu.gd'
    godot_class_name = ''
    godot_extends = 'Control'
    gameplay_system = 'Supporting gameplay'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__build_menu(self):
        """GDScript function: _build_menu() -> void"""
        pass

    def gd_func__make_menu_button(self):
        """GDScript function: _make_menu_button(text: String, callback: Callable) -> Button"""
        pass

    def gd_func__open_demo(self):
        """GDScript function: _open_demo() -> void"""
        pass

    def gd_func__open_testing_environment(self):
        """GDScript function: _open_testing_environment() -> void"""
        pass

    def gd_func__open_dummy_testing_environment(self):
        """GDScript function: _open_dummy_testing_environment() -> void"""
        pass

class OpenWorldStage:
    """Godot script: scripts/open_world_stage.gd
    class_name: none
    extends: Node3D
    system: World, goals, and progression
    """
    source_file = 'scripts/open_world_stage.gd'
    godot_class_name = ''
    godot_extends = 'Node3D'
    gameplay_system = 'World, goals, and progression'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func_refresh_runtime_mesh(self):
        """GDScript function: refresh_runtime_mesh() -> void"""
        pass

    def gd_func__on_body_entered(self):
        """GDScript function: _on_body_entered(body: Node3D) -> void"""
        pass

    def gd_func__on_body_exited(self):
        """GDScript function: _on_body_exited(body: Node3D) -> void"""
        pass

    def gd_func_get_stage_summary(self):
        """GDScript function: get_stage_summary() -> String"""
        pass

    def gd_func__refresh_stage_from_mesh(self):
        """GDScript function: _refresh_stage_from_mesh() -> void"""
        pass

    def gd_func__prepare_material(self):
        """GDScript function: _prepare_material() -> void"""
        pass

    def gd_func__update_label(self):
        """GDScript function: _update_label() -> void"""
        pass

    def uses_game_event_stage_entered(self):
        """Uses GameEvents.stage_entered."""
        pass

    def uses_game_event_stage_exited(self):
        """Uses GameEvents.stage_exited."""
        pass

class Player:
    """Godot script: scripts/player.gd
    class_name: none
    extends: CharacterBody3D
    system: Player orchestration
    """
    source_file = 'scripts/player.gd'
    godot_class_name = ''
    godot_extends = 'CharacterBody3D'
    gameplay_system = 'Player orchestration'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__input(self):
        """GDScript function: _input(event: InputEvent) -> void"""
        pass

    def gd_func__physics_process(self):
        """GDScript function: _physics_process(delta: float) -> void"""
        pass

    def gd_func__get_camera_relative_move_direction(self):
        """GDScript function: _get_camera_relative_move_direction(input_vector: Vector2) -> Vector3"""
        pass

    def gd_func__input_pressed(self):
        """GDScript function: _input_pressed(action: String) -> bool"""
        pass

    def gd_func__input_just_pressed(self):
        """GDScript function: _input_just_pressed(action: String) -> bool"""
        pass

    def gd_func__input_just_released(self):
        """GDScript function: _input_just_released(action: String) -> bool"""
        pass

    def gd_func__get_move_input_vector(self):
        """GDScript function: _get_move_input_vector() -> Vector2"""
        pass

    def gd_func__get_camera_forward_direction(self):
        """GDScript function: _get_camera_forward_direction() -> Vector3"""
        pass

    def gd_func__try_attack(self):
        """GDScript function: _try_attack() -> void"""
        pass

    def gd_func__on_attack_hit_confirmed(self):
        """GDScript function: _on_attack_hit_confirmed(_target: Node) -> void"""
        pass

    def gd_func__acquire_head_launch_target(self):
        """GDScript function: _acquire_head_launch_target() -> void"""
        pass

    def gd_func__head_launch_target_aim(self):
        """GDScript function: _head_launch_target_aim() -> Vector3"""
        pass

    def gd_func__push_head_launch_attack_aim(self):
        """GDScript function: _push_head_launch_attack_aim() -> void"""
        pass

    def gd_func__is_head_launch_combat_mode(self):
        """GDScript function: _is_head_launch_combat_mode() -> bool"""
        pass

    def gd_func__is_head_only_attack_locking_movement(self):
        """GDScript function: _is_head_only_attack_locking_movement() -> bool"""
        pass

    def gd_func__is_head_launch_attack_busy(self):
        """GDScript function: _is_head_launch_attack_busy() -> bool"""
        pass

    def gd_func__is_head_launch_attack_blocked(self):
        """GDScript function: _is_head_launch_attack_blocked() -> bool"""
        pass

    def gd_func__head_launch_attack_input_blocked(self):
        """GDScript function: _head_launch_attack_input_blocked() -> bool"""
        pass

    def gd_func__update_head_launch_recovery(self):
        """GDScript function: _update_head_launch_recovery(delta: float) -> void"""
        pass

    def gd_func__get_head_only_hitbox_follow_target(self):
        """GDScript function: _get_head_only_hitbox_follow_target() -> Node3D"""
        pass

    def gd_func__is_head_only_combat_mode(self):
        """GDScript function: _is_head_only_combat_mode() -> bool"""
        pass

    def gd_func__is_slot_equipped(self):
        """GDScript function: _is_slot_equipped(slot: String) -> bool"""
        pass

    def gd_func__has_any_arm_equipped(self):
        """GDScript function: _has_any_arm_equipped() -> bool"""
        pass

    def gd_func__is_torso_head_launch_combat_mode(self):
        """GDScript function: _is_torso_head_launch_combat_mode() -> bool"""
        pass

    def gd_func__force_head_only_single_visual(self):
        """GDScript function: _force_head_only_single_visual() -> void"""
        pass

    def gd_func__try_bow_shot(self):
        """GDScript function: _try_bow_shot(charge_multiplier: float = 1.0, charge_ratio: float = 0.0) -> void"""
        pass

    def gd_func__start_bow_aim(self):
        """GDScript function: _start_bow_aim() -> void"""
        pass

    def gd_func__release_bow_shot(self):
        """GDScript function: _release_bow_shot() -> void"""
        pass

    def gd_func__cancel_bow_aim(self):
        """GDScript function: _cancel_bow_aim() -> void"""
        pass

    def gd_func__toggle_bow_equipped(self):
        """GDScript function: _toggle_bow_equipped() -> void"""
        pass

    def gd_func__set_bow_equipped(self):
        """GDScript function: _set_bow_equipped(enabled: bool) -> void"""
        pass

    def gd_func__can_use_bow(self):
        """GDScript function: _can_use_bow() -> bool"""
        pass

    def gd_func__fire_player_projectile(self):
        """GDScript function: _fire_player_projectile(forward: Vector3, projectile_damage: int, projectile_speed: float, projectile_gravity: float, projectile_style: String) -> void"""
        pass

    def gd_func__get_pointer_aim_point(self):
        """GDScript function: _get_pointer_aim_point(start_position: Vector3, fallback_direction: Vector3) -> Vector3"""
        pass

    def gd_func__aim_direction_to(self):
        """GDScript function: _aim_direction_to(start_position: Vector3, aim_point: Vector3, fallback_direction: Vector3) -> Vector3"""
        pass

    def gd_func__try_stealth_finish(self):
        """GDScript function: _try_stealth_finish() -> void"""
        pass

    def gd_func__start_backstab_execution(self):
        """GDScript function: _start_backstab_execution(target: Node3D, damage: int, hit_from: Vector3) -> void"""
        pass

    def gd_func__update_backstab_execution(self):
        """GDScript function: _update_backstab_execution(delta: float) -> void"""
        pass

    def gd_func__on_backstab_animator_impact(self):
        """GDScript function: _on_backstab_animator_impact() -> void"""
        pass

    def gd_func__apply_backstab_impact_once(self):
        """GDScript function: _apply_backstab_impact_once() -> void"""
        pass

    def gd_func__finish_backstab_execution(self):
        """GDScript function: _finish_backstab_execution() -> void"""
        pass

    def gd_func__cancel_backstab_execution(self):
        """GDScript function: _cancel_backstab_execution() -> void"""
        pass

    def gd_func__clear_backstab_execution_state(self):
        """GDScript function: _clear_backstab_execution_state() -> void"""
        pass

    def gd_func__is_backstab_executing(self):
        """GDScript function: _is_backstab_executing() -> bool"""
        pass

    def gd_func__face_backstab_target(self):
        """GDScript function: _face_backstab_target(target: Node3D) -> void"""
        pass

    def gd_func__next_combo_animation_step(self):
        """GDScript function: _next_combo_animation_step() -> int"""
        pass

    def gd_func__is_arm_sword_held(self):
        """GDScript function: _is_arm_sword_held() -> bool"""
        pass

    def gd_func__has_both_arms_equipped(self):
        """GDScript function: _has_both_arms_equipped() -> bool"""
        pass

    def gd_func__combo_animation_window(self):
        """GDScript function: _combo_animation_window() -> float"""
        pass

    def gd_func__flash_player_attack(self):
        """GDScript function: _flash_player_attack() -> void"""
        pass

    def gd_func__setup_procedural_character(self):
        """GDScript function: _setup_procedural_character() -> void"""
        pass

    def gd_func__build_bow_visual(self):
        """GDScript function: _build_bow_visual() -> void"""
        pass

    def gd_func__get_bow_visual_parent(self):
        """GDScript function: _get_bow_visual_parent() -> Node3D"""
        pass

    def gd_func__build_aim_reticle_ui(self):
        """GDScript function: _build_aim_reticle_ui() -> void"""
        pass

    def gd_func__make_reticle_rect(self):
        """GDScript function: _make_reticle_rect(rect_name: String, left: float, top: float, right: float, bottom: float, color: Color) -> ColorRect"""
        pass

    def gd_func__set_aim_reticle_visible(self):
        """GDScript function: _set_aim_reticle_visible(visible: bool) -> void"""
        pass

    def gd_func__update_aim_reticle_ui(self):
        """GDScript function: _update_aim_reticle_ui() -> void"""
        pass

    def gd_func__get_bow_charge_ratio(self):
        """GDScript function: _get_bow_charge_ratio() -> float"""
        pass

    def gd_func__get_bow_charge_multiplier(self):
        """GDScript function: _get_bow_charge_multiplier() -> float"""
        pass

    def gd_func__make_bow_piece(self):
        """GDScript function: _make_bow_piece(piece_name: String, size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D"""
        pass

    def gd_func__update_procedural_animation(self):
        """GDScript function: _update_procedural_animation(delta: float, max_speed: float) -> void"""
        pass

    def gd_func__apply_head_only_lunge_displacement(self):
        """GDScript function: _apply_head_only_lunge_displacement(offset: Vector3) -> void"""
        pass

    def gd_func__update_camera_animation_follow_offset(self):
        """GDScript function: _update_camera_animation_follow_offset() -> void"""
        pass

    def gd_func_collect_bone(self):
        """GDScript function: collect_bone(bone_id: String) -> void"""
        pass

    def gd_func_get_equipped_bone_id(self):
        """GDScript function: get_equipped_bone_id() -> String"""
        pass

    def gd_func_has_bone_equipped(self):
        """GDScript function: has_bone_equipped(bone_id: String) -> bool"""
        pass

    def gd_func_get_run_stats(self):
        """GDScript function: get_run_stats() -> Dictionary"""
        pass

    def gd_func_get_inventory_items(self):
        """GDScript function: get_inventory_items() -> Array"""
        pass

    def gd_func_get_equipment_state(self):
        """GDScript function: get_equipment_state() -> Dictionary"""
        pass

    def gd_func_get_equipped_bone_for_slot(self):
        """GDScript function: get_equipped_bone_for_slot(slot: String) -> String"""
        pass

    def gd_func_get_inventory_stats_snapshot(self):
        """GDScript function: get_inventory_stats_snapshot() -> Dictionary"""
        pass

    def gd_func_save_equipment_build(self):
        """GDScript function: save_equipment_build(index: int) -> Dictionary"""
        pass

    def gd_func_apply_equipment_build(self):
        """GDScript function: apply_equipment_build(index: int) -> Dictionary"""
        pass

    def gd_func_get_equipment_build_summaries(self):
        """GDScript function: get_equipment_build_summaries() -> Array"""
        pass

    def gd_func_take_player_damage(self):
        """GDScript function: take_player_damage(amount: int, from_position: Vector3 = Vector3.ZERO) -> void"""
        pass

    def gd_func_take_player_body_part_damage(self):
        """GDScript function: take_player_body_part_damage(body_part: String, amount: int, from_position: Vector3 = Vector3.ZERO) -> void"""
        pass

    def gd_func_has_body_part_hitboxes(self):
        """GDScript function: has_body_part_hitboxes() -> bool"""
        pass

    def gd_func_is_player_dead(self):
        """GDScript function: is_player_dead() -> bool"""
        pass

    def gd_func_get_noise_radius(self):
        """GDScript function: get_noise_radius() -> float"""
        pass

    def gd_func__die_player(self):
        """GDScript function: _die_player() -> void"""
        pass

    def gd_func__flash_player_damage(self):
        """GDScript function: _flash_player_damage() -> void"""
        pass

    def gd_func__equip_next_bone(self):
        """GDScript function: _equip_next_bone() -> void"""
        pass

    def gd_func_equip_bone(self):
        """GDScript function: equip_bone(bone_id: String, target_slot: String = "") -> void"""
        pass

    def gd_func_unequip_slot(self):
        """GDScript function: unequip_slot(slot: String) -> void"""
        pass

    def gd_func_show_bone_info(self):
        """GDScript function: show_bone_info(bone_id: String) -> void"""
        pass

    def gd_func_clear_bone_info(self):
        """GDScript function: clear_bone_info() -> void"""
        pass

    def gd_func_get_equipment_socket_for_slot(self):
        """GDScript function: get_equipment_socket_for_slot(slot: String) -> Node3D"""
        pass

    def gd_func_recalculate_player_stats(self):
        """GDScript function: recalculate_player_stats() -> void"""
        pass

    def gd_func_recalculate_inventory_stats(self):
        """GDScript function: recalculate_inventory_stats() -> void"""
        pass

    def gd_func__recalculate_stats(self):
        """GDScript function: _recalculate_stats() -> void"""
        pass

    def gd_func__update_stealth_finish_prompt(self):
        """GDScript function: _update_stealth_finish_prompt() -> void"""
        pass

    def gd_func_is_head_detached_from_torso(self):
        """GDScript function: is_head_detached_from_torso() -> bool"""
        pass

    def gd_func__detach_head_from_torso_after_miss(self):
        """GDScript function: _detach_head_from_torso_after_miss(detach_offset: Vector3, detached_body_transform: Transform3D = Transform3D.IDENTITY, use_detached_body_transform: bool = false) -> void"""
        pass

    def gd_func__detached_head_ground_local_position(self):
        """GDScript function: _detached_head_ground_local_position(launch_offset: Vector3) -> Vector3"""
        pass

    def gd_func__spawn_detached_torso_marker(self):
        """GDScript function: _spawn_detached_torso_marker(body_bone_id: String, detached_body_transform: Transform3D = Transform3D.IDENTITY, use_detached_body_transform: bool = false) -> void"""
        pass

    def gd_func__grounded_detached_torso_marker_position(self):
        """GDScript function: _grounded_detached_torso_marker_position(anchor_position: Vector3, torso_height: float) -> Vector3"""
        pass

    def gd_func__update_detached_torso_reattach(self):
        """GDScript function: _update_detached_torso_reattach(delta: float) -> bool"""
        pass

    def gd_func__begin_detached_torso_reattach_animation(self):
        """GDScript function: _begin_detached_torso_reattach_animation() -> void"""
        pass

    def gd_func__update_detached_torso_reattach_animation(self):
        """GDScript function: _update_detached_torso_reattach_animation() -> void"""
        pass

    def gd_func__cancel_detached_torso_reattach_animation(self):
        """GDScript function: _cancel_detached_torso_reattach_animation() -> void"""
        pass

    def gd_func__finish_reattach_head_to_detached_torso(self):
        """GDScript function: _finish_reattach_head_to_detached_torso() -> void"""
        pass

    def gd_func__current_head_world_position(self):
        """GDScript function: _current_head_world_position() -> Vector3"""
        pass

    def gd_func__align_player_body_pose_to_detached_torso_marker(self):
        """GDScript function: _align_player_body_pose_to_detached_torso_marker() -> void"""
        pass

    def gd_func__detached_torso_head_attach_offset(self):
        """GDScript function: _detached_torso_head_attach_offset() -> Vector3"""
        pass

    def gd_func__clear_detached_torso_marker(self):
        """GDScript function: _clear_detached_torso_marker() -> void"""
        pass

    def gd_func__set_detached_torso_marker_prompt_visible(self):
        """GDScript function: _set_detached_torso_marker_prompt_visible(is_visible: bool) -> void"""
        pass

    def gd_func__as_vector3(self):
        """GDScript function: _as_vector3(value: Variant, fallback: Vector3) -> Vector3"""
        pass

    def gd_func__find_stealth_target(self):
        """GDScript function: _find_stealth_target() -> Node3D"""
        pass

    def gd_func_enter_interact_range(self):
        """GDScript function: enter_interact_range() -> void"""
        pass

    def gd_func_exit_interact_range(self):
        """GDScript function: exit_interact_range() -> void"""
        pass

    def gd_func_enter_bone_pickup_range(self):
        """GDScript function: enter_bone_pickup_range() -> void"""
        pass

    def gd_func_exit_bone_pickup_range(self):
        """GDScript function: exit_bone_pickup_range() -> void"""
        pass

    def gd_func_get_inventory_tile_size(self):
        """GDScript function: get_inventory_tile_size() -> Vector2"""
        pass

    def gd_func__build_health_ui(self):
        """GDScript function: _build_health_ui() -> void"""
        pass

    def gd_func__update_health_ui(self):
        """GDScript function: _update_health_ui() -> void"""
        pass

    def gd_func__build_stealth_ui(self):
        """GDScript function: _build_stealth_ui() -> void"""
        pass

    def gd_func__set_stealth_prompt(self):
        """GDScript function: _set_stealth_prompt(text: String) -> void"""
        pass

    def gd_func__toggle_inventory(self):
        """GDScript function: _toggle_inventory() -> void"""
        pass

    def gd_func__update_mouse_mode(self):
        """GDScript function: _update_mouse_mode() -> void"""
        pass

    def uses_game_event_inventory_changed(self):
        """Uses GameEvents.inventory_changed."""
        pass

    def uses_game_event_player_died(self):
        """Uses GameEvents.player_died."""
        pass

    def uses_game_event_inventory_open_changed(self):
        """Uses GameEvents.inventory_open_changed."""
        pass

    def depends_on_SceneAttackHitbox(self):
        """Relationship: loads resource."""
        return SceneAttackHitbox

    def depends_on_ArrowProjectile(self):
        """Relationship: loads resource."""
        return ArrowProjectile

    def depends_on_BallisticsService(self):
        """Relationship: references class BallisticsService."""
        return BallisticsService

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_CombatTargetingService(self):
        """Relationship: references class CombatTargetingService."""
        return CombatTargetingService

    def depends_on_DropPickupRulesService(self):
        """Relationship: references class DropPickupRulesService."""
        return DropPickupRulesService

    def depends_on_PlayerCameraController(self):
        """Relationship: references class PlayerCameraController."""
        return PlayerCameraController

    def depends_on_PlayerEquipmentBuildsComponent(self):
        """Relationship: references class PlayerEquipmentBuildsComponent."""
        return PlayerEquipmentBuildsComponent

    def depends_on_PlayerEquipmentComponent(self):
        """Relationship: references class PlayerEquipmentComponent."""
        return PlayerEquipmentComponent

    def depends_on_PlayerInventoryComponent(self):
        """Relationship: references class PlayerInventoryComponent."""
        return PlayerInventoryComponent

    def depends_on_PlayerInventoryUI(self):
        """Relationship: references class PlayerInventoryUI."""
        return PlayerInventoryUI

    def depends_on_PlayerStatsComponent(self):
        """Relationship: references class PlayerStatsComponent."""
        return PlayerStatsComponent

    def depends_on_ModularSkeletonRig(self):
        """Relationship: references class ModularSkeletonRig."""
        return ModularSkeletonRig

    def depends_on_ProceduralPlayerAnimator(self):
        """Relationship: references class ProceduralPlayerAnimator."""
        return ProceduralPlayerAnimator

class PlayerCameraController:
    """Godot script: scripts/player_camera_controller.gd
    class_name: PlayerCameraController
    extends: Node3D
    system: Camera and controls
    """
    source_file = 'scripts/player_camera_controller.gd'
    godot_class_name = 'PlayerCameraController'
    godot_extends = 'Node3D'
    gameplay_system = 'Camera and controls'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__physics_process(self):
        """GDScript function: _physics_process(delta: float) -> void"""
        pass

    def gd_func__process(self):
        """GDScript function: _process(delta: float) -> void"""
        pass

    def gd_func__unhandled_input(self):
        """GDScript function: _unhandled_input(event: InputEvent) -> void"""
        pass

    def gd_func_capture_mouse(self):
        """GDScript function: capture_mouse() -> void"""
        pass

    def gd_func_release_mouse(self):
        """GDScript function: release_mouse() -> void"""
        pass

    def gd_func_set_look_enabled(self):
        """GDScript function: set_look_enabled(enabled: bool) -> void"""
        pass

    def gd_func_set_aim_zoom(self):
        """GDScript function: set_aim_zoom(enabled: bool, zoom_distance: float = 2.6) -> void"""
        pass

    def gd_func_set_animation_follow_offset(self):
        """GDScript function: set_animation_follow_offset(offset: Vector3) -> void"""
        pass

    def gd_func_get_flat_forward(self):
        """GDScript function: get_flat_forward() -> Vector3"""
        pass

    def gd_func_get_flat_right(self):
        """GDScript function: get_flat_right() -> Vector3"""
        pass

    def gd_func_get_center_aim_point(self):
        """GDScript function: get_center_aim_point(max_distance: float = 90.0, exclude: Array[RID] = []) -> Vector3"""
        pass

    def gd_func__apply_mouse_motion(self):
        """GDScript function: _apply_mouse_motion(relative: Vector2) -> void"""
        pass

    def gd_func__zoom(self):
        """GDScript function: _zoom(amount: float) -> void"""
        pass

    def gd_func__target_pivot_position(self):
        """GDScript function: _target_pivot_position() -> Vector3"""
        pass

    def gd_func__apply_orbit_rotation(self):
        """GDScript function: _apply_orbit_rotation() -> void"""
        pass

class PlayerEquipmentBuildsComponent:
    """Godot script: scripts/player_equipment_builds_component.gd
    class_name: PlayerEquipmentBuildsComponent
    extends: Node
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/player_equipment_builds_component.gd'
    godot_class_name = 'PlayerEquipmentBuildsComponent'
    godot_extends = 'Node'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_setup(self):
        """GDScript function: setup(player: Node, equipment: PlayerEquipmentComponent) -> void"""
        pass

    def gd_func_save_current_build(self):
        """GDScript function: save_current_build(index: int) -> Dictionary"""
        pass

    def gd_func_apply_build(self):
        """GDScript function: apply_build(index: int) -> Dictionary"""
        pass

    def gd_func_validate_build_state(self):
        """GDScript function: validate_build_state(raw_state: Dictionary, inventory_items: Array) -> Dictionary"""
        pass

    def gd_func_get_build_summaries(self):
        """GDScript function: get_build_summaries() -> Array"""
        pass

    def gd_func__apply_validated_state(self):
        """GDScript function: _apply_validated_state(target_state: Dictionary) -> void"""
        pass

    def gd_func__matches_equipment_state(self):
        """GDScript function: _matches_equipment_state(target_state: Dictionary) -> bool"""
        pass

    def gd_func__sanitize_build_state(self):
        """GDScript function: _sanitize_build_state(raw_state: Dictionary) -> Dictionary"""
        pass

    def gd_func__bone_counts(self):
        """GDScript function: _bone_counts(items: Array) -> Dictionary"""
        pass

    def gd_func__inventory_items(self):
        """GDScript function: _inventory_items() -> Array"""
        pass

    def gd_func__load_builds(self):
        """GDScript function: _load_builds() -> void"""
        pass

    def gd_func__save_builds(self):
        """GDScript function: _save_builds() -> void"""
        pass

    def gd_func__summary_for_state(self):
        """GDScript function: _summary_for_state(state: Dictionary) -> String"""
        pass

    def gd_func__valid_index(self):
        """GDScript function: _valid_index(index: int) -> bool"""
        pass

    def gd_func__result(self):
        """GDScript function: _result(ok: bool, message: String, state: Dictionary = {}) -> Dictionary"""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

    def depends_on_PlayerEquipmentComponent(self):
        """Relationship: references class PlayerEquipmentComponent."""
        return PlayerEquipmentComponent

class PlayerEquipmentComponent:
    """Godot script: scripts/player_equipment_component.gd
    class_name: PlayerEquipmentComponent
    extends: Node
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/player_equipment_component.gd'
    godot_class_name = 'PlayerEquipmentComponent'
    godot_extends = 'Node'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_setup(self):
        """GDScript function: setup(player: Node) -> void"""
        pass

    def gd_func_equip_starting_core(self):
        """GDScript function: equip_starting_core() -> void"""
        pass

    def gd_func_equip_bone(self):
        """GDScript function: equip_bone(bone_id: String, target_slot: String = "") -> void"""
        pass

    def gd_func_restore_detached_body(self):
        """GDScript function: restore_detached_body(bone_id: String) -> void"""
        pass

    def gd_func_unequip_slot(self):
        """GDScript function: unequip_slot(slot: String) -> void"""
        pass

    def gd_func_get_equipped_bone_id(self):
        """GDScript function: get_equipped_bone_id() -> String"""
        pass

    def gd_func_get_equipped_bone_for_slot(self):
        """GDScript function: get_equipped_bone_for_slot(slot: String) -> String"""
        pass

    def gd_func_has_bone_equipped(self):
        """GDScript function: has_bone_equipped(bone_id: String) -> bool"""
        pass

    def gd_func_get_equipment_state(self):
        """GDScript function: get_equipment_state() -> Dictionary"""
        pass

    def gd_func_get_swap_count(self):
        """GDScript function: get_swap_count() -> int"""
        pass

    def gd_func__equip_bone_in_slot(self):
        """GDScript function: _equip_bone_in_slot(bone_id: String, force_core: bool = false, target_slot: String = "") -> bool"""
        pass

    def gd_func__slot_for_request(self):
        """GDScript function: _slot_for_request(bone_id: String, target_slot: String = "") -> String"""
        pass

    def gd_func__first_open_compatible_slot(self):
        """GDScript function: _first_open_compatible_slot(bone_id: String) -> String"""
        pass

    def gd_func__can_equip_slot(self):
        """GDScript function: _can_equip_slot(slot: String, bone_id: String) -> bool"""
        pass

    def gd_func__emit_equipment_hint(self):
        """GDScript function: _emit_equipment_hint(hint_id: String, text: String) -> void"""
        pass

    def gd_func__clear_equipped_visual(self):
        """GDScript function: _clear_equipped_visual(slot: String) -> void"""
        pass

    def gd_func__get_socket_for_slot(self):
        """GDScript function: _get_socket_for_slot(slot: String) -> Node3D"""
        pass

    def gd_func__get_player_rig(self):
        """GDScript function: _get_player_rig() -> ModularSkeletonRig"""
        pass

    def gd_func__recalculate_owner_stats(self):
        """GDScript function: _recalculate_owner_stats() -> void"""
        pass

    def gd_func__notify_equipment_changed(self):
        """GDScript function: _notify_equipment_changed() -> void"""
        pass

    def gd_func__get_inventory_items(self):
        """GDScript function: _get_inventory_items() -> Array"""
        pass

    def gd_func__get_run_stats(self):
        """GDScript function: _get_run_stats() -> Dictionary"""
        pass

    def gd_func__definition_for_slot(self):
        """GDScript function: _definition_for_slot(bone_id: String, slot: String) -> Dictionary"""
        pass

    def gd_func__tint_visual(self):
        """GDScript function: _tint_visual(visual: Node3D, color: Color) -> void"""
        pass

    def gd_func__tint_visual_mesh(self):
        """GDScript function: _tint_visual_mesh(visual: Node3D, mesh_name: String, color: Color) -> void"""
        pass

    def uses_game_event_bone_equipped(self):
        """Uses GameEvents.bone_equipped."""
        pass

    def uses_game_event_bone_unequipped(self):
        """Uses GameEvents.bone_unequipped."""
        pass

    def uses_game_event_tutorial_hint_requested(self):
        """Uses GameEvents.tutorial_hint_requested."""
        pass

    def uses_game_event_inventory_changed(self):
        """Uses GameEvents.inventory_changed."""
        pass

    def depends_on_SceneEquippedBone(self):
        """Relationship: loads resource."""
        return SceneEquippedBone

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

    def depends_on_ModularSkeletonRig(self):
        """Relationship: references class ModularSkeletonRig."""
        return ModularSkeletonRig

class PlayerInventoryComponent:
    """Godot script: scripts/player_inventory_component.gd
    class_name: PlayerInventoryComponent
    extends: Node
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/player_inventory_component.gd'
    godot_class_name = 'PlayerInventoryComponent'
    godot_extends = 'Node'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_setup(self):
        """GDScript function: setup(player: Node, equipment: PlayerEquipmentComponent = null) -> void"""
        pass

    def gd_func_collect_bone(self):
        """GDScript function: collect_bone(bone_id: String) -> void"""
        pass

    def gd_func_equip_next_bone(self):
        """GDScript function: equip_next_bone() -> void"""
        pass

    def gd_func_get_run_stats(self):
        """GDScript function: get_run_stats() -> Dictionary"""
        pass

    def gd_func_get_inventory_items(self):
        """GDScript function: get_inventory_items() -> Array"""
        pass

    def gd_func__get_equipment_swap_count(self):
        """GDScript function: _get_equipment_swap_count() -> int"""
        pass

    def gd_func__notify_inventory_changed(self):
        """GDScript function: _notify_inventory_changed() -> void"""
        pass

    def uses_game_event_bone_collected(self):
        """Uses GameEvents.bone_collected."""
        pass

    def uses_game_event_inventory_changed(self):
        """Uses GameEvents.inventory_changed."""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_PlayerEquipmentComponent(self):
        """Relationship: references class PlayerEquipmentComponent."""
        return PlayerEquipmentComponent

class PlayerInventoryUI:
    """Godot script: scripts/player_inventory_ui.gd
    class_name: PlayerInventoryUI
    extends: Node
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/player_inventory_ui.gd'
    godot_class_name = 'PlayerInventoryUI'
    godot_extends = 'Node'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_setup(self):
        """GDScript function: setup(owner_player: Node) -> void"""
        pass

    def gd_func_handle_input(self):
        """GDScript function: handle_input(event: InputEvent) -> void"""
        pass

    def gd_func_set_open(self):
        """GDScript function: set_open(open: bool) -> void"""
        pass

    def gd_func_cycle_category(self):
        """GDScript function: cycle_category() -> void"""
        pass

    def gd_func_notify_inventory_changed(self):
        """GDScript function: notify_inventory_changed() -> void"""
        pass

    def gd_func_notify_equipment_changed(self):
        """GDScript function: notify_equipment_changed() -> void"""
        pass

    def gd_func__on_inventory_changed(self):
        """GDScript function: _on_inventory_changed(event_player: Node, _items: Array, _stats: Dictionary) -> void"""
        pass

    def gd_func__on_bone_equipped(self):
        """GDScript function: _on_bone_equipped(_bone_id: String, _slot: String, event_player: Node) -> void"""
        pass

    def gd_func__on_bone_unequipped(self):
        """GDScript function: _on_bone_unequipped(_bone_id: String, _slot: String, event_player: Node) -> void"""
        pass

    def gd_func_get_inventory_tile_size(self):
        """GDScript function: get_inventory_tile_size() -> Vector2"""
        pass

    def gd_func_has_bone_equipped(self):
        """GDScript function: has_bone_equipped(bone_id: String) -> bool"""
        pass

    def gd_func_equip_bone(self):
        """GDScript function: equip_bone(bone_id: String) -> void"""
        pass

    def gd_func_equip_bone_in_slot(self):
        """GDScript function: equip_bone_in_slot(bone_id: String, slot: String) -> void"""
        pass

    def gd_func_unequip_slot(self):
        """GDScript function: unequip_slot(slot: String) -> void"""
        pass

    def gd_func_get_equipped_bone_for_slot(self):
        """GDScript function: get_equipped_bone_for_slot(slot: String) -> String"""
        pass

    def gd_func_select_bone(self):
        """GDScript function: select_bone(bone_id: String) -> void"""
        pass

    def gd_func__refresh_selection_visuals(self):
        """GDScript function: _refresh_selection_visuals() -> void"""
        pass

    def gd_func_begin_bone_drag(self):
        """GDScript function: begin_bone_drag(bone_id: String) -> void"""
        pass

    def gd_func_end_bone_drag(self):
        """GDScript function: end_bone_drag() -> void"""
        pass

    def gd_func__slot_list_text(self):
        """GDScript function: _slot_list_text(slots: Array[String]) -> String"""
        pass

    def gd_func_show_bone_info(self):
        """GDScript function: show_bone_info(bone_id: String) -> void"""
        pass

    def gd_func__bone_comparison_text(self):
        """GDScript function: _bone_comparison_text(bone_id: String) -> String"""
        pass

    def gd_func_clear_bone_info(self):
        """GDScript function: clear_bone_info() -> void"""
        pass

    def gd_func__build_inventory_ui(self):
        """GDScript function: _build_inventory_ui() -> void"""
        pass

    def gd_func__build_right_inventory_panel(self):
        """GDScript function: _build_right_inventory_panel() -> void"""
        pass

    def gd_func__build_inventory_blur_layer(self):
        """GDScript function: _build_inventory_blur_layer() -> ColorRect"""
        pass

    def gd_func__build_inventory_tabs(self):
        """GDScript function: _build_inventory_tabs(parent: VBoxContainer) -> void"""
        pass

    def gd_func__on_inventory_filter_selected(self):
        """GDScript function: _on_inventory_filter_selected(index: int) -> void"""
        pass

    def gd_func__add_inventory_tab(self):
        """GDScript function: _add_inventory_tab(parent: HBoxContainer, category: String, text: String) -> void"""
        pass

    def gd_func__select_inventory_category(self):
        """GDScript function: _select_inventory_category(category: String) -> void"""
        pass

    def gd_func__refresh_inventory_tabs(self):
        """GDScript function: _refresh_inventory_tabs() -> void"""
        pass

    def gd_func__refresh_inventory_mode(self):
        """GDScript function: _refresh_inventory_mode() -> void"""
        pass

    def gd_func__queue_inventory_responsive_layout(self):
        """GDScript function: _queue_inventory_responsive_layout() -> void"""
        pass

    def gd_func__apply_inventory_responsive_layout(self):
        """GDScript function: _apply_inventory_responsive_layout() -> void"""
        pass

    def gd_func__apply_builds_responsive_layout(self):
        """GDScript function: _apply_builds_responsive_layout(content_width: int, content_height: int, compact: bool, very_compact: bool) -> void"""
        pass

    def gd_func__apply_settings_responsive_layout(self):
        """GDScript function: _apply_settings_responsive_layout(content_width: int, content_height: int, compact: bool, very_compact: bool) -> void"""
        pass

    def gd_func__apply_paper_doll_responsive_layout(self):
        """GDScript function: _apply_paper_doll_responsive_layout(doll_scale: float) -> void"""
        pass

    def gd_func__apply_footer_responsive_layout(self):
        """GDScript function: _apply_footer_responsive_layout(content_width: int, very_compact: bool) -> void"""
        pass

    def gd_func__set_margin(self):
        """GDScript function: _set_margin(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void"""
        pass

    def gd_func__build_settings_panel(self):
        """GDScript function: _build_settings_panel() -> ScrollContainer"""
        pass

    def gd_func__build_equipment_builds_tab(self):
        """GDScript function: _build_equipment_builds_tab() -> ScrollContainer"""
        pass

    def gd_func__build_equipment_build_card(self):
        """GDScript function: _build_equipment_build_card(index: int) -> Control"""
        pass

    def gd_func__build_build_preview(self):
        """GDScript function: _build_build_preview(index: int) -> Control"""
        pass

    def gd_func__sync_all_build_previews(self):
        """GDScript function: _sync_all_build_previews() -> void"""
        pass

    def gd_func__sync_build_preview(self):
        """GDScript function: _sync_build_preview(index: int) -> void"""
        pass

    def gd_func__equip_bone_on_rig(self):
        """GDScript function: _equip_bone_on_rig(rig: ModularSkeletonRig, slot_id: String, bone_id: String) -> void"""
        pass

    def gd_func__raw_build_state(self):
        """GDScript function: _raw_build_state(index: int) -> Dictionary"""
        pass

    def gd_func__make_build_preset_button(self):
        """GDScript function: _make_build_preset_button(text: String) -> Button"""
        pass

    def gd_func__save_equipment_build(self):
        """GDScript function: _save_equipment_build(index: int) -> void"""
        pass

    def gd_func__apply_equipment_build(self):
        """GDScript function: _apply_equipment_build(index: int) -> void"""
        pass

    def gd_func__build_slot_is_empty(self):
        """GDScript function: _build_slot_is_empty(index: int) -> bool"""
        pass

    def gd_func__consume_or_arm_confirmation(self):
        """GDScript function: _consume_or_arm_confirmation(action: String, index: int, button_text: String) -> bool"""
        pass

    def gd_func__on_build_preset_confirm_timeout(self):
        """GDScript function: _on_build_preset_confirm_timeout(expected_key: String) -> void"""
        pass

    def gd_func__disarm_build_preset_confirmation(self):
        """GDScript function: _disarm_build_preset_confirmation() -> void"""
        pass

    def gd_func__refresh_build_preset_rows(self):
        """GDScript function: _refresh_build_preset_rows() -> void"""
        pass

    def gd_func__set_build_preset_status(self):
        """GDScript function: _set_build_preset_status(text: String) -> void"""
        pass

    def gd_func__build_control_binding_row(self):
        """GDScript function: _build_control_binding_row(action: String, label_text: String) -> Control"""
        pass

    def gd_func__add_footer_hint(self):
        """GDScript function: _add_footer_hint(parent: HBoxContainer, key_text: String, action_text: String) -> void"""
        pass

    def gd_func__make_rule(self):
        """GDScript function: _make_rule() -> ColorRect"""
        pass

    def gd_func__make_inventory_style(self):
        """GDScript function: _make_inventory_style(bg: Color, border: Color, border_width: int = 1, radius: int = 0) -> StyleBoxFlat"""
        pass

    def gd_func__make_empty_inventory_slot(self):
        """GDScript function: _make_empty_inventory_slot() -> Control"""
        pass

    def gd_func__build_character_preview_panel(self):
        """GDScript function: _build_character_preview_panel() -> Control"""
        pass

    def gd_func__inventory_preview_base_size(self):
        """GDScript function: _inventory_preview_base_size() -> Vector2"""
        pass

    def gd_func__build_preview_room(self):
        """GDScript function: _build_preview_room(parent: Node3D) -> void"""
        pass

    def gd_func__make_preview_room_box(self):
        """GDScript function: _make_preview_room_box(name: String, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D"""
        pass

    def gd_func_sync_preview(self):
        """GDScript function: sync_preview() -> void"""
        pass

    def gd_func__preview_equipment_snapshot(self):
        """GDScript function: _preview_equipment_snapshot() -> Dictionary"""
        pass

    def gd_func__preview_snapshot_matches(self):
        """GDScript function: _preview_snapshot_matches(next_snapshot: Dictionary) -> bool"""
        pass

    def gd_func__build_paper_doll(self):
        """GDScript function: _build_paper_doll() -> Control"""
        pass

    def gd_func__paper_doll_slot_size(self):
        """GDScript function: _paper_doll_slot_size(slot_id: String) -> Vector2"""
        pass

    def gd_func__place_slot(self):
        """GDScript function: _place_slot(doll: Control, slot: String, short_name: String, pos: Vector2, slot_size: Vector2) -> void"""
        pass

    def gd_func__begin_rebinding(self):
        """GDScript function: _begin_rebinding(action: String, button: Button) -> void"""
        pass

    def gd_func__cancel_rebinding(self):
        """GDScript function: _cancel_rebinding() -> void"""
        pass

    def gd_func__apply_control_binding(self):
        """GDScript function: _apply_control_binding(action: String, raw_event: InputEvent) -> void"""
        pass

    def gd_func__is_bindable_control_event(self):
        """GDScript function: _is_bindable_control_event(event: InputEvent) -> bool"""
        pass

    def gd_func__clean_control_event(self):
        """GDScript function: _clean_control_event(raw_event: InputEvent) -> InputEvent"""
        pass

    def gd_func__remove_control_event_from_other_actions(self):
        """GDScript function: _remove_control_event_from_other_actions(target_action: String, event: InputEvent) -> void"""
        pass

    def gd_func__control_events_match(self):
        """GDScript function: _control_events_match(a: InputEvent, b: InputEvent) -> bool"""
        pass

    def gd_func__find_control_event_owner(self):
        """GDScript function: _find_control_event_owner(event: InputEvent, target_action: String) -> String"""
        pass

    def gd_func__refresh_control_buttons(self):
        """GDScript function: _refresh_control_buttons() -> void"""
        pass

    def gd_func__binding_text(self):
        """GDScript function: _binding_text(action: String) -> String"""
        pass

    def gd_func__event_text(self):
        """GDScript function: _event_text(event: InputEvent) -> String"""
        pass

    def gd_func__control_label(self):
        """GDScript function: _control_label(action: String) -> String"""
        pass

    def gd_func__save_control_settings(self):
        """GDScript function: _save_control_settings() -> void"""
        pass

    def gd_func__load_control_settings(self):
        """GDScript function: _load_control_settings() -> void"""
        pass

    def gd_func__event_from_config(self):
        """GDScript function: _event_from_config(config: ConfigFile, action: String) -> InputEvent"""
        pass

    def gd_func__control_event_is_usable(self):
        """GDScript function: _control_event_is_usable(event: InputEvent) -> bool"""
        pass

    def gd_func__ensure_required_control_bindings(self):
        """GDScript function: _ensure_required_control_bindings() -> void"""
        pass

    def gd_func__ensure_default_control_key(self):
        """GDScript function: _ensure_default_control_key(action: String, keycode: int) -> void"""
        pass

    def gd_func__ensure_default_control_mouse(self):
        """GDScript function: _ensure_default_control_mouse(action: String, button_index: int) -> void"""
        pass

    def gd_func__action_has_usable_event(self):
        """GDScript function: _action_has_usable_event(action: String) -> bool"""
        pass

    def gd_func__reset_control_defaults(self):
        """GDScript function: _reset_control_defaults() -> void"""
        pass

    def gd_func__set_default_control_key(self):
        """GDScript function: _set_default_control_key(action: String, keycode: int) -> void"""
        pass

    def gd_func__set_default_control_mouse(self):
        """GDScript function: _set_default_control_mouse(action: String, button_index: int) -> void"""
        pass

    def gd_func_rebuild_item_tiles(self):
        """GDScript function: rebuild_item_tiles() -> void"""
        pass

    def gd_func__bone_matches_inventory_category(self):
        """GDScript function: _bone_matches_inventory_category(bone_id: String) -> bool"""
        pass

    def gd_func__compare_inventory_items(self):
        """GDScript function: _compare_inventory_items(a: String, b: String) -> bool"""
        pass

    def gd_func_update_inventory_ui(self):
        """GDScript function: update_inventory_ui() -> void"""
        pass

    def gd_func__bone_inventory(self):
        """GDScript function: _bone_inventory() -> Array"""
        pass

    def gd_func__equipment_state(self):
        """GDScript function: _equipment_state() -> Dictionary"""
        pass

    def gd_func__equipped_bone_counts(self):
        """GDScript function: _equipped_bone_counts() -> Dictionary"""
        pass

    def gd_func__inventory_stats_snapshot(self):
        """GDScript function: _inventory_stats_snapshot() -> Dictionary"""
        pass

    def uses_game_event_inventory_changed(self):
        """Uses GameEvents.inventory_changed."""
        pass

    def uses_game_event_bone_equipped(self):
        """Uses GameEvents.bone_equipped."""
        pass

    def uses_game_event_bone_unequipped(self):
        """Uses GameEvents.bone_unequipped."""
        pass

    def depends_on_InventoryEmptySlot(self):
        """Relationship: loads resource."""
        return InventoryEmptySlot

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

    def depends_on_PlayerEquipmentBuildsComponent(self):
        """Relationship: references class PlayerEquipmentBuildsComponent."""
        return PlayerEquipmentBuildsComponent

    def depends_on_ModularSkeletonRig(self):
        """Relationship: references class ModularSkeletonRig."""
        return ModularSkeletonRig

    def depends_on_BoneItemTile(self):
        """Relationship: references class BoneItemTile."""
        return BoneItemTile

    def depends_on_BoneSlotWidget(self):
        """Relationship: references class BoneSlotWidget."""
        return BoneSlotWidget

    def depends_on_InventoryEmptySlot2(self):
        """Relationship: references class InventoryEmptySlot."""
        return InventoryEmptySlot

class PlayerStatsComponent:
    """Godot script: scripts/player_stats_component.gd
    class_name: PlayerStatsComponent
    extends: Node
    system: Supporting gameplay
    """
    source_file = 'scripts/player_stats_component.gd'
    godot_class_name = 'PlayerStatsComponent'
    godot_extends = 'Node'
    gameplay_system = 'Supporting gameplay'

    def gd_func_setup(self):
        """GDScript function: setup(initial_move_speed: float, initial_attack_range: float, initial_attack_damage: int, initial_max_health: int) -> void"""
        pass

    def gd_func_calculate(self):
        """GDScript function: calculate(equipment_state: Dictionary, current_health: int, current_max_health: int) -> Dictionary"""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

class ModularSkeletonRig:
    """Godot script: scripts/rig/modular_skeleton_rig.gd
    class_name: ModularSkeletonRig
    extends: Node3D
    system: Rig and animation
    """
    source_file = 'scripts/rig/modular_skeleton_rig.gd'
    godot_class_name = 'ModularSkeletonRig'
    godot_extends = 'Node3D'
    gameplay_system = 'Rig and animation'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func_apply_gorilla_proportions(self):
        """GDScript function: apply_gorilla_proportions() -> void"""
        pass

    def gd_func_apply_lizard_proportions(self):
        """GDScript function: apply_lizard_proportions() -> void"""
        pass

    def gd_func__ensure_lizard_torso_block(self):
        """GDScript function: _ensure_lizard_torso_block(block_name: String, size: Vector3, local_position: Vector3) -> void"""
        pass

    def gd_func__set_socket_position(self):
        """GDScript function: _set_socket_position(socket_key: String, new_position: Vector3) -> void"""
        pass

    def gd_func__set_base_limb_shape(self):
        """GDScript function: _set_base_limb_shape(limb_key: String, new_size: Vector3, new_offset: Vector3) -> void"""
        pass

    def gd_func__apply_gorilla_body_hitboxes(self):
        """GDScript function: _apply_gorilla_body_hitboxes() -> void"""
        pass

    def gd_func__apply_skeleton_model(self):
        """GDScript function: _apply_skeleton_model() -> void"""
        pass

    def gd_func__apply_rigged_limbs(self):
        """GDScript function: _apply_rigged_limbs() -> void"""
        pass

    def gd_func__find_skeleton(self):
        """GDScript function: _find_skeleton(n: Node) -> Skeleton3D"""
        pass

    def gd_func__hang_basis(self):
        """GDScript function: _hang_basis(l: Vector3) -> Basis"""
        pass

    def gd_func__top_ancestor_under(self):
        """GDScript function: _top_ancestor_under(node: Node, ancestor: Node) -> Node"""
        pass

    def gd_func_get_socket(self):
        """GDScript function: get_socket(socket_key: String) -> Node3D"""
        pass

    def gd_func_set_body_progression_enabled(self):
        """GDScript function: set_body_progression_enabled(enabled: bool) -> void"""
        pass

    def gd_func_set_body_hitbox_owner(self):
        """GDScript function: set_body_hitbox_owner(owner_body: Node, damage_group: String = PLAYER_BODY_HITBOX_GROUP) -> void"""
        pass

    def gd_func_has_body_part_hitboxes(self):
        """GDScript function: has_body_part_hitboxes() -> bool"""
        pass

    def gd_func_set_body_part_hitbox_enabled(self):
        """GDScript function: set_body_part_hitbox_enabled(socket_key: String, enabled: bool) -> void"""
        pass

    def gd_func_set_head_only_visual_guard(self):
        """GDScript function: set_head_only_visual_guard(enabled: bool) -> void"""
        pass

    def gd_func__set_mesh_visibility_recursive(self):
        """GDScript function: _set_mesh_visibility_recursive(root: Node, is_visible: bool) -> void"""
        pass

    def gd_func_has_equipped_slot(self):
        """GDScript function: has_equipped_slot(slot_id: String) -> bool"""
        pass

    def gd_func__make_limb(self):
        """GDScript function: _make_limb(socket_key: String, color: Color, extra_scale: Vector3) -> MeshInstance3D"""
        pass

    def gd_func__get_head_model_mesh(self):
        """GDScript function: _get_head_model_mesh() -> Mesh"""
        pass

    def gd_func_equip_bone(self):
        """GDScript function: equip_bone(bone_id: String, bone_def: Dictionary) -> void"""
        pass

    def gd_func_unequip_slot(self):
        """GDScript function: unequip_slot(slot_id: String) -> void"""
        pass

    def gd_func_get_equipped_bone_defs(self):
        """GDScript function: get_equipped_bone_defs() -> Array"""
        pass

    def gd_func__refresh_body_progression_visibility(self):
        """GDScript function: _refresh_body_progression_visibility() -> void"""
        pass

    def gd_func__base_socket_should_show(self):
        """GDScript function: _base_socket_should_show(socket_key: String) -> bool"""
        pass

    def gd_func__socket_is_equipped(self):
        """GDScript function: _socket_is_equipped(socket_key: String) -> bool"""
        pass

    def gd_func__ensure_body_hitboxes(self):
        """GDScript function: _ensure_body_hitboxes() -> void"""
        pass

    def gd_func__make_body_hitbox(self):
        """GDScript function: _make_body_hitbox(socket_key: String) -> void"""
        pass

    def gd_func__body_hitbox_name(self):
        """GDScript function: _body_hitbox_name(socket_key: String) -> String"""
        pass

    def gd_func__configure_body_hitbox_owner(self):
        """GDScript function: _configure_body_hitbox_owner(socket_key: String) -> void"""
        pass

    def gd_func__apply_default_body_hitbox(self):
        """GDScript function: _apply_default_body_hitbox(socket_key: String) -> void"""
        pass

    def gd_func__apply_equipped_body_hitbox(self):
        """GDScript function: _apply_equipped_body_hitbox(socket_key: String, explicit_size: Vector3, scale_value: Vector3, extra_offset: Vector3, rotation_value: Vector3) -> void"""
        pass

    def gd_func__apply_body_hitbox(self):
        """GDScript function: _apply_body_hitbox(socket_key: String, size_value: Vector3, offset_value: Vector3, rotation_value: Vector3) -> void"""
        pass

    def gd_func__apply_body_hitbox_shape(self):
        """GDScript function: _apply_body_hitbox_shape(socket_key: String, size_value: Vector3, offset_value: Vector3, rotation_value: Vector3) -> void"""
        pass

    def gd_func__refresh_body_hitbox_shapes(self):
        """GDScript function: _refresh_body_hitbox_shapes() -> void"""
        pass

    def gd_func__enemy_adjusted_hitbox_size(self):
        """GDScript function: _enemy_adjusted_hitbox_size(socket_key: String, size_value: Vector3) -> Vector3"""
        pass

    def gd_func__refresh_body_hitbox_enabled(self):
        """GDScript function: _refresh_body_hitbox_enabled() -> void"""
        pass

    def gd_func__body_hitbox_should_be_enabled(self):
        """GDScript function: _body_hitbox_should_be_enabled(socket_key: String) -> bool"""
        pass

    def gd_func__clear_damage_hitbox_groups(self):
        """GDScript function: _clear_damage_hitbox_groups(area: Area3D) -> void"""
        pass

    def gd_func__build_socket_markers(self):
        """GDScript function: _build_socket_markers() -> void"""
        pass

    def gd_func__make_socket_marker(self):
        """GDScript function: _make_socket_marker(socket_key: String) -> MeshInstance3D"""
        pass

    def gd_func_get_waist_joint(self):
        """GDScript function: get_waist_joint() -> Node3D"""
        pass

    def gd_func_get_socket_attach(self):
        """GDScript function: get_socket_attach(socket_key: String) -> Node3D"""
        pass

    def gd_func__build_waist_joint(self):
        """GDScript function: _build_waist_joint() -> void"""
        pass

    def gd_func__socket_layout_for(self):
        """GDScript function: _socket_layout_for(socket_key: String) -> Vector3"""
        pass

    def gd_func__limb_geo_for(self):
        """GDScript function: _limb_geo_for(socket_key: String) -> Dictionary"""
        pass

    def gd_func__split_limbs_active(self):
        """GDScript function: _split_limbs_active() -> bool"""
        pass

    def gd_func__foot_parent_key(self):
        """GDScript function: _foot_parent_key(leg_key: String) -> String"""
        pass

    def gd_func_limb_socket_group(self):
        """GDScript function: limb_socket_group(key: String) -> Array[String]"""
        pass

    def gd_func_get_limb_meshes(self):
        """GDScript function: get_limb_meshes(key: String) -> Array[MeshInstance3D]"""
        pass

    def gd_func__as_vector3(self):
        """GDScript function: _as_vector3(value: Variant, fallback: Vector3) -> Vector3"""
        pass

    def gd_func__scale_vector3(self):
        """GDScript function: _scale_vector3(size_value: Vector3, scale_value: Vector3) -> Vector3"""
        pass

    def gd_func__positive_vector3(self):
        """GDScript function: _positive_vector3(value: Vector3, fallback: Vector3) -> Vector3"""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

    def depends_on_PlayerEquipmentComponent(self):
        """Relationship: references class PlayerEquipmentComponent."""
        return PlayerEquipmentComponent

class ProceduralEnemyAnimator:
    """Godot script: scripts/rig/procedural_enemy_animator.gd
    class_name: ProceduralEnemyAnimator
    extends: ProceduralPlayerAnimator
    system: Combat and enemies
    """
    source_file = 'scripts/rig/procedural_enemy_animator.gd'
    godot_class_name = 'ProceduralEnemyAnimator'
    godot_extends = 'ProceduralPlayerAnimator'
    gameplay_system = 'Combat and enemies'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def depends_on_ProceduralPlayerAnimator(self):
        """Relationship: references class ProceduralPlayerAnimator."""
        return ProceduralPlayerAnimator

class ProceduralPlayerAnimator:
    """Godot script: scripts/rig/procedural_player_animator.gd
    class_name: ProceduralPlayerAnimator
    extends: Node3D
    system: Rig and animation
    """
    source_file = 'scripts/rig/procedural_player_animator.gd'
    godot_class_name = 'ProceduralPlayerAnimator'
    godot_extends = 'Node3D'
    gameplay_system = 'Rig and animation'

    def gd_func_update_from_player(self):
        """GDScript function: update_from_player(delta: float, velocity: Vector3, max_speed: float, facing_direction: Vector3, equipped_defs: Array) -> void"""
        pass

    def gd_func__waist_target_angle(self):
        """GDScript function: _waist_target_angle() -> float"""
        pass

    def gd_func__animate_waist(self):
        """GDScript function: _animate_waist(delta: float) -> void"""
        pass

    def gd_func__apply_waist_carry(self):
        """GDScript function: _apply_waist_carry(angle: float) -> void"""
        pass

    def gd_func_trigger_demo_attack_procedural(self):
        """GDScript function: trigger_demo_attack_procedural() -> void"""
        pass

    def gd_func_trigger_demo_attack_tween(self):
        """GDScript function: trigger_demo_attack_tween() -> void"""
        pass

    def gd_func__update_demo_procedural(self):
        """GDScript function: _update_demo_procedural(delta: float) -> void"""
        pass

    def gd_func__apply_demo_pose(self):
        """GDScript function: _apply_demo_pose() -> void"""
        pass

    def gd_func__demo_keyframes(self):
        """GDScript function: _demo_keyframes() -> Dictionary"""
        pass

    def gd_func__demo_charge_time(self):
        """GDScript function: _demo_charge_time() -> float"""
        pass

    def gd_func__demo_air_time(self):
        """GDScript function: _demo_air_time() -> float"""
        pass

    def gd_func__demo_begin(self):
        """GDScript function: _demo_begin() -> Node3D"""
        pass

    def gd_func__demo_local_forward(self):
        """GDScript function: _demo_local_forward() -> Vector3"""
        pass

    def gd_func_set_demo_target_world_position(self):
        """GDScript function: set_demo_target_world_position(world_position: Vector3) -> void"""
        pass

    def gd_func__demo_stop(self):
        """GDScript function: _demo_stop() -> void"""
        pass

    def gd_func__demo_on_tween_finished(self):
        """GDScript function: _demo_on_tween_finished() -> void"""
        pass

    def gd_func__ease_out_sine(self):
        """GDScript function: _ease_out_sine(t: float) -> float"""
        pass

    def gd_func__ease_out_quad(self):
        """GDScript function: _ease_out_quad(t: float) -> float"""
        pass

    def gd_func__ease_in_quad(self):
        """GDScript function: _ease_in_quad(t: float) -> float"""
        pass

    def gd_func__ease_in_out_sine(self):
        """GDScript function: _ease_in_out_sine(t: float) -> float"""
        pass

    def gd_func_is_head_launch_attack_busy(self):
        """GDScript function: is_head_launch_attack_busy() -> bool"""
        pass

    def gd_func_set_head_launch_attack_aim(self):
        """GDScript function: set_head_launch_attack_aim(direction: Vector3, valid: bool) -> void"""
        pass

    def gd_func__head_launch_aim_or(self):
        """GDScript function: _head_launch_aim_or(fallback: Vector3) -> Vector3"""
        pass

    def gd_func__update_head_launch_attack_aim(self):
        """GDScript function: _update_head_launch_attack_aim() -> void"""
        pass

    def gd_func_trigger_attack(self):
        """GDScript function: trigger_attack(combo_step: int = 0, allow_head_launch: bool = true) -> void"""
        pass

    def gd_func_trigger_stealth_finish_attack(self):
        """GDScript function: trigger_stealth_finish_attack() -> void"""
        pass

    def gd_func__capture_torso_head_miss_body_hold_transform(self):
        """GDScript function: _capture_torso_head_miss_body_hold_transform() -> void"""
        pass

    def gd_func_set_aiming(self):
        """GDScript function: set_aiming(enabled: bool) -> void"""
        pass

    def gd_func_confirm_head_only_attack_contact(self):
        """GDScript function: confirm_head_only_attack_contact() -> void"""
        pass

    def gd_func_get_head_only_attack_forward_offset(self):
        """GDScript function: get_head_only_attack_forward_offset() -> float"""
        pass

    def gd_func_get_head_only_attack_world_offset(self):
        """GDScript function: get_head_only_attack_world_offset() -> Vector3"""
        pass

    def gd_func_get_head_launch_attack_world_offset(self):
        """GDScript function: get_head_launch_attack_world_offset() -> Vector3"""
        pass

    def gd_func_has_head_only_body_catch_up_request(self):
        """GDScript function: has_head_only_body_catch_up_request() -> bool"""
        pass

    def gd_func_consume_head_only_body_catch_up_offset(self):
        """GDScript function: consume_head_only_body_catch_up_offset() -> Vector3"""
        pass

    def gd_func_has_torso_head_miss_detach_request(self):
        """GDScript function: has_torso_head_miss_detach_request() -> bool"""
        pass

    def gd_func_consume_torso_head_miss_detach_offset(self):
        """GDScript function: consume_torso_head_miss_detach_offset() -> Vector3"""
        pass

    def gd_func_get_torso_head_miss_detach_body_transform(self):
        """GDScript function: get_torso_head_miss_detach_body_transform() -> Transform3D"""
        pass

    def gd_func_enter_detached_head_state(self):
        """GDScript function: enter_detached_head_state(start_local_position: Vector3 = Vector3.ZERO, use_start_position: bool = false) -> void"""
        pass

    def gd_func_start_detached_head_reattach_tornado(self):
        """GDScript function: start_detached_head_reattach_tornado(body_world_position: Vector3, target_world_position: Vector3, body_world_rotation: Vector3 = Vector3.ZERO) -> void"""
        pass

    def gd_func_set_detached_head_reattach_tornado_progress(self):
        """GDScript function: set_detached_head_reattach_tornado_progress(progress: float, body_world_position: Vector3, target_world_position: Vector3, body_world_rotation: Vector3 = Vector3.ZERO) -> void"""
        pass

    def gd_func_cancel_detached_head_reattach_tornado_to_ground(self):
        """GDScript function: cancel_detached_head_reattach_tornado_to_ground() -> void"""
        pass

    def gd_func_play_detached_head_reattach_finish_blend(self):
        """GDScript function: play_detached_head_reattach_finish_blend() -> void"""
        pass

    def gd_func_get_detached_head_reattach_tornado_duration(self):
        """GDScript function: get_detached_head_reattach_tornado_duration() -> float"""
        pass

    def gd_func_get_stable_body_attach_local_position(self):
        """GDScript function: get_stable_body_attach_local_position() -> Vector3"""
        pass

    def gd_func__update_head_only_facing_direction(self):
        """GDScript function: _update_head_only_facing_direction(facing_direction: Vector3) -> void"""
        pass

    def gd_func__world_horizontal_offset_to_local(self):
        """GDScript function: _world_horizontal_offset_to_local(world_offset: Vector3) -> Vector3"""
        pass

    def gd_func__world_rotation_to_rig_local(self):
        """GDScript function: _world_rotation_to_rig_local(world_rotation: Vector3) -> Vector3"""
        pass

    def gd_func__capture_head_only_recoil_start_local_position(self):
        """GDScript function: _capture_head_only_recoil_start_local_position() -> Vector3"""
        pass

    def gd_func__capture_socket_local_position(self):
        """GDScript function: _capture_socket_local_position(socket_key: String) -> Vector3"""
        pass

    def gd_func__capture_socket_local_rotation(self):
        """GDScript function: _capture_socket_local_rotation(socket_key: String) -> Vector3"""
        pass

    def gd_func__capture_socket_local_scale(self):
        """GDScript function: _capture_socket_local_scale(socket_key: String) -> Vector3"""
        pass

    def gd_func__get_head_only_grounded_local_position(self):
        """GDScript function: _get_head_only_grounded_local_position() -> Vector3"""
        pass

    def gd_func_set_crawl_mode(self):
        """GDScript function: set_crawl_mode(enabled: bool) -> void"""
        pass

    def gd_func_set_lizard_wall_climb_blend(self):
        """GDScript function: set_lizard_wall_climb_blend(blend: float) -> void"""
        pass

    def gd_func_set_player_body_progression_enabled(self):
        """GDScript function: set_player_body_progression_enabled(enabled: bool) -> void"""
        pass

    def gd_func__capture_rest(self):
        """GDScript function: _capture_rest() -> void"""
        pass

    def gd_func__get_rest_pos(self):
        """GDScript function: _get_rest_pos(key: String) -> Vector3"""
        pass

    def gd_func__get_rest_rot(self):
        """GDScript function: _get_rest_rot(key: String) -> Vector3"""
        pass

    def gd_func__calculate_weight(self):
        """GDScript function: _calculate_weight(equipped_defs: Array) -> float"""
        pass

    def gd_func__update_torso_head_socket_offset(self):
        """GDScript function: _update_torso_head_socket_offset(equipped_defs: Array) -> void"""
        pass

    def gd_func__as_vector3(self):
        """GDScript function: _as_vector3(value: Variant, fallback: Vector3) -> Vector3"""
        pass

    def gd_func__animate_body(self):
        """GDScript function: _animate_body() -> void"""
        pass

    def gd_func__is_head_only(self):
        """GDScript function: _is_head_only() -> bool"""
        pass

    def gd_func__head_only_attack_airborne(self):
        """GDScript function: _head_only_attack_airborne() -> bool"""
        pass

    def gd_func__is_torso_spring_only(self):
        """GDScript function: _is_torso_spring_only() -> bool"""
        pass

    def gd_func__is_slot_equipped(self):
        """GDScript function: _is_slot_equipped(slot: String) -> bool"""
        pass

    def gd_func__has_any_arm_equipped(self):
        """GDScript function: _has_any_arm_equipped() -> bool"""
        pass

    def gd_func__torso_head_launch_available(self):
        """GDScript function: _torso_head_launch_available() -> bool"""
        pass

    def gd_func__animate_head_only(self):
        """GDScript function: _animate_head_only(sway: float, breath: float) -> void"""
        pass

    def gd_func__apply_detached_head_reattach_tornado(self):
        """GDScript function: _apply_detached_head_reattach_tornado(head: Node3D) -> void"""
        pass

    def gd_func__apply_detached_head_reattach_finish_blend(self):
        """GDScript function: _apply_detached_head_reattach_finish_blend(_body: Node3D, head: Node3D) -> void"""
        pass

    def gd_func__animate_torso_spring(self):
        """GDScript function: _animate_torso_spring(sway: float, breath: float) -> void"""
        pass

    def gd_func__anchor_socket_to_body(self):
        """GDScript function: _anchor_socket_to_body(key: String, body: Node3D) -> void"""
        pass

    def gd_func__animate_limbs(self):
        """GDScript function: _animate_limbs() -> void"""
        pass

    def gd_func__animate_crawl_body(self):
        """GDScript function: _animate_crawl_body() -> void"""
        pass

    def gd_func__animate_crawl_limbs(self):
        """GDScript function: _animate_crawl_limbs() -> void"""
        pass

    def gd_func__apply_lizard_wall_climb_limb_pose(self):
        """GDScript function: _apply_lizard_wall_climb_limb_pose() -> void"""
        pass

    def gd_func__animate_lizard_torso_blocks(self):
        """GDScript function: _animate_lizard_torso_blocks(sway: float, breath: float, base_pitch: float) -> void"""
        pass

    def gd_func__swing(self):
        """GDScript function: _swing(key: String, angle: float) -> void"""
        pass

    def gd_func__animate_joints(self):
        """GDScript function: _animate_joints() -> void"""
        pass

    def gd_func__joint_phase(self):
        """GDScript function: _joint_phase(key: String) -> float"""
        pass

    def gd_func__animate_wobble(self):
        """GDScript function: _animate_wobble() -> void"""
        pass

    def gd_func__wobble_phase(self):
        """GDScript function: _wobble_phase(key: String) -> float"""
        pass

    def gd_func__update_aim_overlay(self):
        """GDScript function: _update_aim_overlay(delta: float) -> void"""
        pass

    def gd_func__apply_aim_overlay(self):
        """GDScript function: _apply_aim_overlay() -> void"""
        pass

    def gd_func__update_attack_overlay(self):
        """GDScript function: _update_attack_overlay(delta: float) -> void"""
        pass

    def gd_func__apply_attack_overlay(self):
        """GDScript function: _apply_attack_overlay() -> void"""
        pass

    def gd_func__combo_step_for_equipped_arms(self):
        """GDScript function: _combo_step_for_equipped_arms() -> int"""
        pass

    def gd_func__attack_pose_strength(self):
        """GDScript function: _attack_pose_strength() -> float"""
        pass

    def gd_func__attack_strike_curve(self):
        """GDScript function: _attack_strike_curve(phase: float) -> float"""
        pass

    def gd_func__attack_phase(self):
        """GDScript function: _attack_phase() -> float"""
        pass

    def gd_func__apply_head_only_attack_pose(self):
        """GDScript function: _apply_head_only_attack_pose() -> void"""
        pass

    def gd_func__apply_head_only_hit_recoil_pose(self):
        """GDScript function: _apply_head_only_hit_recoil_pose(head: Node3D) -> void"""
        pass

    def gd_func__apply_torso_head_attack_pose(self):
        """GDScript function: _apply_torso_head_attack_pose() -> void"""
        pass

    def gd_func__apply_torso_head_miss_fall_pose(self):
        """GDScript function: _apply_torso_head_miss_fall_pose(body: Node3D, head: Node3D) -> void"""
        pass

    def gd_func__apply_torso_head_miss_body_hold_pose(self):
        """GDScript function: _apply_torso_head_miss_body_hold_pose(body: Node3D) -> void"""
        pass

    def gd_func__future_head_only_ground_position(self):
        """GDScript function: _future_head_only_ground_position() -> Vector3"""
        pass

    def gd_func__apply_torso_head_recoil_pose(self):
        """GDScript function: _apply_torso_head_recoil_pose(body: Node3D, head: Node3D) -> void"""
        pass

    def gd_func__attack_strength_lagged(self):
        """GDScript function: _attack_strength_lagged(lag: float) -> float"""
        pass

    def gd_func__whip_elbow(self):
        """GDScript function: _whip_elbow(joint_key: String, strength: float) -> void"""
        pass

    def gd_func__apply_right_combo_pose(self):
        """GDScript function: _apply_right_combo_pose(strength: float) -> void"""
        pass

    def gd_func__apply_left_combo_pose(self):
        """GDScript function: _apply_left_combo_pose(strength: float) -> void"""
        pass

    def gd_func__apply_arm_sword_pose(self):
        """GDScript function: _apply_arm_sword_pose(strength: float) -> void"""
        pass

    def gd_func_is_arm_sword_held(self):
        """GDScript function: is_arm_sword_held() -> bool"""
        pass

    def gd_func_note_arm_sword_swing(self):
        """GDScript function: note_arm_sword_swing() -> void"""
        pass

    def gd_func__update_arm_sword(self):
        """GDScript function: _update_arm_sword(delta: float) -> void"""
        pass

    def gd_func__both_arms_equipped(self):
        """GDScript function: _both_arms_equipped() -> bool"""
        pass

    def gd_func__right_hand_rig_position(self):
        """GDScript function: _right_hand_rig_position() -> Vector3"""
        pass

    def gd_func__apply_finisher_combo_pose(self):
        """GDScript function: _apply_finisher_combo_pose(strength: float) -> void"""
        pass

    def gd_func__animate_feet(self):
        """GDScript function: _animate_feet(delta: float) -> void"""
        pass

    def gd_func__place_foot(self):
        """GDScript function: _place_foot(space: PhysicsDirectSpaceState3D, key: String, delta: float) -> void"""
        pass

    def gd_func__find_body(self):
        """GDScript function: _find_body() -> Node3D"""
        pass

    def gd_func__animate_facing(self):
        """GDScript function: _animate_facing(delta: float, facing_direction: Vector3) -> void"""
        pass

    def signal_attack_impact_reached(self):
        """Godot signal: attack_impact_reached()"""
        pass

    def depends_on_ModularSkeletonRig(self):
        """Relationship: references class ModularSkeletonRig."""
        return ModularSkeletonRig

class RigTestPlayer:
    """Godot script: scripts/rig/rig_test_player.gd
    class_name: none
    extends: CharacterBody3D
    system: Rig and animation
    """
    source_file = 'scripts/rig/rig_test_player.gd'
    godot_class_name = ''
    godot_extends = 'CharacterBody3D'
    gameplay_system = 'Rig and animation'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__physics_process(self):
        """GDScript function: _physics_process(delta: float) -> void"""
        pass

    def gd_func__trigger_animation_demo(self):
        """GDScript function: _trigger_animation_demo(use_tween: bool) -> void"""
        pass

    def gd_func__ensure_demo_target(self):
        """GDScript function: _ensure_demo_target() -> void"""
        pass

    def gd_func__update_demo_target(self):
        """GDScript function: _update_demo_target(delta: float) -> void"""
        pass

    def gd_func__cycle_equip(self):
        """GDScript function: _cycle_equip() -> void"""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_ModularSkeletonRig(self):
        """Relationship: references class ModularSkeletonRig."""
        return ModularSkeletonRig

    def depends_on_ProceduralPlayerAnimator(self):
        """Relationship: references class ProceduralPlayerAnimator."""
        return ProceduralPlayerAnimator

class TestingEnvironment:
    """Godot script: scripts/testing_environment.gd
    class_name: none
    extends: Node3D
    system: Supporting gameplay
    """
    source_file = 'scripts/testing_environment.gd'
    godot_class_name = ''
    godot_extends = 'Node3D'
    gameplay_system = 'Supporting gameplay'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__unhandled_input(self):
        """GDScript function: _unhandled_input(event: InputEvent) -> void"""
        pass

    def gd_func__build_world(self):
        """GDScript function: _build_world() -> void"""
        pass

    def gd_func__make_box(self):
        """GDScript function: _make_box(box_name: String, pos: Vector3, size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO) -> StaticBody3D"""
        pass

    def gd_func__make_material(self):
        """GDScript function: _make_material(color: Color) -> StandardMaterial3D"""
        pass

    def gd_func__find_or_create_spawn_root(self):
        """GDScript function: _find_or_create_spawn_root() -> void"""
        pass

    def gd_func__add_spawn_marker(self):
        """GDScript function: _add_spawn_marker(marker_name: String, pos: Vector3, profile: String) -> void"""
        pass

    def gd_func__spawn_player(self):
        """GDScript function: _spawn_player() -> void"""
        pass

    def gd_func__seed_testing_inventory(self):
        """GDScript function: _seed_testing_inventory() -> void"""
        pass

    def gd_func__spawn_initial_enemy_set(self):
        """GDScript function: _spawn_initial_enemy_set() -> void"""
        pass

    def gd_func__spawn_enemy_at_next_marker(self):
        """GDScript function: _spawn_enemy_at_next_marker(profile: String) -> void"""
        pass

    def gd_func__spawn_markers(self):
        """GDScript function: _spawn_markers() -> Array[Marker3D]"""
        pass

    def gd_func__spawn_enemy(self):
        """GDScript function: _spawn_enemy(profile: String, pos: Vector3) -> void"""
        pass

    def gd_func__apply_profile(self):
        """GDScript function: _apply_profile(enemy: Node, profile: String) -> void"""
        pass

    def gd_func__bone_for_profile(self):
        """GDScript function: _bone_for_profile(profile: String) -> String"""
        pass

    def gd_func__try_spawn_dummy(self):
        """GDScript function: _try_spawn_dummy() -> void"""
        pass

    def gd_func__has_live_dummy(self):
        """GDScript function: _has_live_dummy() -> bool"""
        pass

    def gd_func__remove_latest_enemy(self):
        """GDScript function: _remove_latest_enemy() -> void"""
        pass

    def gd_func__on_enemy_defeated(self):
        """GDScript function: _on_enemy_defeated(_enemy: Node, _dropped_bone_id: String) -> void"""
        pass

    def gd_func__build_ui(self):
        """GDScript function: _build_ui() -> void"""
        pass

    def gd_func__update_status(self):
        """GDScript function: _update_status() -> void"""
        pass

    def gd_func__cycle_overlay_mode(self):
        """GDScript function: _cycle_overlay_mode() -> void"""
        pass

    def gd_func__apply_overlay_mode(self):
        """GDScript function: _apply_overlay_mode() -> void"""
        pass

    def gd_func__cycle_validation_guide(self):
        """GDScript function: _cycle_validation_guide(direction: int) -> void"""
        pass

    def gd_func__current_validation_guide_text(self):
        """GDScript function: _current_validation_guide_text() -> String"""
        pass

    def gd_func__begin_notes_editing(self):
        """GDScript function: _begin_notes_editing() -> void"""
        pass

    def gd_func__cancel_notes_editing(self):
        """GDScript function: _cancel_notes_editing() -> void"""
        pass

    def gd_func__on_notes_submitted(self):
        """GDScript function: _on_notes_submitted(text: String) -> void"""
        pass

    def gd_func__runtime_evidence_snapshot(self):
        """GDScript function: _runtime_evidence_snapshot() -> Dictionary"""
        pass

    def gd_func__log_validation_result(self):
        """GDScript function: _log_validation_result(result: String) -> void"""
        pass

    def gd_func__append_log_entry_to_file(self):
        """GDScript function: _append_log_entry_to_file(entry: Dictionary) -> void"""
        pass

    def gd_func__count_validation_results(self):
        """GDScript function: _count_validation_results(result: String) -> int"""
        pass

    def gd_func__validation_log_summary_text(self):
        """GDScript function: _validation_log_summary_text() -> String"""
        pass

    def uses_game_event_enemy_defeated(self):
        """Uses GameEvents.enemy_defeated."""
        pass

    def depends_on_ScenePlayer(self):
        """Relationship: loads resource."""
        return ScenePlayer

    def depends_on_SceneEnemy(self):
        """Relationship: loads resource."""
        return SceneEnemy

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

class TutorialIslandBuilder:
    """Godot script: scripts/tutorial_island_builder.gd
    class_name: none
    extends: Node3D
    system: UI and guidance
    """
    source_file = 'scripts/tutorial_island_builder.gd'
    godot_class_name = ''
    godot_extends = 'Node3D'
    gameplay_system = 'UI and guidance'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func__build_demo_island(self):
        """GDScript function: _build_demo_island() -> void"""
        pass

    def gd_func__resize_base_ground(self):
        """GDScript function: _resize_base_ground() -> void"""
        pass

    def gd_func__place_player_start(self):
        """GDScript function: _place_player_start() -> void"""
        pass

    def gd_func__spawn_starter_torso_pickup(self):
        """GDScript function: _spawn_starter_torso_pickup() -> void"""
        pass

    def gd_func__layout_stage_regions(self):
        """GDScript function: _layout_stage_regions() -> void"""
        pass

    def gd_func__configure_stage(self):
        """GDScript function: _configure_stage(node_name: String, pos: Vector3, trigger_size: Vector3, stage_name: String, difficulty: int, recommended: String, description: String, color: Color) -> void"""
        pass

    def gd_func__layout_story_nodes(self):
        """GDScript function: _layout_story_nodes() -> void"""
        pass

    def gd_func__move_node(self):
        """GDScript function: _move_node(path: String, pos: Vector3) -> void"""
        pass

    def gd_func__build_island_visuals(self):
        """GDScript function: _build_island_visuals() -> void"""
        pass

    def gd_func__build_ocean_and_river(self):
        """GDScript function: _build_ocean_and_river(root: Node3D) -> void"""
        pass

    def gd_func__build_paths(self):
        """GDScript function: _build_paths(root: Node3D) -> void"""
        pass

    def gd_func__build_landmarks(self):
        """GDScript function: _build_landmarks(root: Node3D) -> void"""
        pass

    def gd_func__build_mountain_wall(self):
        """GDScript function: _build_mountain_wall(root: Node3D) -> void"""
        pass

    def gd_func__build_tree_belts(self):
        """GDScript function: _build_tree_belts(root: Node3D) -> void"""
        pass

    def gd_func__spawn_tutorial_enemy_packs(self):
        """GDScript function: _spawn_tutorial_enemy_packs() -> void"""
        pass

    def gd_func__build_enemy_camps(self):
        """GDScript function: _build_enemy_camps(root: Node3D) -> void"""
        pass

    def gd_func__create_enemy_camp(self):
        """GDScript function: _create_enemy_camp(parent: Node3D, camp_name: String, pos: Vector3, reward_bone_id: String, enemy_defs: Array) -> void"""
        pass

    def gd_func__make_camp_ring(self):
        """GDScript function: _make_camp_ring(parent: Node3D, ring_name: String, pos: Vector3) -> void"""
        pass

    def gd_func__dict_vector3(self):
        """GDScript function: _dict_vector3(data: Dictionary, key: String, fallback: Vector3) -> Vector3"""
        pass

    def gd_func__dict_dictionary(self):
        """GDScript function: _dict_dictionary(data: Dictionary, key: String) -> Dictionary"""
        pass

    def gd_func__spawn_enemy(self):
        """GDScript function: _spawn_enemy(enemy_name: String, pos: Vector3, bone_id: String, overrides: Dictionary) -> Node"""
        pass

    def gd_func__make_box(self):
        """GDScript function: _make_box(parent: Node, box_name: String, pos: Vector3, size: Vector3, color: Color, collision: bool, yaw: float = 0.0) -> Node3D"""
        pass

    def gd_func__make_tree(self):
        """GDScript function: _make_tree(parent: Node, tree_name: String, pos: Vector3) -> void"""
        pass

    def gd_func__get_material(self):
        """GDScript function: _get_material(color: Color) -> StandardMaterial3D"""
        pass

    def depends_on_SceneEnemy(self):
        """Relationship: loads resource."""
        return SceneEnemy

    def depends_on_SceneBone(self):
        """Relationship: loads resource."""
        return SceneBone

    def depends_on_DemoEnemyCamp(self):
        """Relationship: loads resource."""
        return DemoEnemyCamp

class BoneItemTile:
    """Godot script: scripts/ui_bone_item.gd
    class_name: BoneItemTile
    extends: Control
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/ui_bone_item.gd'
    godot_class_name = 'BoneItemTile'
    godot_extends = 'Control'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_setup(self):
        """GDScript function: setup(id: String, player_ref: Node, quantity: int = 1) -> void"""
        pass

    def gd_func__place_diamond(self):
        """GDScript function: _place_diamond(rect: ColorRect, centre: Vector2, bounding_side: float) -> void"""
        pass

    def gd_func__gui_input(self):
        """GDScript function: _gui_input(event: InputEvent) -> void"""
        pass

    def gd_func__on_mouse_entered(self):
        """GDScript function: _on_mouse_entered() -> void"""
        pass

    def gd_func__on_mouse_exited(self):
        """GDScript function: _on_mouse_exited() -> void"""
        pass

    def gd_func_refresh(self):
        """GDScript function: refresh() -> void"""
        pass

    def gd_func_set_selected(self):
        """GDScript function: set_selected(value: bool) -> void"""
        pass

    def gd_func__repaint(self):
        """GDScript function: _repaint() -> void"""
        pass

    def gd_func__get_drag_data(self):
        """GDScript function: _get_drag_data(_at_position: Vector2) -> Variant"""
        pass

    def gd_func__make_preview(self):
        """GDScript function: _make_preview() -> Control"""
        pass

    def gd_func__make_tile_style(self):
        """GDScript function: _make_tile_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat"""
        pass

    def gd_func__can_drop_data(self):
        """GDScript function: _can_drop_data(_at_position: Vector2, data: Variant) -> bool"""
        pass

    def gd_func__drop_data(self):
        """GDScript function: _drop_data(_at_position: Vector2, data: Variant) -> void"""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

    def depends_on_PlayerInventoryUI(self):
        """Relationship: references class PlayerInventoryUI."""
        return PlayerInventoryUI

class BoneSlotWidget:
    """Godot script: scripts/ui_bone_slot.gd
    class_name: BoneSlotWidget
    extends: Control
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/ui_bone_slot.gd'
    godot_class_name = 'BoneSlotWidget'
    godot_extends = 'Control'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_resize(self):
        """GDScript function: resize(target_size: Vector2) -> void"""
        pass

    def gd_func__place_diamond(self):
        """GDScript function: _place_diamond(rect: ColorRect, centre: Vector2, bounding_side: float) -> void"""
        pass

    def gd_func__on_mouse_entered(self):
        """GDScript function: _on_mouse_entered() -> void"""
        pass

    def gd_func__on_mouse_exited(self):
        """GDScript function: _on_mouse_exited() -> void"""
        pass

    def gd_func_refresh(self):
        """GDScript function: refresh() -> void"""
        pass

    def gd_func__on_unequip_pressed(self):
        """GDScript function: _on_unequip_pressed() -> void"""
        pass

    def gd_func_set_highlighted(self):
        """GDScript function: set_highlighted(value: bool) -> void"""
        pass

    def gd_func_set_drag_state(self):
        """GDScript function: set_drag_state(state: String) -> void"""
        pass

    def gd_func__repaint(self):
        """GDScript function: _repaint() -> void"""
        pass

    def gd_func__get_drag_data(self):
        """GDScript function: _get_drag_data(_at_position: Vector2) -> Variant"""
        pass

    def gd_func__can_drop_data(self):
        """GDScript function: _can_drop_data(_at_position: Vector2, data: Variant) -> bool"""
        pass

    def gd_func__drop_data(self):
        """GDScript function: _drop_data(_at_position: Vector2, data: Variant) -> void"""
        pass

    def gd_func__notification(self):
        """GDScript function: _notification(what: int) -> void"""
        pass

    def gd_func__gui_input(self):
        """GDScript function: _gui_input(event: InputEvent) -> void"""
        pass

    def gd_func__make_slot_style(self):
        """GDScript function: _make_slot_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat"""
        pass

    def gd_func__equipped_bone_id(self):
        """GDScript function: _equipped_bone_id() -> String"""
        pass

    def depends_on_BoneRulesService(self):
        """Relationship: references class BoneRulesService."""
        return BoneRulesService

    def depends_on_EquipmentRulesService(self):
        """Relationship: references class EquipmentRulesService."""
        return EquipmentRulesService

    def depends_on_PlayerInventoryUI(self):
        """Relationship: references class PlayerInventoryUI."""
        return PlayerInventoryUI

class InventoryEmptySlot:
    """Godot script: scripts/ui_inventory_empty_slot.gd
    class_name: InventoryEmptySlot
    extends: Control
    system: Inventory, equipment, and bones
    """
    source_file = 'scripts/ui_inventory_empty_slot.gd'
    godot_class_name = 'InventoryEmptySlot'
    godot_extends = 'Control'
    gameplay_system = 'Inventory, equipment, and bones'

    def gd_func_setup(self):
        """GDScript function: setup(owner_ref: Node, requested_size: Vector2) -> void"""
        pass

    def gd_func__can_drop_data(self):
        """GDScript function: _can_drop_data(_at_position: Vector2, data: Variant) -> bool"""
        pass

    def gd_func__drop_data(self):
        """GDScript function: _drop_data(_at_position: Vector2, data: Variant) -> void"""
        pass

    def gd_func__make_slot_style(self):
        """GDScript function: _make_slot_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat"""
        pass

class WorldMapManager:
    """Godot script: scripts/world_map_manager.gd
    class_name: none
    extends: Node
    system: World, goals, and progression
    """
    source_file = 'scripts/world_map_manager.gd'
    godot_class_name = ''
    godot_extends = 'Node'
    gameplay_system = 'World, goals, and progression'

    def gd_func__ready(self):
        """GDScript function: _ready() -> void"""
        pass

    def gd_func_enter_stage(self):
        """GDScript function: enter_stage(stage: Node) -> void"""
        pass

    def gd_func_exit_stage(self):
        """GDScript function: exit_stage(stage: Node) -> void"""
        pass

    def gd_func__on_stage_entered(self):
        """GDScript function: _on_stage_entered(stage: Node) -> void"""
        pass

    def gd_func__on_stage_exited(self):
        """GDScript function: _on_stage_exited(stage: Node) -> void"""
        pass

    def gd_func__on_objective_updated(self):
        """GDScript function: _on_objective_updated(source: Node, objective_id: String, title: String, body: String) -> void"""
        pass

    def gd_func__build_map_ui(self):
        """GDScript function: _build_map_ui() -> void"""
        pass

    def gd_func__update_map_ui(self):
        """GDScript function: _update_map_ui() -> void"""
        pass

    def gd_func__emit_region_objective(self):
        """GDScript function: _emit_region_objective() -> void"""
        pass

    def gd_func__region_body(self):
        """GDScript function: _region_body() -> String"""
        pass

    def uses_game_event_stage_entered(self):
        """Uses GameEvents.stage_entered."""
        pass

    def uses_game_event_stage_exited(self):
        """Uses GameEvents.stage_exited."""
        pass

    def uses_game_event_objective_updated(self):
        """Uses GameEvents.objective_updated."""
        pass

    def uses_game_event_tutorial_hint_requested(self):
        """Uses GameEvents.tutorial_hint_requested."""
        pass

class SceneAttackHitbox:
    """Godot scene: scenes/attack_hitbox.tscn"""
    source_file = 'scenes/attack_hitbox.tscn'
    nodes = ['AttackHitbox', 'CollisionShape3D', 'Visual']

    def contains_AttackHitbox(self):
        """Scene relationship: uses script."""
        return AttackHitbox

class SceneBone:
    """Godot scene: scenes/bone.tscn"""
    source_file = 'scenes/bone.tscn'
    nodes = ['BonePickup', 'MeshInstance3D', 'PickupMarker', 'PromptLabel', 'CollisionShape3D']

    def contains_Bone(self):
        """Scene relationship: uses script."""
        return Bone

class SceneBoneTrialGate:
    """Godot scene: scenes/bone_trial_gate.tscn"""
    source_file = 'scenes/bone_trial_gate.tscn'
    nodes = ['BoneTrialGate', 'GateMesh', 'CollisionShape3D', 'GateLabel']

    def contains_BoneTrialGate(self):
        """Scene relationship: uses script."""
        return BoneTrialGate

class SceneDummyTestingEnvironment:
    """Godot scene: scenes/dummy_testing_environment.tscn"""
    source_file = 'scenes/dummy_testing_environment.tscn'
    nodes = ['DummyTestingEnvironment', 'EnemySpawnPoints', 'DummySpawn']

    def contains_TestingEnvironment(self):
        """Scene relationship: uses script."""
        return TestingEnvironment

class SceneEnemy:
    """Godot scene: scenes/enemy.tscn"""
    source_file = 'scenes/enemy.tscn'
    nodes = ['Enemy', 'MeshInstance3D', 'CollisionShape3D', 'VisualRoot', 'ModularSkeletonRig', 'ProceduralAnimator', 'VisionMesh', 'HealthLabel']

    def contains_Enemy(self):
        """Scene relationship: uses script."""
        return Enemy

    def contains_ModularSkeletonRig(self):
        """Scene relationship: uses script."""
        return ModularSkeletonRig

    def contains_ProceduralEnemyAnimator(self):
        """Scene relationship: uses script."""
        return ProceduralEnemyAnimator

class SceneEquippedBone:
    """Godot scene: scenes/equipped_bone.tscn"""
    source_file = 'scenes/equipped_bone.tscn'
    nodes = ['EquippedBone', 'BoneMesh', 'JointMesh']

    pass

class SceneExitPortal:
    """Godot scene: scenes/exit_portal.tscn"""
    source_file = 'scenes/exit_portal.tscn'
    nodes = ['ExitPortal', 'PortalMesh', 'CollisionShape3D', 'PortalLabel']

    def contains_ExitPortal(self):
        """Scene relationship: uses script."""
        return ExitPortal

class SceneGuideWisp:
    """Godot scene: scenes/guide_wisp.tscn"""
    source_file = 'scenes/guide_wisp.tscn'
    nodes = ['GuideWisp', 'Orb', 'Label3D']

    def contains_GuideWisp(self):
        """Scene relationship: uses script."""
        return GuideWisp

class SceneMain:
    """Godot scene: scenes/main.tscn"""
    source_file = 'scenes/main.tscn'
    nodes = ['Main', 'WorldEnvironment', 'DirectionalLight3D', 'Ground', 'MeshInstance3D', 'CollisionShape3D', 'Player', 'GuideWisp', 'ArenaGoalManager', 'WorldMapManager', 'DemoIslandBuilder', 'OpenWorldStages', 'BonefieldHub', 'FirstHuntField', 'ReachRidge', 'QuickrootRun', 'HeavyRuin', 'RibfenBonus', 'ElderMarrowGate', 'SightTestWalls', 'CenterHideWall', 'LeftHideWall', 'RightHideWall', 'EnemyCenter', 'EnemyLeft', 'EnemyRight', 'ArmTrialGate', 'LegTrialGate', 'HeavyTrialGate', 'EnemyBonus', 'ExitPortal']

    def contains_ArenaGoalManager(self):
        """Scene relationship: uses script."""
        return ArenaGoalManager

    def contains_WorldMapManager(self):
        """Scene relationship: uses script."""
        return WorldMapManager

    def contains_TutorialIslandBuilder(self):
        """Scene relationship: uses script."""
        return TutorialIslandBuilder

    def contains_ScenePlayer(self):
        """Scene relationship: instantiates scene."""
        return ScenePlayer

    def contains_SceneEnemy(self):
        """Scene relationship: instantiates scene."""
        return SceneEnemy

    def contains_SceneBoneTrialGate(self):
        """Scene relationship: instantiates scene."""
        return SceneBoneTrialGate

    def contains_SceneExitPortal(self):
        """Scene relationship: instantiates scene."""
        return SceneExitPortal

    def contains_SceneOpenWorldStage(self):
        """Scene relationship: instantiates scene."""
        return SceneOpenWorldStage

    def contains_SceneGuideWisp(self):
        """Scene relationship: instantiates scene."""
        return SceneGuideWisp

class SceneMainMenu:
    """Godot scene: scenes/main_menu.tscn"""
    source_file = 'scenes/main_menu.tscn'
    nodes = ['MainMenu']

    def contains_MainMenu(self):
        """Scene relationship: uses script."""
        return MainMenu

class SceneOpenWorldStage:
    """Godot scene: scenes/open_world_stage.tscn"""
    source_file = 'scenes/open_world_stage.tscn'
    nodes = ['OpenWorldStage', 'StageBody', 'StageMesh', 'StageCollision', 'StageTrigger', 'StageTriggerShape', 'StageLabel']

    def contains_OpenWorldStage(self):
        """Scene relationship: uses script."""
        return OpenWorldStage

class ScenePlayer:
    """Godot scene: scenes/player.tscn"""
    source_file = 'scenes/player.tscn'
    nodes = ['Player', 'MeshInstance3D', 'CollisionShape3D', 'VisualRoot', 'ModularSkeletonRig', 'ProceduralAnimator', 'SocketArmRight', 'SocketArmLeft', 'SocketLegs', 'SocketBody', 'CameraPivot', 'SpringArm3D', 'Camera3D']

    def contains_Player(self):
        """Scene relationship: uses script."""
        return Player

    def contains_ModularSkeletonRig(self):
        """Scene relationship: uses script."""
        return ModularSkeletonRig

    def contains_ProceduralPlayerAnimator(self):
        """Scene relationship: uses script."""
        return ProceduralPlayerAnimator

    def contains_PlayerCameraController(self):
        """Scene relationship: uses script."""
        return PlayerCameraController

class SceneRigTest:
    """Godot scene: scenes/rig_test.tscn"""
    source_file = 'scenes/rig_test.tscn'
    nodes = ['RigTest', 'WorldEnvironment', 'DirectionalLight3D', 'Ground', 'GroundMesh', 'GroundCollision', 'Ramp', 'RampMesh', 'RampCollision', 'RigTestPlayer', 'CollisionShape3D', 'CameraPivot', 'Camera3D', 'VisualRoot', 'ModularSkeletonRig', 'ProceduralAnimator']

    def contains_RigTestPlayer(self):
        """Scene relationship: uses script."""
        return RigTestPlayer

    def contains_ModularSkeletonRig(self):
        """Scene relationship: uses script."""
        return ModularSkeletonRig

    def contains_ProceduralPlayerAnimator(self):
        """Scene relationship: uses script."""
        return ProceduralPlayerAnimator

class SceneTestingEnvironment:
    """Godot scene: scenes/testing_environment.tscn"""
    source_file = 'scenes/testing_environment.tscn'
    nodes = ['TestingEnvironment', 'EnemySpawnPoints', 'NormalSpawn', 'GorillaSpawn', 'LizardSpawn', 'RangedSpawn', 'DummySpawn']

    def contains_TestingEnvironment(self):
        """Scene relationship: uses script."""
        return TestingEnvironment

