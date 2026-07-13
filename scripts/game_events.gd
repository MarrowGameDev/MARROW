extends Node

# Global gameplay event bus.
#
# Use this for events that several distant systems may care about. Emitters
# should announce what happened and move on; listeners decide how to react.

signal bone_collected(bone_id: String, collector: Node)
signal bone_equipped(bone_id: String, slot: String, player: Node)
signal bone_unequipped(bone_id: String, slot: String, player: Node)
signal player_died(player: Node)
signal trial_completed(trial_id: String, trial_name: String)
signal exit_reached(player: Node)
signal stage_entered(stage: Node)
signal stage_exited(stage: Node)
signal camp_chest_opened(camp: Node, reward_bone_id: String, player: Node)
