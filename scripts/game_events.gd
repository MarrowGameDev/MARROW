extends Node

# Global gameplay event bus.
#
# Use this for events that several distant systems may care about. Emitters
# should announce what happened and move on; listeners decide how to react.

signal bone_collected(bone_id: String, collector: Node)
signal bone_equipped(bone_id: String, slot: String, player: Node)
signal bone_unequipped(bone_id: String, slot: String, player: Node)
signal inventory_changed(player: Node, items: Array, stats: Dictionary)
signal inventory_open_changed(player: Node, is_open: bool)
signal pickup_focus_changed(pickup: Node, bone_id: String, player: Node, in_range: bool)
signal pickup_collected(bone_id: String, pickup: Node, collector: Node)
signal drop_spawned(bone_id: String, pickup: Node, source: Node)
signal enemy_defeated(enemy: Node, dropped_bone_id: String)
signal player_died(player: Node)
signal trial_completed(trial_id: String, trial_name: String)
signal exit_reached(player: Node)
signal stage_entered(stage: Node)
signal stage_exited(stage: Node)
signal objective_updated(source: Node, objective_id: String, title: String, body: String)
signal tutorial_hint_requested(source: Node, hint_id: String, text: String, priority: int)
signal camp_state_changed(camp: Node, unlocked: bool, opened: bool, remaining_enemies: int)
signal camp_chest_opened(camp: Node, reward_bone_id: String, player: Node)
