# Godot Signal Guidelines

These rules keep Marrow's scenes modular while the project is still small.

## Prefer Event Names

Signals should describe what happened, not what another node must do.

Good:
- `bone_collected`
- `trial_completed`
- `player_died`

Avoid:
- `update_inventory`
- `open_win_screen`
- `tell_manager_trial_done`

## Signal Up, Call Down

Child nodes and world objects announce events upward or globally.
Managers and parent nodes decide how to react and can call methods downward.

Examples in this project:
- `BoneTrialGate` emits `GameEvents.trial_completed`.
- `ArenaGoalManager` listens and opens the exit when enough trials are complete.
- `OpenWorldStage` emits `GameEvents.stage_entered`.
- `WorldMapManager` listens and updates the map UI.

## Pass Useful Data

Signals should carry the information listeners need without forcing them to
look back into the emitter.

Examples:
- `bone_collected(bone_id, collector)`
- `bone_equipped(bone_id, slot, player)`
- `camp_chest_opened(camp, reward_bone_id, player)`

## Keep Emitters Decoupled

After emitting a signal, the emitter should not wait for a specific listener to
do something. If the emitter needs an immediate local result, use a direct method
call instead.

For now, pickups and camp chests still call `player.collect_bone(...)` directly
because that is the immediate gameplay action. They also emit events afterward so
future systems like audio, analytics, achievements, and tutorials can react.

## Use `GameEvents` Sparingly

`GameEvents` is for cross-scene gameplay events that distant systems may need.
Do not put every button hover or tiny local interaction on the global bus.
