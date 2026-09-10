# Marionette Hand Character

The animated hand is imported from:

`res://assets/marionette_hand/marionette_hand_player.glb`

The GLB contains the skinned mesh, skeleton, material, embedded base-color,
normal, and roughness/metallic textures, plus these animation clips:

- `Idle` (subtle default loop)
- `AFK Rock` (one-shot)
- `AFK Paper` (one-shot)
- `AFK Scissors` (one-shot)
- `Walking Forward` (loop)
- `Running` (loop)
- `Jumping` (one shot)

Use `res://scenes/marionette_hand_character.tscn` when adding the hand to a
scene. Its `MarionetteHandCharacter` controller exposes `play_idle()`,
`play_walk()`, `play_run()`, and `play_jump()`. Jumping returns to Idle when it
finishes.

This is a standalone visual character scene. It does not replace the current
collision or movement logic. The player scene now instances it as the visible
character and maps movement state to clips:

- no movement: `Idle`
- W/A/S/D movement: `Walking Forward`
- Shift while moving: `Running`
- Space: `Jumping`

After 30 seconds without player input, the hand turns onto its side and performs
three bouncing beats. On the final beat it jumps sideways, briefly floats while
showing a randomly chosen Rock, Paper, or Scissors pose, then lands and returns
to the subtle idle. Another throw requires another 30 seconds of inactivity.
Movement, jumping, attacking, aiming, or other keyboard, mouse, controller, or
touch input interrupts the AFK throw and immediately returns it to the
appropriate animation.

The player GLB is optimized from 1,318,208 to 105,456 triangles (92% reduction),
with its three texture maps reduced from 4096x4096 to 2048x2048. The original
high-resolution animated GLB remains alongside it as a source-quality reference.

## Minimal gameplay scene

`res://scenes/main.tscn` is the project startup scene and now contains only the
world environment, directional light, physical floor, and hand player. The
previous populated gameplay scene is preserved at
`res://scenes/main_full_backup.tscn` for recovery or selective reuse.
