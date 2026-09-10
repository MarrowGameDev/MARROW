# Marrow — Modular Rig / Procedural Animation notes

Isolated prototype for the "Modular Rigging and Procedural Animation" brief.
**Not wired into the real player yet** (brief Phase G) — test it in `rig_test.tscn` first.

## Live tuning menu (key 4, in game)
`TuningMenuUI` (scripts/tuning_menu_ui.gd, a CanvasLayer in player.tscn) opens
with **4** (Esc or 4 closes; the testing environment's ranged-enemy spawn moved
from 4 to 6 to free the key) and live-edits the most-tuned values without
hunting exports: walk speed (`base_move_speed`, routed through
`recalculate_player_stats()` so bone bonuses keep stacking), step jump height
(`ik_leap_height`), leg forward reach (`ik_stride_reach_boost`), stance
width (`ik_stance_width`), and the whole-body rotation on all three axes
(`whole_body_rotation_deg`, a new animator export applied to the rig node —
zero for enemies, guarded so their transform never dirties). Values are LIVE
only — "Reset to defaults" restores what the scene loaded with; to make a value
permanent, copy it into the export/scene. The mouse is released while the menu
is open and re-captured on close.

## Running spine arch (waist vertical, chest pitched forward)
Author-directed 2026-07-16: *"make the waist be a little more vertical than the
chest so there is an arch, when moving or running."* The spine has two visible
segments: the `body` socket carries the ABDOMEN (the waist region), and its child
`waist_joint` carries the CHEST — so **`waist_joint.rotation.x` IS the
chest-relative-to-waist differential, i.e. the arch**. `run_arch_deg` (20) adds a
steady FORWARD chest pitch through `_waist_target_angle`, scaled by speed_ratio
so it is 0 when idle and grows into the run; the abdomen (`body` socket) stays
vertical because `torso_lean_amount` is 0 on the player. Measured: STAND
waist +13.9° / chest +13.9° (idle guard leans the whole torso together, no arch);
**WALK waist +0.0° / chest +9.8°; RUN waist +0.0° / chest +8.1°** — the chest sits
~8-10° forward of the vertical waist, consistently (never dips back), 0.0% skate.
The old `waist_bend_lean` back-tilt (−0.08, from the superseded "tilt back"
request) is now 0. `ik_leap_pitch_up_deg` was gentled 32→20 so the push-off
bounce no longer swings the chest back past the steady arch — the leap cycle is
preserved, just re-centred forward. `waist_bend_limit` raised 0.35→0.55 rad for
headroom. Gated on the waist joint, so enemies (no waist) are untouched.

## Smooth brake — feet do not fuss when stopping
Author-reported 2026-07-16: *"smooth out the brake on moving forward, feet adjust
too much."* Trace of a stop showed the feet re-centring AFTER the body halted: a
settling step plus the underdamped magnet overshooting the now-still target and
springing back. Two fixes:
- **Settle SLIDE not step** (`_ik_update_steps`): below `ik_idle_settle_speed`
  (0.22) each planted foot gently LERPs its plant toward the idle anchor
  (`ik_idle_settle_rate` 5) instead of the trigger firing a discrete adjustment
  step — the magnet just follows the drifting plant. Settling steps per stop
  3 → 1. The idle step-trigger could then stay loose (0.14).
- **Speed-scaled magnet damping**: the moving spring is underdamped (bouncy,
  `ik_magnet_damping` 20) which OVERSHOT the stopped target. `_ik_magnet_foot`
  now blends toward `ik_magnet_damping_idle` (46, ~critical) as speed_ratio
  falls, so the stop settles without oscillation while the walk keeps its bounce.
Measured: brake post-stop peak foot-move 0.034 → 0.020-0.024, overshoot
direction-reversals → 0, walk bounce preserved (0.077), walk skate still 0%.

**Direction changes** (author follow-up "fix the change in direction in feet")
whip the foot targets to the new heading; the feet chased at ~2× normal speed
(reverse 0.152, 90-turn 0.140 vs steady 0.094). Two more pieces:
- A **transition detector** (`_ik_transition`): the magnet damping now blends to
  critical when the move velocity CHANGES sharply (brake, turn, reversal — not
  just when slow), spiking on the change and decaying over the catch-up
  (`ik_magnet_transition_thresh`/`_decay`). Kills overshoot in all three.
- A **foot-speed ceiling** (`ik_foot_max_speed` 6 m/s) on the magnet velocity: a
  whipped target can no longer snap the foot — it slides over at a walk-step pace.
  A normal swing sits under the cap, so it is untouched.
Measured after: reverse/turn peak 0.15/0.14 → **0.10** (≈ the 0.094 steady step),
steady walk unchanged, no non-finite.

## Standing feet sit under the (tilted) body, biased behind the hips
Author-reported 2026-07-16, in two passes: first *"feet are set a little more
forward than the body when standing"*, then — after pulling them to under the hip
POINTS — *"they still have to be set a little more behind ... because of the
tiltation of the body ... so it makes the perspective of being under the body."*
The insight: the socket ORIGINS all sit at z≈0, but the torso's forward tilt
shifts the visible MESH forward, so feet under the hip points read as forward of
the body. `idle_foot_forward` (**−0.10**) is the standing +Z foot offset, negative
= behind the hips to sit under the leaning mass; `_ik_anchor_world` blends it to the socket's
natural offset with speed (`lerpf(idle_foot_forward, rest_foot.z, stance_engage)`),
so moving is unchanged. The step trigger also TIGHTENS at idle
(`lerpf(0.05, ik_step_trigger, ...)`) — the stride's 0.18 m deadzone would leave a
stopped foot resting up to that far forward of the pulled-back anchor, so without
it the feet never fully settle. Measured: fresh stand −0.102 m vs hip (behind); three walk-then-stop cycles
settle to −0.07..−0.09 (the idle trigger deadzone); leg extension 89%; walking
stride (−0.36..+0.23) and 0.0% skate preserved. The bias is one tunable knob
(idle_foot_forward) — toward 0 for feet under the hip points, more negative for
further back.

## Bug sweep (2026-07-18) — found & fixed
Author-requested "check for bugs" over the recent magnet-gait / altitude work.
- **SETTLE-SLIDE broke altitude** (`_ik_update_steps`): the idle settle-slide
  lerped the WHOLE plant toward `_ik_anchor_world`, whose Y is a rig-rest height
  not the probed ground — it sank standing feet ~8 mm on flat ground and would
  pull them to the wrong altitude on a slope/step. Fixed to slide XZ only, keeping
  each plant's own ground Y. Measured: stand foot Y −0.008 → ~0.
- **MAGNET re-seeded at the plant on IK activation** (`_ik_reset_plants`),
  snapping the leg to the plant in one frame when the IK turned on from a
  different pose (the head-only→full transition when the legs are equipped).
  Fixed to seed at the foot socket's CURRENT world position so the magnet springs
  in at the capped speed. Measured: activation foot move 0.56 → 0.10.
Ruled out (verified, not bugs): a fresh player is HEAD-ONLY by design (only the
head equipped), so `_ik_active()` is correctly false until a body+legs are
equipped through progression — the gait runs only on the fully-equipped player.
Idle-stance/arch are bit-clean when disabled (chest 0.0°, waist 0.4°). No NaN
through a 0.5 s delta spike or a 1200-frame speed/turn/jump run. The foot-speed
cap sits right at the sprint swing speed (6.0 m/s) but feet still converge — raise
`ik_foot_max_speed` if sprint ever feels throttled.

## Per-foot altitude / uneven ground (was crashing)
Author-directed 2026-07-18: *"fix the altitude offset — each foot has a different
target; if either foot's target is at a different altitude, account for it."* The
whole uneven-ground path had never actually run: the foot-to-ground-normal
alignment in `_ik_solve_leg` built a degenerate/non-rotation Basis whenever the
spherecast returned a non-vertical normal (a step EDGE or ledge returns the
vertical FACE normal), which crashed `get_quaternion` in the slerp — only ever
hit off flat ground. Fixes:
- **Reject non-walkable normals** (`up.y < 0.5` → keep the foot level) so a step
  face never feeds the basis.
- **Re-derive the basis orthonormal** (forward = right×up, `.orthonormalized()`)
  and slerp on the rotation QUATERNION preserving the foot's scale — a hair of
  float non-orthogonality or a chain scale can no longer make it a non-rotation.
Altitude itself was already correct once it stopped crashing: each foot probes
its OWN ground (`_ik_probe_ground` per foot at step time), the magnet springs to
that per-foot plant, the foot tilts to the ground normal, and the pelvis rides
the AVERAGE foot Y (`_ik_update_pelvis`), with the capsule owning the gross climb.
Verified: standing straddling a 0.12 m lateral step each foot reaches its ground
(±0.01 m) and the pelvis rises 0.10 m; walking up an 8° ramp the character climbs
0.77 m, feet track the slope and tilt to it (~9° ≈ the ramp), 0 non-finite. Note
the foot-speed cap makes a foot lag briefly when stepping UP a slope (max ~0.19 m
transient) — raise `ik_foot_max_speed` if that reads badly on steep terrain.

## Cartoon MAGNET feet (jump-like walk)
Author-directed 2026-07-16: *"make a jump like / walk animation. set the targets
for the foot (the foot must touch the target) but it works more like a magnet
than a fix point. cartoonish look."* This is a MODE switch (`ik_foot_magnet`,
default on) in the foot-IK solve, replacing the rigid-plant + skate-guard with a
spring.

- **`_ik_magnet_foot`**: each foot is a semi-implicit spring (`ik_magnet_stiffness`
  500, `ik_magnet_damping` 20 → underdamped, bouncy) chasing its target
  (`_ik_foot_world` = plant or swing arc). It CONVERGES to a still, in-range
  target — a planted foot touches the ground and holds (measured stand foot y
  0.001) — but LAGS and overshoots in motion: the loose cartoon foot.
- **The reach shortfall became the look, not a bug**: after the spring, the foot
  is clamped to the leg's reach (only the outward velocity is killed, so it slides
  along the reach sphere toward the target). An out-of-reach target leaves the
  foot STRETCHED to the limit reaching for it — never a dragged plant. Measured
  skate **0.0%** at walk and sprint (the whole skate saga is moot in this mode).
- **This unlocked tall, extended legs**: with no skate to fear, `ik_hip_drop_moving`
  dropped to 0.05 (near-zero crouch) — planted-leg extension **90%→98%**, which
  also answers the earlier "extend the legs more".
- **Cartoon tuning**: `ik_leap_height` 0.10 (body bounce ~0.09; THIS is the
  jump-vs-walk dial — 0.18 → 10% ground contact/very hoppy, 0.08 → 29%/grounded),
  `ik_step_height` 0.20 (high 0.22 m foot lift). Magnet stiffness/damping are the
  looseness dial (lower damping = bouncier).
- Idle, jumps, enemies unaffected (gated inside the split-player IK path; magnet
  seeds at the plant on reset, falls back to `target` on any non-finite).
- Set `ik_foot_magnet=false` to restore the rigid-plant realistic gait.

## Idle combat stance

## Idle combat stance (key: standing still is a READY pose)
Author-directed 2026-07-16: *"the still stance has to be legs spread, the chest,
not the waist, the chest leaning forward and moving slightly to simulate
breathing, and both arms in a ready to fight pose guard down."* This SUPERSEDES
the earlier "feet under the hips so the character stands normally" — standing is
now a fighting stance, not a neutral stand. `_apply_idle_stance()`, all of it
faded by `_idle_stance_blend()` = `1 - speed_ratio*2.5` and gated on
`_ik_active()`, so it is the split player only and every enemy / head-only /
torso / crawl / demo mode stays bit-identical.

- **Legs spread**: `idle_stance_width` (0.10) is blended against the moving
  `ik_stance_width` (0.08) inside `_ik_anchor_world` — the anchor re-aims with
  speed, the old plants exceed `ik_step_trigger`, and the feet re-settle on their
  own. Measured (after a 2026-07-16 "feet a little more under the body" pull-in that
  took idle_stance_width 0.10→0.05 and ik_stance_width 0.08→0.04): **0.333 m
  standing, 0.305 walking** (hips are 0.24 apart) — still a slight athletic
  spread, closer to under the body; 0.0% skate (narrower = less lateral reach).
- **CHEST, not the waist**: the author was explicit, so the lean rides the `body`
  socket's own rotation (`idle_chest_lean_deg` 14) and the waist joint is left to
  the gait. Measured: **chest +14.0°, waist −0.1°**.
- **Breathing**: `idle_chest_breath_deg` (2.2) oscillates the chest LEAN rather
  than bobbing it, so the ribcage swells and settles. Measured: chest pitch
  cycles **11.8°..16.2°**.
- **Guard down**: shoulders forward (`idle_guard_arm_raise_deg` 42) and tucked in
  (`idle_guard_arm_tuck_deg` 13 — note the +Z-forward handedness flips the roll
  sign per side), elbows folded up (`idle_guard_elbow_deg` 68). Measured: arms
  +43°/+40°, both elbows −75°.
- **ORDER**: runs after `_animate_limbs`/`_animate_joints` (so it overrides the
  idle rest pose) but BEFORE the attack/aim overlays, which must stay free to
  take the arms. Verified: an attack from the guard sweeps the arm 85.7° away
  (−21.6°..64.1°) and the guard restores afterwards.

## How to test
Open `scenes/rig_test.tscn` in Godot and run it (F6 / "Run Current Scene").

- **WASD** — move. Body bobs, torso leans, arms/legs swing, and the whole figure
  turns smoothly toward the movement direction. Standing still = subtle idle breathing.
- **Attack** — cycles simple combo poses: right-arm strike, left-arm strike,
  then a heavier two-arm/torso finisher.
- **Q** — cycles equipping **Arm → Leg → Heavy** into their slots. The grey limb is
  swapped for a bone-colored one; Heavy is bigger (visual_scale) and heavier.
- Walk **forward onto the ramp** (in front of spawn) to see the foot IK (see
  "Foot IK locomotion" below): feet plant in world space and the legs solve to
  reach them. Only the split player rig has the knee socket this needs.

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
- The old `foot_placement_enabled` planter (which assigned `foot.position` in the
  ROTATING knee's space) is **deleted** — replaced by the foot IK below.

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
attack_torso_twist 0.35. Foot IK exports are in the "Foot IK locomotion" section
above (the old `foot_*` raycast planter has been deleted).
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
- Not merged into the real player (Phase G) — do that only after this feels good.

## Foot IK locomotion (2026-07-15)

Replaces the dead `foot_placement_enabled` planter. **Inverts the leg chain from
FK to IK**: the walk cycle used to rotate the hip and drag the foot along; now the
foot is planted in WORLD space and the hip+knee rotations are *solved* to reach it.
Lives entirely in `procedural_player_animator.gd` (`_update_foot_ik` and the
`_ik_*` helpers); the FK writers for the arms are untouched.

- **Scripts touched:** `scripts/rig/procedural_player_animator.gd` only.
- **New behaviour:** feet stay pinned to the ground in world space while the body
  moves/turns; each foot steps to a spherecast-probed ground point when it drifts
  past `ik_step_trigger`; legs strictly alternate (one airborne at a time); the
  pelvis (and everything a real pelvis would carry) rides the average foot height.
- **Gate — `_ik_active()`.** On only when `ik_feet_enabled` (default true) AND the
  rig has a waist joint (split player only) AND not head-only / torso-spring /
  crawl / demo. Every enemy is unsplit → no waist → **IK never runs**, so their
  FK/crawl/lizard-climb paths are bit-identical. Same for the head-only and
  torso-only player states. Verified headless: `_ik_active()==false` and
  `_ik_pelvis_dy==0` for the default (head-only) player and for `enemy.tscn`.
- **Proportion-agnostic.** Leg lengths, the ankle rest tilt (`knee_rest`, ~12.5°
  forward — the rest shin is NOT collinear with the thigh, so `knee.rotation.x=0`
  is a slightly broken knee and +X straightens before it bends) and the pelvis
  baseline are all read from the captured rest pose, never from `SOCKET_LAYOUT`.
  A gorilla (0.44 leg) or lizard (0.40) would solve correctly the day it is split.
- **The swing cycle (author-directed, 2026-07-15).** A step is shaped, not a
  symmetric hop: the LIFT peaks early (`sin(pow(t,0.7)*PI)`) and the forward travel
  is back-loaded (`pow(t,1.6)`), so the foot lifts with the knee coming forward and
  UP first, then EXTENDS down-and-forward to plant. Measured knee flexion over a
  walk: ~24°..92°. The hips also lean forward into the move (`ik_run_lean`, +Z is
  forward) so the reach reads as "the feet pull the body along," not the hips.
  `ik_step_height` 0.14 drives how high the knee lifts — drop it if the walk reads
  too marchy.
- **The body's motion comes from the feet (author-directed, 2026-07-15; took
  three iterations, each killed by a measurement).** The capsule glides at
  constant speed, so a rig glued to it reads hip-led no matter what the legs do —
  measured: body world speed dead-flat at capsule speed. What finally works is a
  composed system; removing any one part collapses back to a glide:
  1. **The pelvis rides the feet horizontally** (the other half of "use average
     feet position for body position"), applied RAW — a filtered/high-passed pulse
     was tried first and its ±4 cm was invisible.
  2. **Swing-weighting** (`ik_step_drive`): an even mean of two alternating feet
     moves at exactly capsule speed by construction — zero read. Weighting the
     stepping foot makes the body load back as the knee lifts and get dragged
     forward by the extending leg.
  3. **Cadence coupled to speed** (`_ik_step_duration_now` = `ik_step_reach` /
     speed): with a fixed duration the capsule advances further per step than the
     leg can stride (~0.24 m), so the plants trail permanently, the raw offset
     saturates any clamp, and the sprint skated ~196% of its path. Duration =
     reach/speed keeps each step's travel expressible. Side effect: this KILLED
     the sprint skate (196% → 2.1%).
  4. **Plants straddle the capsule** (`ik_stride_lead`, in units of one step's
     capsule travel; the anchor itself moves one travel during the swing, so 1.5
     lands ~half a stride ahead): centred plants give the raw offset (near) zero
     steady component, so `ik_body_follow_recenter` is only a very slow safety
     bleed, not a signal filter.
  Measured after: body world speed **0.07..5.04 m/s around a 2.5 m/s capsule**
  (the body stops between steps and doubles the capsule at each surge; was
  2.50..2.50 flat), 2.18..10.14 at 6 m/s; true skate 0.0% at 2.5 m/s, 2.1% at 6;
  follow DC ≈ 0 at all speeds; circles and 1 s reversals bounded (|follow| ≤ 0.33
  vs the 0.45 clamp), plants pinned to ground throughout.
- **Longer strides, slower feet (author-directed, 2026-07-16).** Because cadence
  is `ik_step_reach / speed`, raising the reach IS the slow-the-feet knob — but
  the standing envelope caps the stride at ~0.24 m (hip 0.534 m up, leg 0.587 m).
  Three mechanisms buy the rest, each earned by a measured failure:
  1. **Stride dip** (`ik_stride_dip` 0.10): pure leg-triangle geometry —
     `dy ≤ sqrt(L² − spread²) − span` — the pelvis gives vertically only when a
     leg's spread would put its plant out of reach, and releases between strides.
     Envelope table: dip 0 → 0.24 m, 0.04 → 0.31, 0.08 → 0.37, 0.12 → 0.41.
  2. **Asymmetric dip response** (drop at 3× `ik_pelvis_response`, rise at 0.8×):
     a symmetric τ≈0.1 s arrives after the skate guard has already dragged the
     plant — measured 9.5% skate at 2.5 m/s from lag alone.
  3. **Anticipatory spread + hysteresis**: the dip estimator measures against
     THIS frame's follow (where the hips are heading — at each step handoff the
     weights snap and a one-frame-behind estimator under-dips exactly when the
     leading leg is longest), and uses leg×0.96 vs the guard's 0.99 so the pelvis
     arrives below the drag threshold, not exactly at it.
  Reach sweep (skate % at 1.5/2.5/6.0 m/s, all mechanisms in): 0.28 → 1.0/0.0/5.6;
  **0.32 → 0.0/0.5/3.6 (chosen)**; 0.34 → 0.4/2.9/3.8; 0.40 → 7.3/10.0/3.4.
  Net vs the original 0.24: **feet step ~53% slower with ~33% longer strides**
  (0.147 vs 0.096 s/step at 2.5 m/s). The 6 m/s residual is the
  `ik_step_duration_min` floor, identical at every reach.
  Adversarial review verified the dip is feedforward (no limit cycle — the bob is
  step-synchronized and decaying), ramp-safe both directions, and NaN-free.
- **Swing overlap — the smooth-vs-grounded knob (author-directed, 2026-07-16:
  "feet look like near teleportation").** Strict one-foot-at-a-time forced every
  swing to fit inside stride/speed: 8 frames at a walk, 4 at a sprint. With
  `ik_step_overlap`, the next swing launches while the previous is landing
  (launch order still strictly alternating), stretching every swing's airtime by
  1/(1−overlap) at the same ground coverage — the cadence formula divides by the
  LAUNCH interval, and so does the stride lead. THE BUG THAT ATE THE FIRST
  ATTEMPT: the lead scaled by swing duration (which overlap had just stretched
  54%), throwing every plant ~50% too far ahead — metre-long swings, no
  smoothness gain, and all of the low-speed skate. Lead must scale by
  duration×(1−overlap). Two arc fixes ride along: forward travel eases OUT into
  the plant (pow(t,1.6) peaked foot speed at the landing frame), and the lift is
  eased through smoothstep first (pow(t,0.7) alone has infinite slope at t=0 —
  a ~7 cm first-frame pop). Measured at 2.5 m/s (tele = max foot movement per
  frame): old gait 0.142 m, overlap 0.15 → 0.124, **0.25 → 0.108 (default)**,
  0.35 → 0.095 but both feet airborne 49% of the time and the body surge
  flattens (1.7..3.9 vs 1.0..4.5 at 0.25). Bonus: the lead fix + overlap lifting
  sprint duration off its floor removed ALL remaining skate — 0.00% at every
  speed tested, sprint included (was 3.6%).
- **The leap gait (author-directed, 2026-07-16, twice).** First cut was a
  two-feet BOUND (both feet push off together — it halves rel-to-body foot
  speed, tele 0.074 at 2.5 m/s), but the author corrected it: *"still have the
  feet move one after the other. the jump its not meant to be a two feet
  jump."* So the shipped gait keeps the strictly alternating stepper (overlap
  0.35, swings 0.197 s at 2.5 m/s, tele 0.094) and layers a per-stride LEAP on
  top, driven by the foot CLOSEST to touchdown (keying on the newest swing
  instead played the chest's landing compression before every touchdown —
  measured, wrong):
  - `_ik_leap_lift`: ballistic pelvis parabola over each swing (`ik_leap_height`
    0.05), applied through `_ik_pelvis_offset`. The stride-dip estimator
    subtracts the lift — it eats leg reach, and without that the planted foot
    skated 13% of the path (measured; 0.00% with it).
  - `_ik_leap_pitch`: the chest pitches UP at push-off (`ik_leap_pitch_up_deg`
    25) and COMPRESSES through to slightly down (`ik_leap_pitch_down_deg` 7) as
    the foot touches — "chest and waist compress". Rides the waist joint (added
    to `_animate_waist`'s bend, so `_apply_waist_carry` moves head/arms with
    it), exactly 0 whenever the IK is inactive — special modes stay
    bit-identical. Both outputs are SMOOTHED (`ik_leap_pitch_response` 14): the
    max-t driver is a sawtooth at swing handoffs, and at ~4 steps/s the full
    ±sweep would bobblehead — realized range at 2.5 m/s is a held-up chest
    (mean ≈ −7°) nodding ~8° into each landing; the full range emerges at
    slower cadences. Raise the response for a snappier sweep.
  - Jump landings are a CATCH, not a snap: `_ik_land_plants` turns each foot
    into a normal step from wherever the fall left it down to the probed
    ground (a straight snap dropped the sockets 0.44 m in one frame —
    adversarial review, measured; the catch's worst frame is 0.025 m).
  The two bound-only defects the adversarial review found (reversal landing
  teleport, walk→bound adoption pop) were removed along with the bound itself.
  Known remaining: an instant 180° reversal at speed produces one catch-up
  swing of up to ~0.27 m/frame — inherent to plant-ahead stepping under
  un-ramped velocity flips.
- **The walking speed was the real ceiling (author-directed, 2026-07-16: "if
  needed, have the character's overall walking speed lower").** `base_move_speed`
  was 6.0 with sprint ×1.55 = 9.3 — proportionally absurd for a 0.92 m skeleton
  (a human walks 1.4 m/s at twice the height), and it pinned the foot IK in its
  scurry zone during ALL normal play: speed IS foot speed when the legs can only
  express a 0.32 m stride. Lowered to **2.6 (sprint 4.03)** in player.gd.
  Measured at the new in-game speeds: walk tele 0.103 (was 0.258 at the old
  walk), swings 0.189 s (was 0.082), full leap cycle with a visible ~7 cm hop
  (`ik_leap_height` 0.08) and chest nod; sprint tele 0.153, skate 0.04%. The
  flat `player_stats.move_speed` bone bonuses in bone_data_catalog.gd were
  rescaled ×0.43 (3.0→1.3, −1.5→−0.65, 1.5→0.65) to keep their
  percent-of-base design; enemy_stats speeds untouched.
  Follow-up (author-directed, same day: "higher jumps so feet make a smoother
  move"): `ik_leap_height` 0.08→0.13, `ik_step_overlap` 0.35→0.45,
  `ik_stride_dip` 0.13→0.16. The higher jump and the extra overlap are one
  mechanism: with more airtime per stride the next swing launches earlier, the
  feet ride the jump instead of racing around a planted twin, and swings get
  1.8× strict-alternation airtime. Measured at play speeds: walk tele 0.087
  (swing 0.224 s, realized hop 0.107 m), sprint tele 0.129 / 0.00% skate, jump
  catch 0.025, strict LRLR order. Trade accepted: stances become brief
  touch-and-go contacts, so the stall-surge pulse narrows (1.98..3.51 at walk).
  Second follow-up ("torso tilt back more, feet slower via higher jumps"):
  `ik_leap_height` 0.13→0.18 (realized hop 0.149 m), `ik_step_overlap`
  0.45→**0.5 — the zero-stance limit**: each foot relaunches the moment it
  lands, a foot averages exactly ground speed during a swing, the mathematical
  floor for an alternating gait. The swing's velocity profile became a
  back-loaded TRAPEZOID (`_swing_forward_curve`, ease 25/cruise/ease 18 — peak
  ~1.27× average vs ~1.6× for an eased hump). The back-tilt is three pieces:
  `waist_bend_lean` +0.10→**−0.08** (the walk lean now tilts BACK),
  `ik_leap_pitch_up_deg` 32 / `down_deg` 0 (the cycle settles to level, never
  forward), and `torso_lean_amount = 0.0` overridden on the PLAYER instance in
  player.tscn (the shared default 0.14 stays for enemies — it was adding 8°
  forward that ate half the tilt). Measured: **net chest pitch −19..−11° back**
  through the walk cycle, walk tele 0.064 (started at 0.258 — 4× smoother),
  sprint tele 0.096, skate 0.00% both speeds, jump catch 0.021. **BALANCE FLAG: enemy
  chase/flee speeds were tuned against a 6.0 player and are now relatively
  ~2.3× faster — they likely need their own pass.** `ik_stride_dip` raised to
  0.16 (full-ratio posture + leap lift both draw on the dip budget). Residual
  walk skate 1.8% — millimetre-scale drags, visually negligible.
- **Less crouch / normal-walking look (author-directed 2026-07-16: "legs not
  crouch as much when moving, simulate normal walking").** The unlock was the
  LEAP: `ik_leap_height` (0.10) lifted the hips each step, stealing reach from the
  planted foot, which forced the crouch to avoid skate. Halving it (**0.05**) freed
  that reach, so the crouch could ease (`ik_hip_drop_moving` 0.17→**0.12**) and the
  stride shrink a touch (`ik_step_reach` 0.36→**0.34**, `ik_stride_dip` 0.10→0.14)
  WITHOUT adding skate. Measured: walk knee **89%→91% avg, deepest bend 74%→79%**
  (visibly straighter), hipY 0.447→0.461 (−4 cm from the 0.500 stand vs −5.4 cm
  before), hop flatter, skate 3.5% (was 3.7%), 2.64 steps/m, sprint skate 0.9%.
  A fully upright walk is still not reachable: with the stride kept ≥⅓ m for the
  3-steps/m cap, a 0.59 m leg must bend to plant it — going straighter means a
  smaller stride (more steps/m, past the cap) or accepting skate. Tried and
  rejected: a purely DYNAMIC crouch (tiny constant drop, big reach-driven dip)
  straightened the legs to 95% but the smoothed dip lagged the plant → 11-15%
  skate.

- **Raise the hips when walking + more airtime (author-directed 2026-07-16:
  "raise the hips more ... feet feel staggered with very little room ... to
  maintain smoothness just give more airtime").** A HIP-HEIGHT vs SKATE trade,
  and a tight one: with the stride fixed by the 3-steps/m cap, the planted legs
  are already near their reach limit, so raising the hips straightens them into
  a drag. Measured: `ik_hip_drop_moving` 0.20→hipY 0.428/0.3% skate,
  **0.17→0.447 (+2 cm)/3.7%**, 0.15→0.458 (+3 cm)/5.7%. Chose 0.17 (visible
  raise, skate still low). Reducing the stride to raise them more breaks the
  cap; reducing the stride LEAD made it WORSE (the foot then only trails back,
  further from the hip) — the straddle lead is optimal. The airtime is
  `ik_step_overlap` 0.30→0.40 and `ik_step_duration` 0.42→0.48: swing-foot speed
  2.64→2.29 m/s, tele 0.095→0.081, planted 33%→25% (still a real stance),
  2.50 steps/m, sprint skate 0.7%. The ~2-3 cm hip ceiling is inherent to a
  0.59 m leg with a stride this size — the only way past it is a smaller stride
  (more steps/m) or a longer leg.

- **Slower feet, take 4 (author-reported "legs still moving too fast", 2026-07-16).**
  With the 3-steps/m cap the stride can't shrink, so the levers are walk speed and
  swing airtime. Raising `ik_step_duration` (0.32→0.42) is the enabler: it lets a
  SLOWER walk keep its cadence under the cap instead of the duration-ceiling forcing
  extra steps. `base_move_speed` 2.0→**1.4** (sprint 2.17), bone speed bonuses
  rescaled ×0.7. Measured: swing-foot speed **3.75→2.64 m/s (−29%)**, tele
  0.134→0.095, while the stance holds (33% planted) and cadence stays legal
  (2.57 steps/m walk, 2.58 sprint), 0.3% skate. Slowest levers if still too fast:
  drop speed toward 1.2 with `ik_step_duration`→0.50 (measured 2.25 m/s swing, still
  ~2.6 steps/m and 32% planted), or raise `ik_step_overlap` for more airtime at the
  cost of stance.

- **THE STANCE FIX — the gait had no ground contact at all (author-reported
  2026-07-16: "legs still kind of teleporting… is the back leg able to be behind
  the hip when the hip moves forward?").** That question exposed the real bug.
  Measured: **right foot PLANTED 0% of frames, BOTH feet airborne 100%** — at
  `ik_step_overlap` 0.5 each foot relaunches the instant it lands, so the figure
  never planted anything; it cycled its legs in the air. Every "0.0% skate" win
  reported before this was VACUOUS — there were no planted frames to skate. Two
  root causes, both now fixed:
  1. LAUNCH SPIKE. `sin(pow(t,0.8)*PI)` in the reach boost: an exponent BELOW 1
     has an INFINITE derivative at t=0, so the reach snapped on ~0.12 m in ONE
     frame at every swing start (traced: arcMove 0.133 at t≈0.05 = 3x body speed,
     decaying to 0.011 — a spike, not sustained speed). Exactly the old
     `pow(t,0.7)` lift trap, reintroduced. Fixed with a smoothstep feed and an
     exponent ABOVE 1: `sin(pow(smoothstep(0,1,t),1.3)*PI)` — smooth at both ends
     AND peaks late (~0.55) as originally intended (0.8 actually peaked EARLY, at
     0.42; the comment claiming otherwise was wrong).
  2. NO STANCE. Overlap 0.5 → 0.3, so each foot is planted ~33% of its cycle and
     the body rides over it. This instantly exposed 35%+ skate, which led to:
- **THE CROUCH — why a jumping gait needs bent legs.** Pure geometry: a planted
  foot 0.36 m from its hip on a 0.587 m leg requires the hip BELOW 0.455 m
  (`sqrt(0.36² + h²) ≤ 0.58`), but a straight-legged rig stands at 0.53 and the
  leap lift pushed it higher still — so every planted frame the foot was out of
  reach and got dragged. **You cannot raise the pelvis 0.18 m while a foot is
  planted far from the hip on a leg with no bend.** Real legs solve it by being
  bent: crouch, then extend the planted leg to push off. New
  `ik_hip_drop_moving` (0.20) vs `ik_hip_drop` (0.05), blended by
  `_ik_hip_drop_now()` on the same speed ramp as the stance width — so standing
  stays TALL and straight-legged (author's "stands normally") and the crouch only
  engages to walk. Sweep at walk: hip_drop 0.05→0.20 took skate 35%→3% and the
  planted knee from 99% to ~62% extension (real bend, reserve to push with).
  Jump-height sweep at the crouch: leap 0.06→3.8%, **0.10→5.7%**, 0.14→14.4%,
  0.18→22% skate — 0.10 is the most jump the leg reserve affords.
  Final config (walk 2.0 / sprint 3.1): **2.55 steps/m, 33% planted, back foot
  0.33 m BEHIND its hip, forward reach +0.28, tele 0.135 (was 0.226), skate
  0.0%, knee 75%, jump-catch 0.021**; standing bodyY 0.846 at 87% leg extension,
  stance 0.243 (under hips), returning to 0.873 after stopping. `base_move_speed`
  2.6→**2.0**: slower is strictly better here — it lengthens the swing, so it cut
  tele AND raised forward reach at once. Bone speed bonuses rescaled ×0.77 to hold
  their percent-of-base.
- **Bigger, wider steps (author-directed 2026-07-16: "maximum three steps per
  metre; legs well separated / good distance between them; target points not
  under the hips").** NOTE: the 0.42 reach / 0.12 stance / 0.22 dip tuned here
  were re-swept by the stance fix above (0.36 / 0.08 / 0.10) — the numbers below
  describe the method, the values above are what ships. Two coordinated changes, both measured:
  1. STEPS/METRE cap. Steps/metre ≈ 1/`ik_step_reach` (each launch interval
     covers `ik_step_reach` of ground). 0.32 measured 2.81/m — just under the
     cap. Raised to **0.42** → **2.35/m walk, 2.13/m sprint**, a comfortable
     margin under 3, with bigger strides. `ik_stride_dip` 0.16→**0.22** pays the
     extra leg reach the longer stride demands (skate stayed 0.0%).
  2. STANCE WIDTH. The anchor planted each foot directly under its hip (±0.12),
     a narrow 0.24 m stance. New `ik_stance_width` (0.12) pushes each target
     OUTBOARD along its own hip's side (right_leg at +X, left at −X via
     `signf(leg_rest.x)`), so feet plant **0.46 m apart** while moving. It costs
     leg reach (foot farther from hip laterally), which the same dip covers.
     MOVEMENT-GATED (author-directed: "when standing still the targets have to be
     under the hips so the character stands normally"): the width scales by
     `clampf(speed_ratio * 2.5, 0, 1)` — the same quick ramp the leap uses — so
     it is 0 at a standstill and full once past ~40% of walk speed. No extra
     state was needed for the settle: when the player stops, the anchor narrows,
     the wide plants exceed `ik_step_trigger` on their own, and the feet take a
     natural little step inward. Measured: fresh stand 0.243 m (= hip width),
     walking 0.459 m, settles back under the hips 0.63 s after stopping, then
     dead still (0.0000 m/frame foot movement, no oscillation).
  Measured after, walk+sprint: 0.0% skate, 99% extension, no collapse, no
  non-finite, idle feet wide-and-still, jump-catch 0.020, reversals bounded.
  Cost of the bigger stride: the pelvis dips ~0.20 m mid-stride (weight
  transfer) to keep the wide/long plants reachable — a pronounced athletic bob,
  the honest price of big steps on a 0.59 m leg. `ik_stance_width` is a live
  slider ("Stance width") in the tuning menu; `ik_step_reach` stays an export
  (it is the steps/metre constraint, not a feel dial).
- **Forward leg reach — the swing overshoots ahead (author-directed
  2026-07-16: "exaggerate the extension of the legs when moving forward, really
  noticeable").** Baseline measurement exposed the real gap: the foot **never
  reached ahead of its hip** (max +0.00 m), it planted under the hip and only
  trailed back to −0.30 — legs read as dragging, never reaching. The obvious
  levers all failed: bigger `ik_stride_lead` throws the plant past leg reach so
  it clamps and the stride COLLAPSES over ~10 s (span 0.24→0.08, pelvis crouches
  0.37 m — a short probe misses it, a 600-frame one catches it); bigger
  `ik_step_reach` sends the foot further BEHIND. Both move where the foot
  *plants*, which must stay stable. The fix moves the *swing arc* instead:
  `ik_stride_reach_boost` (0.42) bulges the airborne foot forward along the
  rig's facing, peaking just after mid-swing (`sin(pow(t,0.8)*PI)`) so the leg
  is at full forward extension on the way down into the plant, scaled by
  speed_ratio (inert standing) and zero at both swing ends. The PLANT is
  untouched, so it costs no skate and cannot collapse the stride — the reach is
  a pure mid-air flourish, which is also how a real reaching stride works (the
  foot overreaches, then draws back to contact). Measured, foot-ahead-of-hip:
  boost 0→+0.00, 0.20→+0.07, 0.34→+0.20, **0.42→+0.25 (default)**, 0.48→+0.33 —
  and skate stayed 2.7% at 0.42 / 0.0% at sprint (baseline was worse), span
  healthy, idle inert, jump-catch 0.03, reversals bounded. Exposed as a live
  slider ("Leg forward reach") in the F3/key-4 tuning menu.
- **The jump-height knob was cancelling itself (author-reported "step jump
  doesn't do anything", fixed 2026-07-16).** The stride-dip estimator subtracted
  `_ik_leap_lift` for EVERY foot each frame, so raising the jump dipped the
  pelvis by the same amount — net body-Y barely moved, and what did move was
  drowned in up to 27% skate. Three coupled fixes so the knob has real,
  measured authority now:
  1. The dip clause skips IN-FLIGHT feet (`_ik_step_t < 1.0`) — a swinging foot
     that can't reach its arc just clamps in the solve (a tucked leg under a
     jump), it is not what the skate guard drags. Only PLANTED feet still
     subtract the lift.
  2. `_ik_snap_dip_for_landing()` fires on the plant event: the smoothed lift
     lags its zero-at-touchdown target, so a still-high pelvis would hand the
     fresh plant to the skate guard; snapping the dip down at the landing is the
     compression thud and keeps the foot reachable on the frame it lands.
  3. The lift target tapers to 0 over t∈[0.72,0.96] (`1 - smoothstep`), so the
     smoothed lift is already low before touchdown instead of lagging high into
     it.
  Measured, body-Y jump amplitude vs `ik_leap_height` at walk 2.6: 0.05→0.067,
  0.12→0.103, 0.18→0.192, 0.24→0.274, 0.30→0.295 — a 4.4× span the slider now
  visibly drives (was a compressed 1.6× buried in skate). Cost: the taller the
  jump the more per-frame foot travel (tele 0.064 at 0.12, 0.195 at 0.18) and a
  little skate returns (3–4.6% above ~0.18) — inherent, the foot arcs higher in
  the same swing time. So `ik_leap_height` is now the smooth-vs-jumpy dial
  itself: low = smoothest feet, high = bigger hop. Jump-catch landing 0.021,
  unchanged.
- **Landing re-grounds the plants (found by adversarial review, fixed
  2026-07-16).** The airborne hang leaves each plant ~v/14 m above the floor at
  touchdown, and nothing else restores plant Y — steps fire on XZ error alone, so
  a standing landing never steps and the skeleton stood on air indefinitely
  (measured: both feet 0.23 m up, forever, after a 5 m/s fall; running landings
  dragged a floating foot ~0.9 m behind for ~0.27 s). `_ik_land_plants()` runs on
  the airborne→grounded edge: keeps the hang XZ (the feet gathered under the hips
  during the fall — that is a landing pose) and probes Y/normal down to the ground
  actually under each foot. Measured after: worst |plant y| after landing 0.0000
  in both scenarios.
- **The carry's frame invariant (found by adversarial review, fixed).** The pelvis
  carry `+=`s six sockets and NEEDS their positions re-assigned from rest earlier
  in the same frame or it compounds. The wobble's position assign is that reset;
  with `wobble_enabled` off (it is an exported tunable) nothing wrote the four limb
  sockets and the carry sent an arm 202 m off the rig in 10 s. `_update_foot_ik`
  now re-bases the four limb sockets itself when the wobble is off (measured after:
  worst drift 0.29 m = the bounded offset, over the same 600 frames).
- **THE LOAD-BEARING CONSTRAINT — the leg is too short for the game's run speed.**
  Standing, the leg rests at 99.9% extension (hip→ankle 0.586 m vs 0.587 m reach):
  ~0.5 mm of slack. `ik_hip_drop` (0.05 m after the author asked to reduce the
  crouch) lowers the pelvis a little to buy the knees room to bend; the reach the
  gait actually needs now comes from the stepping cycle, not a deep hip drop. The
  reachable foot excursion is only ~0.25–0.32 m, while a 6 m/s run
  (`base_move_speed`) demands a ~1.4 m stride per step. Above that ceiling a
  planted foot **skates** forward (`_ik_reachable_target` clamps the target onto
  reachable ground) rather than floating toward an unreachable point. Shallower
  crouch = a bit more skate; the author chose that trade. The remaining honest
  fixes are longer leg sockets or a lower run speed — logged, not taken here.
- **Body-from-feet is `_apply_pelvis_carry`, not a `_animate_body` edit.** Every
  socket is a child of the RIG (body/head/arms/legs are SIBLINGS), so moving the
  body socket alone would tear the figure at the waist. The carry offsets all six
  pelvis-carried sockets by `_ik_pelvis_dy`, mirroring `_apply_waist_carry`. The
  waist carry's rest pivot is shifted by `_ik_pelvis_dy` so the bend still pivots
  on the (now-lowered) waist plane.
- **Coexistence with the wobble.** `_animate_wobble` no longer rattles the foot
  sockets under IK (the foot IS the plant, and its rest offset is the shin length
  the solver measures). The legs stay in the wobble list: the solver runs after
  it and reads the wobbled hip, so the rattle survives as absorbed hip motion.
- **Recommended tests:** headless probes covered plant-invariance under 180° yaw
  (0.000 m drift), standing solve accuracy (<1 cm), ramp ground-tracking (≤2.1 cm
  vs true ground height on an 11° slope), finite output over 60 frames, and the
  bit-identical gates above. **Manual, still owed:** how the crouch silhouette and
  the gait/skate READ on-screen — none of that is headless-testable.
- **Tuning** (all `@export`, "Foot IK" group): `ik_hip_drop` (0.05),
  `ik_step_trigger` (0.18), `ik_step_duration` (0.32 ceiling),
  `ik_step_reach` (0.32 — the stride; cadence = reach/speed, so this is ALSO the
  slow-the-feet knob; above 0.32 plants start to slide, see the sweep),
  `ik_stride_dip` (0.10 — extra pelvis give at stride extremes; the weight bob),
  `ik_step_duration_min` (0.06 — cadence floor; past ~4 m/s the feet scurry),
  `ik_step_overlap` (0.3 — each foot planted ~(1-2*ovl) of its swing; 0.5 is a
  ZERO-STANCE degenerate that never plants a foot),
  `ik_leap_height` (0.10 — more than the crouch's leg reserve affords with a real stance), `ik_leap_pitch_up_deg` (32),
  `ik_leap_pitch_down_deg` (0), `ik_leap_pitch_response` (14 — raise for a
  snappier chest sweep),
  `ik_step_height` (0.14), `ik_stride_lead` (1.7 launch-interval travels),
  `ik_run_lean` (0.07), `ik_body_follow` (1.0),
  `ik_step_drive` (0.85 — raise toward 1.0 for a harder per-step surge),
  `ik_body_follow_max` (0.45), `ik_body_follow_response` (22),
  `ik_body_follow_recenter` (0.8 — safety bleed only, NOT a signal filter; raising
  it re-glues the body to the capsule and kills the read),
  `ik_probe_radius/up/down`, `ik_max_drop`, `ik_pelvis_response`,
  `ik_foot_response`, `ik_align_to_normal`.

### Known limits
- Sprint skate is nearly gone (2.1% of path at 6 m/s) since the cadence coupling,
  but past ~4 m/s the `ik_step_duration_min` floor bites and the feet scurry —
  rapid small steps rather than long strides. That is the honest ceiling of these
  leg proportions.
- World-space plants assume static ground — teleports/level loads/moving platforms
  strand a plant until the next step re-probes.
- Vertical steps taller than the capsule can climb block the body (CharacterBody3D
  step-up), unrelated to the IK; ramps are fine.
- Enemies keep FK forever (unsplit). Splitting them is the separate Cut 2/3 work.
