# Marrow — Modular Rig / Procedural Animation notes

Isolated prototype for the "Modular Rigging and Procedural Animation" brief.
**Not wired into the real player yet** (brief Phase G) — test it in `rig_test.tscn` first.

## How to test
Open `scenes/rig_test.tscn` in Godot and run it (F6 / "Run Current Scene").

- **WASD** — move. Body bobs, torso leans, arms/legs swing, and the whole figure
  turns smoothly toward the movement direction. Standing still = subtle idle breathing.
- **Attack** — cycles simple combo poses: right-arm strike, left-arm strike,
  then a heavier two-arm/torso finisher.
- **Q** — cycles equipping **Arm → Leg → Heavy** into their slots. The grey limb is
  swapped for a bone-colored one; Heavy is bigger (visual_scale) and heavier.
- Walk **forward onto the ramp** (in front of spawn) to see foot placement (Phase F):
  each foot raycasts down and plants on the surface, tilting to the slope.

### Animation A/B demo (rig sandbox only)
`2` and `3` play the SAME head lunge authored two ways, so the two styles can be
compared. Both read the `head_only_attack_*` tuning, so retuning moves them
together and any difference is the authoring style, not the numbers.

Lives in `scripts/rig/rig_test_player.gd`, so it is confined to `rig_test.tscn`
and never reaches the shipping `Player`. The animator keeps the demo poses
(`trigger_demo_attack_procedural` / `trigger_demo_attack_tween` /
`set_demo_target_world_position`) because that is animation code and both scenes
share the animator, but nothing triggers them outside the sandbox.

- **2** — `ProceduralPlayerAnimator.trigger_demo_attack_procedural()`: per-frame
  math with hand-written easing helpers (`_ease_out_quad` and friends).
- **3** — `ProceduralPlayerAnimator.trigger_demo_attack_tween()`: a `Tween` chain,
  easing by name (`TRANS_QUAD` + `EASE_OUT`).

An orange ball spawns on first press and orbits the player as a moving target.
Key `2` re-aims mid-flight and tracks it; key `3` commits to wherever the ball was
when the tween was built and misses by ~40 deg. That is the real trade: identical
output, the tween is nicer to author, only the procedural version can react to a
runtime target. Measured headless: both trace the same arc (peak 0.9199 vs 0.9197).

Because `_animate_body()` rebuilds `head.position` from rest every frame, the
tween cannot own the socket — it drives values that `_apply_demo_pose()` writes at
the end of the animator's frame. An `AnimationPlayer` would hit the same wall.
The demo hijacks the head socket regardless of equipped state, and settles back to
a pose captured at trigger time, so it may pop slightly if triggered mid-sprint.

## Head model (skull)
The player's head is `assets/skull.glb` instead of a grey box. Wired in
`player.tscn` via `ModularSkeletonRig.head_model_scene`.

- Both the base head box AND the equipped head bone are built by `_make_limb()`,
  so that is the only hook needed. It has to cover both:
  `PlayerEquipmentComponent.equip_starting_core()` equips `head_bone` on spawn and
  `_base_socket_should_show()` returns false for an equipped socket, so the head
  you actually SEE is the equipped bone's visual — swapping only the base box
  would look like nothing happened.
- `head_model_scale` 0.32: skull.glb measures ~0.96 x 1.00 x 0.96 around its own
  origin, and the grey head box it replaces is 0.32 (LIMB_GEO). It MULTIPLIES the
  bone's `visual_scale`, so a bigger head bone still reads bigger. Measured in
  play: the visible head is 0.307 x 0.319 x 0.306.
- `head_model_rotation_deg` is `(0, -90, 0)` in `player.tscn`. skull.glb's face
  points down its own **+X**, established from two in-game observations that agree:
  at rotation 0 it looked left, and at +90 it looked backward. The mesh is
  near-symmetric (0.959 vs 0.955 on X/Z), so its facing cannot be derived from its
  bounds — only from looking at it.
- Careful with left/right here: this rig's forward is **+Z** (`_animate_facing`
  sets `rotation.y = atan2(flat.x, flat.z)`, aiming the node's +Z along facing),
  which is 180 deg from Godot's standard -Z forward. That flip swaps handedness:
  facing +Z the character's right is **-X** and its LEFT is **+X**. Assuming
  Godot's usual "+X is right" here gives exactly the wrong sign.
- `equip_bone()` ADDS `visual_rotation`/`visual_offset` rather than assigning
  them. Assigning discarded `head_model_rotation_deg` on the EQUIPPED head (the
  visible one) while the hidden base box rotated correctly. Every current bone has
  a zero `visual_rotation`, so `+=` is identical to `=` for them.
- `head_model_keep_material` (true) keeps the imported skull material instead of
  flat-tinting it with the bone colour the grey boxes use.
- With no `head_model_scene` assigned the grey box is used, so enemies (which
  share `ModularSkeletonRig`) are unaffected.
- Hitboxes are unchanged: `_apply_equipped_body_hitbox()` sizes from the bone
  data, not the visual.

## Split limbs (elbows and knees)
`ModularSkeletonRig.use_split_limbs` (on in `player.tscn`) splits each arm/leg
into an upper and a lower half with a bending elbow/knee.

Socket tree when split (right side; left mirrors):

    right_arm_socket            (0.28, 0.30, 0)   shoulder — swing pivot
    ├── MeshInstance3D  box(0.16, 0.29, 0.16) @ -0.145   -> base_visuals["right_arm"]
    └── right_arm_lower_socket  (0, -0.29, 0)     ELBOW — bend pivot
        └── MeshInstance3D  box(0.16, 0.29, 0.16) @ -0.145 -> base_visuals["right_arm_lower"]

    right_leg_socket            (0.16, -0.35, 0)  hip
    ├── MeshInstance3D  box(0.18, 0.31, 0.18) @ -0.155   -> base_visuals["right_leg"]
    └── right_leg_lower_socket  (0, -0.31, 0)     KNEE
        ├── MeshInstance3D  box(0.18, 0.31, 0.18) @ -0.155 -> base_visuals["right_leg_lower"]
        └── right_foot_socket   (0, -0.27, 0.06)  MOVED off the hip

The torso splits too, into a chest and an abdomen meeting at a WAIST socket at the
body origin (`body` keeps the chest, `body_lower` hangs the abdomen below it):

    body_socket                 (0, 0, 0)        root / waist
    ├── MeshInstance3D  box(0.5, 0.35, 0.28) @ +0.175  -> base_visuals["body"]        CHEST
    └── body_lower_socket       (0, 0, 0)        WAIST — structural only
        └── MeshInstance3D  box(0.5, 0.35, 0.28) @ -0.175 -> base_visuals["body_lower"] ABDOMEN

Proportions (split rig only — enemies keep the old 0.5 torso / 0.18 legs):

| part | size | note |
|---|---|---|
| chest (`body`) | 0.50 x 0.35 x 0.28 | UNCHANGED — width pinned by the arm sockets |
| waist (`body_lower`) | 0.40 x 0.35 x 0.22 | 0.80 of the chest wide, 0.79 deep |
| thigh / shin | 0.16 x 0.31 x 0.16 | narrowed from 0.18 to fit inside the waist |
| hip socket X | +-0.12 | `SPLIT_SOCKET_LAYOUT`, was +-0.16 |

The arithmetic that has to close, and why each number is what it is:
- **Legs inside the waist:** hip 0.12 + half-leg 0.08 = 0.20 = waist half-width. Flush
  by design, not a near miss — the thigh starts at y=-0.35 where the waist ends, so
  there is no shared height and nothing to z-fight. The leg's outer wall simply
  continues the waist's downward, which is what a hip looks like.
- **The hip HAD to move.** Keeping it at 0.16 requires waist >= 0.32 + legWidth; even
  at a 0.16 leg that is a 0.48 waist — a 0.01/side taper, invisible. There is no
  version of this that keeps the sockets.
- **The FOOT sets the floor.** `LIMB_GEO["*_foot"]` (0.2 wide) is shared with enemies
  and has no split-only override, so foot width is immovable, and the foot centres on
  its leg socket X. Hip 0.10 would put the feet at x[0.00,0.20] — touching at the
  centreline and fusing into one slab. Hip 0.12 gives a 0.04 gap. That floor is what
  fixes the waist at 0.40 rather than a slimmer 0.36.
- **The 0.04 gap is stable:** legs only rotate about X, and crawl/wall-climb offsets
  push them APART, so rest is the worst case.
- **The chest cannot narrow.** Arm sockets sit at +-0.28 with a 0.16 arm, so the arm
  buries 0.05 of itself in the chest. That embed is what makes a shoulder read as a
  joint; at a 0.40 chest the arms come away from the body. Leaving it also gives the
  waist its reference edge — a taper is contrast.
- **Z tapers too** (0.28 -> 0.22). The waist has no bend, so static geometry is its
  only cue; a width-only taper vanishes in profile.

### The waist bend
The chest leans at the waist and the head and arms come with it, giving a
two-segment spine instead of a rigid plank. Tuning lives in the animator's
`Waist` export group (`waist_bend_lean` 0.10 is the main read; set it to 0 to
disable the feature at runtime).

- `_build_waist_joint()` inserts a `waist_joint` Node3D between the body socket
  and the chest mesh. It sits at body-local ZERO because the waist plane IS the
  body origin, which makes moving the chest mesh onto it a NUMERIC IDENTITY.
- It is NOT in `sockets`, on purpose. A new socket key would silently need a
  `LIMB_GEO` entry (else a 0.2 m cube), an `ENEMY_HITBOX_ACCURACY_SCALE` entry
  (else a default scale) and a `_base_socket_should_show` branch (else `return
  true`, rendering an unearned chest). Staying out of the dict sidesteps all three
  plus the marker/equip/hitbox loops. `get_waist_joint()` returns null on an
  unsplit rig, and that null IS the animator's gate — the animator is shared and
  has no per-rig flag.
- `get_socket_attach("body")` returns the pivot, so equipped torso art and the
  chest hurtbox bend with it.
- **NOT routed through `_animate_joints`.** That writer is for elbows and knees:
  it ASSIGNS rotation (stomping other writers), its `joint_bend_base` 0.12 +
  `joint_bend_swing` 0.7 would give the chest a permanent 0.12–0.82 rad flex every
  step, and its `bend_sign` keys off the substring `"arm"`.

**The head and arms are NOT reparented under the chest** — and that is the
load-bearing decision. Reparenting is the obvious way to make them follow, but
`_capture_rest()` stores every socket's PARENT-LOCAL rest pose, so it silently
redefines what `_rest_pos["head"]` means and six families break at once:
torso-spring (`head.position = body.position + offset`), the head-only ground
constants (rig-space −0.85 fused with chest-space rest.x/z), the 12
`_world_horizontal_offset_to_local` call sites (rig-basis directions applied in a
tilted frame), `rig.to_local` across the player.gd boundary, the doubled crawl
drops, and — the one nothing warns about — `body.scale`'s squash-and-stretch,
which would suddenly squash the head and both arms.

So `_apply_waist_carry()` ADDS the transform a hierarchy would have contributed,
by hand, after every other writer. No socket changes parent, so no space changes
and all six are structurally absent. **Verified equivalent:** the carried head and
a real parent transform agree to 0.00000 m.

Two consequences to respect:
- **`_animate_waist(delta)` MUST stay last in `update_from_player`.** A writer
  added below it escapes the carry, and the head silently stops following the
  chest. This is the price of the carry over a real hierarchy.
- `_waist_target_angle()` returns exactly 0.0 in head-only, torso-spring, crawl,
  the detach/reattach states and the demo — every mode that owns the head socket
  or already pitches the torso. `_apply_waist_carry` early-returns on
  `is_zero_approx`, so those modes are bit-identical to a build with no waist.

Do the real reparent only when something needs a writer BETWEEN the waist and the
head/arms (IK, a skinned chest, per-socket physics), or when the ordering rule
above actually bites.

**The ABDOMEN (`body_lower`) does NOT bend, deliberately** (`LOWER_UNDER_UPPER["body_lower"]` sets
`bend: false`, so it is never registered in `limb_joints`). The head and arm
sockets are SIBLINGS of `body`, not children, so a bending waist would swing the
chest away from them and tear the figure apart. The split is an attach point for
swapping in a chest and an abdomen mesh, not an animated joint. Making it bend
means first reparenting head/arms under the chest — a much larger animator change.
Note the torso box is CENTRED on its socket (offset +0.175 for the chest), unlike
the limbs which hang from theirs (-0.145 / -0.155).

Rules that keep this safe:

- **Lower sockets are CHILDREN of their upper**, like `FOOT_UNDER_LEG` already
  does for feet. They cannot go in `SOCKET_LAYOUT`: that loop `add_child()`s every
  socket to the RIG, so a lower limb declared there would be a sibling and neither
  the shoulder swing nor the elbow bend would carry it.
- **`base_visuals[key]` stays a flat key -> MeshInstance3D map.** Each half gets
  its OWN key. Do not make it a container: `enemy.gd:1366` casts
  `base_visuals[limb_key] as MeshInstance3D` and reads `.mesh`, and a container
  would null that cast and silently stop enemy limbs from spawning.
- **Do not parent the elbow under the upper MESH.** Tempting (hiding a parent
  hides descendants), but `equip_bone()` hides `base_visuals[key]`, so equipping
  any arm bone would make the forearm vanish.
- **All limb geometry goes through `_limb_geo_for()`, never `LIMB_GEO` directly.**
  That helper is what swaps a split upper limb to its half-length
  `SPLIT_UPPER_GEO` box. `_make_limb` originally read the dict directly, which
  left the upper arm at full 0.58 with the forearm overlapping it — and desynced
  the art from the hurtbox, because the hitbox builders already used the helper.
- **Zero-diff invariant.** The halves reconstruct the original box exactly:
  arm 0.29+0.29=0.58, leg 0.31+0.31=0.62, and the foot resolves to leg-space -0.58
  either way. Verified: split and unsplit silhouettes match to 0.00000. If the
  split is ever suspected of moving the pose, set `joint_bend_base` and
  `joint_bend_swing` to 0 — the rig must then be identical to the unsplit one.
  CAUTION: this invariant is necessary but NOT sufficient. It only measures how
  DEEP a limb reaches, which is identical whether or not the upper half was
  shortened — it passed while the uppers were still full length. Check each
  segment's own LENGTH too (0.29 / 0.31), not just the limb's total extent.
- **Vocabulary boundary.** The `*_lower` keys are a RENDER + HITBOX concern only.
  They belong in `LIMB_GEO`, `SPLIT_UPPER_GEO`, `ENEMY_HITBOX_ACCURACY_SCALE` and
  `SLOT_TO_SOCKETS`. Never in `LIMB_TO_SLOT`, `primary_limb_keys_for_slot`,
  `LIMB_DISPLAY`, `DETACHABLE_LIMBS`/`PICKUP_ELIGIBLE_LIMBS` or
  `detached_limb_keys` — a lower key there generates a bone id like
  `normal_right_arm_lower_bone` that `slot_for_bone` cannot parse, so the drop
  silently no-ops.
- **`_base_socket_should_show()` must name the lower keys.** They otherwise fall
  through to `return true`, and with body progression on an unearned forearm
  renders alone while its upper half is correctly hidden.
- **`_animate_joints()` reads `kind` FIRST.** The skinned entry has `"skel"`; the
  socket entry does not, and `var skel: Skeleton3D = info["skel"]` HALTS the
  script rather than failing soft like the rest of this codebase.
- Equipment needed one constant: `SLOT_TO_SOCKETS` gained the lower keys, so
  `equip_bone`'s existing per-socket loop paints both halves. No slot changed.

`use_split_limbs` is a TEMPORARY migration adapter (AGENTS.md: "migraciones
graduales y con adaptadores"). It is off for enemies so their paths stay
byte-identical. Remaining cuts:
- **Cut 2 — enemies.** `enemy.gd` fans `_set_rig_limb_visible`,
  `_limb_recovery_group`, `_recovery_group_key` and `_spawn_detached_limb_piece`
  over `rig.limb_socket_group()` / `rig.get_limb_meshes()`, THEN flip
  `enemy.tscn`. Flip it first and a detached arm leaves a floating forearm with a
  live hurtbox.
- **Cut 3 — proportions + delete the flag.** `apply_gorilla_proportions` /
  `apply_lizard_proportions` resize whole limbs; applied to a half they render a
  ~1.3 m arm. Then remove the flag. If it outlives cut 3 it is permanent debt.
- `foot_placement_enabled` (off by default) assigns `foot.position` in the foot's
  parent space, which is now the ROTATING knee. Resolve that before enabling it.

## Socket markers (model-swap build aid)
`ModularSkeletonRig.show_socket_markers` (on in `player.tscn`) puts a small
magenta ball on every socket ORIGIN — 12 of them: pelvis, neck, both shoulders,
both elbows, both hips, both knees, both ankles.

Why they are worth having: the animator only ever rotates and moves SOCKETS —
`_swing()` turns the shoulder/hip, `_animate_joints()` turns the elbow/knee,
`_anchor_socket_to_body()` re-anchors arms in torso-spring mode. So a socket
origin is exactly the point a real model's joint has to land on. Line a model's
shoulder up with the shoulder ball and the procedural animation needs no
compensation; miss it and every pose is off by that offset forever.

- Parented AT the socket, so a marker inherits every rotation the animator
  applies. Verified: the elbow marker travels 0.618 m through a walk cycle.
- Drawn unshaded with depth-test off, so a marker buried inside a limb box is
  still readable. No shadow, no collision, no Area3D.
- NOT registered in `base_visuals`. That dict is the limb registry: it drives
  equip/progression visibility and enemy dismemberment clones
  `base_visuals[key].mesh`, so a marker in there could ragdoll away as a limb.
- Default OFF, because enemies share this rig. Verified: with the export off, no
  marker nodes exist at all and the hurtbox count is unchanged.
- Known interaction: `set_head_only_visual_guard(true)` hides every head-socket
  child that is not an equipped head part, so the NECK marker disappears in
  head-only mode. Harmless for an overlay; do not "fix" it by special-casing the
  guard.
- Tune with `socket_marker_radius` (0.035) and `socket_marker_color`.

## Architecture (animate sockets, not meshes)
- `scripts/rig/modular_skeleton_rig.gd` (`ModularSkeletonRig`) — builds Node3D
  sockets in `_ready()` and hangs a grey box on each. `equip_bone(id, def)` /
  `unequip_slot(slot)` swap the socket's visual. Equipped bones are children of
  sockets, so they inherit socket motion for free.
- `scripts/rig/procedural_player_animator.gd` (`ProceduralPlayerAnimator`) —
  `update_from_player(delta, velocity, max_speed, facing, equipped_defs)` moves
  the sockets from the ACTUAL velocity (so slopes/knockback/speed bonuses all read
  correctly). Layers: idle breathing, walk bob, torso lean/sway, arm+leg swing,
  turn smoothing, weight response.
- `scripts/bone_database.gd` — compatibility layer for bone data; `weight`
  remains the legacy animation weight while `physical_weight`,
  `equipment_weight`, `inventory_weight` and `weight_class` are available for
  future rig/inventory rules.
- `scripts/rig/rig_test_player.gd` — sandbox movement controller (no combat/inventory).

## Tuning variables (exports on ProceduralAnimator)
walk_cycle_speed 8.0 · body_bob_amount 0.08 · body_sway_amount 0.04 ·
torso_lean_amount 0.12 · arm_swing_amount 0.45 · leg_swing_amount 0.35 ·
turn_smoothing 12.0 · idle_breath_amount 0.025 · heavy_weight_swing_slowdown 0.65

## Phase E/F tuning (exports on ProceduralAnimator)
attack_overlay_duration 0.16 · attack_overlay_blend_speed 18 · attack_arm_forward 1.1 ·
attack_torso_twist 0.35 · foot_raycast_up/down 0.6/1.4 · foot_lift 0.06 ·
foot_smoothing 14 · foot_align_to_normal true (uncheck foot_placement_enabled to disable).
Head-only attack tuning: `head_only_attack_duration`,
`head_only_attack_charge_portion`, `head_only_attack_lunge`,
`head_only_attack_arc`, `head_only_attack_charge_squash`,
`head_only_attack_roll`, `head_only_attack_release_portion` 0.25 (fraction of the
jump over which the charge compression unwinds; 0 restores the old one-frame
snap) and `head_only_attack_roll_damping` 0.2 (how much rolling spin survives
while the head is airborne mid-attack; 1.0 restores the old behaviour).
Hit recoil tuning: `head_only_hit_recoil_duration`,
`head_only_hit_recoil_hold`, `head_only_hit_recoil_arc`,
`head_only_hit_recoil_lift`, `head_only_hit_recoil_horizontal_push`,
`head_only_hit_recoil_roll` and `head_only_hit_recoil_settle`.

Head-launch auto-aim:
- `Player` pushes a world-space aim into
  `ProceduralPlayerAnimator.set_head_launch_attack_aim(direction, valid)` every
  frame (before `update_from_player`). `valid = false` restores the old behaviour
  of launching down the player's facing direction.
- `trigger_attack` seeds `_head_only_attack_direction` /
  `_torso_head_attack_direction` from that aim, and
  `_update_head_launch_attack_aim()` keeps re-reading it every frame while the
  launch is in the air, so an enemy that moves mid-attack is tracked. The
  direction freezes on landing so the landing offset matches the pose reached.
- The animator knows nothing about enemies. Enemy lookup and range rules live in
  `Player` + `CombatTargetingService` (see `docs/combat_flow.md`).

Combo overlay:
- `Player` passes a combo step into `ProceduralPlayerAnimator.trigger_attack`.
- Step 1 uses right arm + torso twist.
- Step 2 uses left arm + opposite torso twist.
- Step 3 uses both arms, deeper lunge, and a small head dip.
- If the player is only a head, combo arm poses are skipped. The head instead
  squashes backward to charge, jumps forward/up toward the target direction,
  reaches above mid-torso height, and lands forward into a new rolling start
  point. That forward landing is now a real displacement of the PLAYER: on
  landing the animator raises `has_head_only_body_catch_up_request()` and the
  Player consumes it the same frame, moving the capsule to the head with
  `move_and_collide` (so lunging into a wall stops at the wall). Previously the
  landing accumulated into `_head_only_base_world_offset` and only the head
  visual moved, so the head drifted 0.85 m further from the capsule on every
  attack, forever — and that drift also leaked into the camera follow offset via
  `get_head_launch_attack_world_offset()`. A hit does not displace the player:
  the recoil returns the head to the body instead. The launch uses the rig's positive
  local Z direction so it moves forward in game view. The landed offset is
  stored as a world-horizontal vector and converted into rig-local space each
  frame, so turning or strafing sideways does not rotate the old landing offset
  and teleport the head.
- The landing frame applies the newly accumulated landed offset immediately,
  instead of waiting for the next animation tick. This prevents a one-frame
  snap/ghost where the head briefly appears at the previous start point.
- If `AttackHitbox` confirms a real contact, the head-only attack switches into
  a separate hit recoil pose. It captures the exact local `head` socket position
  at impact, including the screen X/Y placement, and blends from that pose back
  toward the pre-impact start point while the camera follows the horizontal
  recoil. The extra ground-plane push ramps in during the recoil instead of
  snapping on the impact frame. The recoil uses smoothstep easing plus a small
  damped settle wave. `head_only_hit_recoil_lift` is only used as a minimum
  bounce height after recoil starts, and `head_only_hit_recoil_horizontal_push`
  controls the extra shove along the ground plane. A miss still lands forward
  and becomes the next start point.
- Current head-only height tuning uses `head_only_attack_arc = 0.92`,
  `head_only_hit_recoil_arc = 0.64`, and `head_only_hit_recoil_lift = 0.46`.
- Head-only melee uses a small `AttackHitbox` volume that follows the rig's
  `head` socket every physics frame. Contact is driven by the visible head
  position, including the vertical arc/recoil, instead of forcing the animator to
  snap forward to a minimum impact offset.
- During that head-only attack, the animator exposes
  `get_head_only_attack_world_offset()` so the camera can follow the accumulated
  horizontal motion directly. The vertical arc stays visual on the head socket.
- `ModularSkeletonRig.set_head_only_visual_guard` runs during head-only movement
  to keep the equipped/core head mesh as the only visible mesh under the head
  socket. `Player` also calls the guard immediately when head-only melee starts,
  before spawning the attack hitbox, so the fallback grey head cannot overlap
  for the first rendered frame.
- This is visual only; melee damage and hitbox behavior are unchanged.

## Current player body progression
- The real player now enables body progression on `ModularSkeletonRig`.
- `Player._setup_procedural_character()` enables
  `player_body_progression_enabled` on `ProceduralPlayerAnimator`; enemies keep
  this disabled.
- The head is the fixed core. Torso must be equipped before arms or legs can
  attach.
- When the torso is missing, `ProceduralPlayerAnimator` uses
  `head_only_ground_socket_y` to place the head socket at ground height instead
  of the normal full-body head rest pose.
- Head-only movement increments `_head_only_roll_angle` from actual horizontal
  travel distance and applies that as rotation, so the head rolls along the
  ground instead of wobbling like a loose limb.
- The head-only vertical hop defaults to `0.0`, keeping the head planted unless
  designers intentionally tune bounce back in.
- The wobble pass skips the head while it is the only equipped core, so it does
  not reset the head back to the full-body rest height or overwrite the roll.
- When the torso is equipped but legs are still missing,
  `ProceduralPlayerAnimator` enters a torso-spring state. The torso compresses,
  launches upward/forward and settles like a spring from
  `torso_spring_ground_socket_y`, with the head placed from
  the equipped torso's `head_socket_offset` relative to the springing torso. If
  a torso has no socket data, the animator falls back to
  `torso_spring_head_offset`. The head adds a delayed
  `torso_spring_head_pop_amount` bounce so it rises a bit higher than the torso
  and settles back into place by the end of the cycle. The head uses extra side
  drift and rotation during this state so the torso-only movement reads more
  exaggerated than the full-body animation.
- Torso-only attack uses separate `torso_head_attack_*` tuning. The torso coils
  down, the head launches forward from the current torso spring socket, and the
  skull sphere hitbox follows the launched head. On confirmed contact, the head
  recoils high into the air and returns to the live torso socket position. Once
  landed, the overlay pins the head to that socket so it cannot replay the launch
  branch during blend-out.
- If the torso-only launch finishes without a confirmed contact, the animator
  exposes a detach request instead of snapping the head back. `Player` consumes
  that request, moves the character capsule to the launched head position,
  unequips the body slot, and leaves a simple detached torso marker in the
  world. The animator keeps the player in torso-attack mode until the launched
  skull reaches the future head-only ground position, then requests the actual
  detach. During that miss-fall window, the body stays in player/rig space
  instead of being pinned to a cached world transform. The abandoned torso marker
  is spawned from the player's current `VisualRoot` plus the rig origin before
  the capsule moves to the launched skull. The animator's stored transform is
  only a fallback; marker placement should follow where the player actually
  detached, not a stale pose from a previous location. After the X/Z anchor is
  chosen, `Player` raycasts downward and lifts the marker by half the torso mesh
  height so the abandoned torso rests on the surface instead of floating at
  capsule height. This uses a plain `intended_marker_transform` and applies it
  after the marker is added to the scene, avoiding reads from a temporary
  unparented node's `global_position`.
  That lets head-only movement start at the exact location where the skull
  touched down. The landing uses a short
  `detached_head_landing_duration` with a continuous fall ease and only a small
  fading bounce; head-only rolling is damped by `head_only_roll_speed_scale` so
  the skull does not over-rotate. After the capsule moves to the landed head,
  `enter_detached_head_state()` receives that grounded local position and uses a
  tiny `detached_head_mode_blend_duration` handoff into normal rolling sway,
  avoiding the last ground-level pop. `Player` also carries the camera's
  head-launch offset briefly during the detach handoff, preventing a one-frame
  jump back to torso view. Holding `Interact` near that marker restores only the
  abandoned torso.
- Reattaching the abandoned torso uses the `Interact` hold as the animation
  timeline. `Player` keeps the character root where the skull currently is, then
  `set_detached_head_reattach_tornado_progress()` orbits the skull diagonally
  around the torso marker toward the future head socket. Releasing `Interact`
  before completion calls `cancel_detached_head_reattach_tornado_to_ground()`,
  making the skull fall back to the head-only ground pose instead of restoring
  the torso. Combat/movement input is paused only while the hold animation is
  actively being pressed.
- The tornado target uses the detached torso marker rotation plus the torso
  bone's `head_socket_offset` / `head_origin_offset`, instead of a fixed height.
  When the hold completes, `Player` captures the head's current world position,
  aligns the player rig's stable body pose and yaw to the detached torso marker,
  then reapplies the captured head position before restoring the torso. That
  means normal body animation resumes from the marker instead of moving or
  rotating the body after the head has attached. `play_detached_head_reattach_finish_blend()`
  only blends the head back into the normal full-body pose.
- Reattach only aligns the player root at completion, after the head has reached
  the torso marker. That alignment uses the current detached marker, not cached
  attack data, so the restored body remains in place instead of popping after
  the attachment finishes.
- Enemies use `ProceduralEnemyAnimator`, a thin subclass that keeps player body
  progression disabled. This prevents enemies without player equipment records
  from being treated as head-only bodies.
- Once the torso is equipped, the normal body/head rest pose takes over again.

## Body-part hurtboxes
- `ModularSkeletonRig` now creates one `Area3D` hurtbox per socket:
  `head`, `body`, `right_arm`, `left_arm`, `right_leg`, `left_leg`,
  `right_foot` and `left_foot`.
- Hurtboxes live under the same sockets as the visuals, so procedural animation,
  crawling, rolling head movement and equipped-part scaling all move the boxes
  with the visible body part.
- `set_body_hitbox_owner(owner, group)` labels the same socket boxes for the
  owning actor. Player boxes use `player_body_hurtboxes`; enemy boxes use
  `enemy_body_hurtboxes`.
- Enemy-owned hurtboxes are trimmed with `ENEMY_HITBOX_ACCURACY_SCALE` after
  ownership is assigned, so enemy damage checks hug each body part more tightly
  without shrinking the player's own recovery/progression hurtboxes.
- When a bone is equipped, `equip_bone()` reads `hitbox_size`,
  `hitbox_offset`, `hitbox_scale` and `hitbox_rotation`. If no explicit
  `hitbox_size` is provided, the rig derives the box from the part's visual
  scale and the default limb geometry.
- Player body progression enables only the recovered/equipped body part
  hurtboxes. In the head-only start, only the head hurtbox should receive
  projectile damage.
- Enemies register themselves as the owner of their rig hurtboxes. When limbs
  detach or recover, `Enemy._set_rig_limb_visible()` also disables/enables that
  limb's hurtbox.
- Gorilla proportions now apply custom padded hurtboxes for torso, head, arms,
  legs and feet after the larger limb visuals are created. `Enemy` also widens
  the main collision box for active gorilla profiles, so physical contact and
  body-part damage both match the larger silhouette better.

## Known limitations / TODO
- Socket positions & limb sizes are hand-estimated grey-box values — expect to
  nudge them once seen in a real window.
- Body facing yaw uses `atan2(facing.x, facing.z)`; if the figure faces backwards,
  flip the sign (orientation not verified visually).
- Attack overlay sign (arm forward/back) not visually verified — flip
  `attack_arm_forward` if it thrusts the wrong way.
- Feet are independent of the swinging leg boxes (no knee IK yet, per the brief's
  grey-box rule); on steep slopes there may be a visible leg/foot gap.
- Foot placement done on flat ground + a ramp; steps not added (CharacterBody3D
  needs step-up logic to climb vertical steps).
- Not merged into the real player (Phase G) — do that only after this feels good.
