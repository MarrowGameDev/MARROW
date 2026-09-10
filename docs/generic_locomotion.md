# MARROW Procedural Animation — plan & progress

A ground-up **morphology-driven** procedural animation system: it accepts a
creature assembled at runtime from interchangeable, differently-proportioned,
detachable rigid parts and produces locomotion, balance, attacks and damage
reactions with NO authored clips and no fixed rig. It replaces — for these
bodies — the hardcoded biped in `scripts/rig/procedural_player_animator.gd`,
which stays as-is and keeps driving the current player while this grows beside it
under `scripts/locomotion/`, built and tested stage by stage. A later milestone
adds an adapter so the shipping rig can feed this system.

## Authoritative design — the Morphology-Driven TDD

The spec is **`Morphology_Driven_Procedural_Animation_Godot.pdf`** (Technical
Design Document, 2026-07-18; the user's copy lives in `~/Downloads/`). This
document tracks our implementation against it. Extract the PDF's text with
`python3` + `pypdf` (poppler / `pdftotext` are not installed on this machine).

Its load-bearing decisions, which everything here follows:

- **The body is a runtime graph; the connected component containing the active
  head IS the character.** Identity and control belong to a persistent **Core
  Agent** represented by the head, not to the torso.
- **Pipeline:** compile the creature into a kinematic body graph → discover
  viable support configurations → schedule contacts → solve balance and root
  pose → solve each chain with topology-appropriate IK → switch disconnected
  components to physics. **Possession always follows the head.**
- **Animate tasks, not poses.** Never store "the knee is at 42°"; store "the foot
  must reach this contact while the knee bends toward this pole within its
  limits." IK/constraint solvers turn tasks into joint transforms valid for the
  *current* body.
- **The custom BodyGraph is authoritative.** Godot's `Skeleton3D`,
  `TwoBoneIK3D`, `FABRIK3D`, `SkeletonModifier3D` may be used as calculation
  helpers, but must not define ownership or anatomy.

## Our modules ↔ TDD components

Our headless `RefCounted` classes implement the TDD's compiler/planner concepts.
(Renaming the classes to the TDD's names is a deferred mechanical refactor; the
concepts map 1:1 today.)

| TDD component | Our class (`scripts/locomotion/`) | Status |
|---|---|---|
| BodyGraph (parts, links, traversal) | `body_graph.gd` + `body_part.gd` | ✅ (tree; no cut/components yet) |
| MorphologyCompiler / CompiledMorphology | `body_measure.gd` | ✅ (mass, COM, chains, reach, joint limits) |
| Support-polygon / stability math | `geom2d.gd` | ✅ |
| StanceSelector | `stance_generator.gd` (+ `resting_stance`) | ✅ (margin scoring; comfort/energy terms pending) |
| ContactPlanner (foot lock) | `contact_lock.gd` | ✅ (lock + reach bookkeeping) |
| GenericIKController | `chain_ik.gd` | ✅ (hinge / two-bone / FABRIK) |
| GaitGenerator / oscillators | `gait_oscillator.gd` + `gait_controller.gd` + `gait_pattern.gd` | ✅ (walk / trot / tripod / wave) |
| BalanceController / RootPoseSolver | `gait_controller.gd` + `root_pose_solver.gd` | ✅ (lateral sway + pitch/roll/height from contacts) |
| DetachmentManager / ConnectedComponentFinder | `body_graph.gd` (components/subgraph) + `detachment.gd` | ✅ cut + recompile (physics hand-off = scene layer) |
| CoreAgent / PossessionController | — | ◻ M8 |
| Attack task system | `attack_controller.gd` | ✅ (task-space paths, reach policy; hit detection = scene layer) |
| Debug visualization | `locomotion_gallery.gd` + `locomotion_zoo.gd` | ✅ (stances, support polygons, CoM) |

## Roadmap — TDD milestones

This supersedes the earlier ad-hoc "12 stages" (whose numbers the code/tests
still use; the mapping is noted per milestone).

| Milestone | Deliverable | Our coverage | Status |
|---|---|---|---|
| **M1 Modular assembly** | Part scenes, sockets, connection validation, graph traversal | stages 1–2 topology | ✅ (pure-class; scene parts + `AttachmentLink`s deferred to M7) |
| **M2 Compilation** | Measure chains, mass, COM, reach, supports; debug viz | stage 2 + gallery | ✅ |
| **M3 Static stance** | Generate & score stable biped + quadruped poses | stage 3 | ✅ |
| **M4 One procedural leg** | Lock one contact, solve one chain, place rigid visible segments | stage 4 (lock ✅) + stage 5 (IK ✅) | ✅ |
| **M5 Biped locomotion** | Alternating gait phase, contact prediction, root/pelvis correction, turning | stage 6 (walk + terrain + turning ✅, all tested) | ✅ |
| **M6 Generalized supports** | 4+ limbs, quadruped walk/trot, topology-independent oscillator sets | stages 7-9 (walk/trot/tripod/wave + torso pose ✅) | ✅ |
| **M7 Damage & detachment** | Graph cuts, physics transfer, collision grace, live recompilation | `detachment.gd` (cut + recompile ✅; physics/possession = scene layer) | ◨ |
| **M8 Head possession** | Detach head, head-only movement, compatible-socket search, reattachment | (new — not in old plan) | ◻ |
| **M9 Procedural attacks** | Task-space attack paths, root stepping, hit windows, missing-limb fallback | `attack_controller.gd` (paths + reach + impact ✅; hit/damage wiring = scene layer) | ◨ |
| **M10 Polish & scale** | Emergency reactions, LOD, pooling, networking, save/load, tools | stage 12 | ◻ |

**Minimum viable prototype** (TDD §16.1): two torso types, three interchangeable
limb lengths, automatic biped/quadruped stance selection, one walk gait each, one
severable limb, head detachment, and one reattachable body. Prove topology
changes recompile locomotion without authored clips — *before* chasing every
creature family or advanced physics.

## Key design decisions carried from the TDD

- **IK by topology (§8):** 1 segment → direct/hinge; 2 → analytical two-bone IK
  with a **pole target**; 3+ → constrained CCD / FABRIK; spine/tail → spline or
  multi-joint iterative. Clamp the target distance to `[|a−b|, a+b]`; never
  silently stretch a part unless it declares scaling.
- **Avoid singular fully-extended poses.** Derive a stable pole from the socket
  bend axis + torso orientation + previous-frame direction and smooth it so knees
  don't flip. Addressed in the gallery via `StanceGenerator`'s `reach_fraction`
  (stand at 90% of full reach → the two-segment legs land on a bent knee instead
  of the singular straight pose). The default is still 1.0; a gait/comfort profile
  lowers it.
- **Visible-segment placement (§4.4):** put the rigid mesh at the midpoint of two
  solved joints, orient it start→end, scale ONLY along its length axis and only if
  allowed. Prefer moving joints to the true socket-to-socket length over stretching
  meshes. (The gallery already draws bones this way.)
- **Attached vs detached physics (§10.3):** an attached part is driven by the
  solver and contributes to the assembled COM; a detached part/subassembly becomes
  a `RigidBody3D` under gravity/impulse. Detachment = deactivate a graph edge →
  find connected components → transfer velocity+impulse → recompile the head's
  component → new stance or collapse.
- **Possession rule (§11.1):** the connected component containing the Core Agent's
  head receives input, camera, abilities and identity — this one rule covers head
  on a biped, on a quadruped, on a single arm, or alone.
- **Stance scoring (§6.2):** the full score is
  `stability_margin·w + joint_comfort·w + ground_clearance·w + orientation_pref −
  energy_cost − joint_limit_penalty − self_collision_penalty`. We currently score
  on margin + tiebreaks only; the other terms are a natural M3 enrichment.
- **Locomotion families (§6.4):** biped, quadruped, multi-leg, hop, crawl,
  serpentine, rolling, head-only. The stance selector chooses a *compatible*
  family rather than forcing one formula. (Our snake is the serpentine seed.)

---

# Built so far

## M1 / stage 1 (done) — the body graph
- **`body_part.gd` (BodyPart)** — one rigid box: `size`, `mass`, `center_offset`,
  and named **sockets** (each a `Transform3D` frame in the part's own origin
  space). Carries NO notion of "arm"/"leg" — a torso is a part with five sockets,
  a leg a part with two (`root` mount, `tip` endpoint).
- **`body_graph.gd` (BodyGraph)** — parts + **joints**. A joint pins a child's
  mount socket onto a parent's socket; `assemble(root_transform)` walks the tree
  and returns a world `Transform3D` per part:
  `child_world = parent_world * parentSocket * childSocket⁻¹`. `validate()`
  rejects no/unknown root, two parents, orphan, cycle, missing socket. Tree-only
  for now; closed loops and the `AttachmentLink`/`cut_link`/`connected_component`
  machinery arrive with **M7 detachment**.
- **Tested**: `test_body_graph.gd` builds a biped and quadruped from the SAME
  assembler and checks placement, coplanar stances, rotated-socket propagation and
  all four validation failures. `BODY_GRAPH_TEST: ALL PASS`.

## M2 / stage 2 (done) — compilation / measure
- **Model extension**: `BodyPart.endpoints` (`mark_endpoint()`), and joints carry
  a `dof` Array — `{axis, min, max}` rotational freedoms in the parent-socket
  frame; `[]` = rigid weld. Helpers `BodyGraph.hinge` and `.ball`. `assemble()`
  uses the rest pose (all angles 0); dof is metadata until the IK solver drives it.
- **Topology queries**: `parent_joint_of`, `leaves`, `joints_to`, `endpoints_world`.
- **`body_measure.gd` (BodyMeasure)** — name-agnostic `total_mass()`,
  `center_of_mass()`, `chains()` (per endpoint: `reach_rest`,
  `reach_max` = Σ segment lengths, `limb_mass`, `limb_com`, per-joint DOF/limits)
  and `describe()`. This is the TDD's MorphologyCompiler.
- **Tested**: `test_body_measure.gd` — 2-segment legs (thigh+shin+knee), a 50°
  bent knee proves `reach_rest < reach_max`. `BODY_MEASURE_TEST: ALL PASS`.

## M3 / stage 3 (done) — static stance selection
- **`geom2d.gd` (Geom2d)** — `convex_hull` (monotone chain), `signed_margin`
  (positive inside a convex CCW polygon; handles 1-/2-point hulls), `area`,
  `centroid`.
- **`stance_generator.gd` (StanceGenerator / StanceSelector)** — the torso stands
  at height H; each endpoint drops to the ground within reach and splays outward by
  fraction s. It sweeps (H, s), builds the support polygon from foot patches
  (`contact_radius` 0.08), projects the CoM, and keeps the largest balance MARGIN.
  **Tiebreaks: least spread, then tallest torso** — a biped's margin is
  foot-radius-capped fore-aft so spread AND height tie; least-spread stops the
  splits, tallest-torso stands it at near-full extension (valid for rigid legs;
  see the ⚠ above — bent knees arrive with M4 IK). A quadruped's margin grows with
  spread, so it still splays wide. **`reach_fraction`** sets how upright it stands
  (leg usage) and **`stance_width`** (optional; default lets the search choose)
  fixes the lateral splay as a fraction of the reach available at that height — two
  independent knobs, verified by `test_stance_generator.gd` (same height, splay
  0.46→0.74).
- **`resting_stance()`** (static) — the LIMBLESS family (snake): drop the body
  until its lowest endpoints touch, run the SAME hull/margin check with no
  height/spread search. Same return shape as `generate()` plus a centring
  `root_offset`.
- **Tested**: `test_stance_generator.gd` — stable hip-width biped (+0.08), wide
  4-corner quadruped (+0.45), stub legs → none, off-centre load → `unstable`
  (−0.31). `STANCE_TEST: ALL PASS`.

## M4 / stage 4 (done — the lock half) — contact locking
- **`contact_lock.gd` (ContactLock / ContactPlanner)** — once a stance plants the
  endpoints, their world positions are LOCKED. The torso can sway, bob, lean and
  turn while every foot stays exactly put; it reports, per proposed torso pose,
  whether each limb can still REACH its contact and how much reach it has to spare
  (the signal the gait scheduler reads to decide when a foot must be lifted). It
  does NOT bend the legs — that's the IK half (below).
- **Rests on one fact**: a limb's base is a socket on the ROOT part, so
  `hip_world = root_transform * base_local` — no re-assembly as the torso moves.
  Per contact: `hip`, `foot` (locked), `dist`, `margin` (= reach_max − dist),
  `strain` (= dist / reach_max), `reachable`; per body: `all_reachable` + tightest
  limb. `max_travel(dir)` bisects how far the torso can move before a lock breaks;
  `set_contact()` re-plants a foot after a step.
- **Tested**: `test_contact_lock.gd` — under translation feet stay fixed and hips
  move by exactly the same vector; crouch adds margin, over-extension breaks a
  lock; the standing biped crouches ~1.24 m but rises ~0.001 m and sways ±0.035 m
  (full-extension); yaw keeps feet planted; a quadruped locks four the same way.
  `CONTACT_LOCK_TEST: ALL PASS`.

## M4 (done — the IK half) / stage 5 — generic chain IK
- **`chain_ik.gd` (ChainIK)** — bend a limb so its tip reaches a target, solving by
  TOPOLOGY: 1 segment → hinge (point at target); 2 → **analytical two-bone IK with
  a pole target** (deterministic, exact); 3+ → **FABRIK** (pole-seeded iterative).
  Pure static math on world points + segment lengths — knows nothing about
  BodyGraph, so `test_chain_ik.gd` unit-tests it directly. Reachability per TDD
  §8.2: a target beyond `a+b` straightens the chain toward it, a target too close
  folds as far as it can; segments never stretch (verified to ±1e-4).
- **Fed by** `BodyMeasure.chains()[i].segments` — the per-segment lengths (thigh,
  shin, …) added this stage; the hip is the chain `base`.
- **Two-segment legs**: `LocomotionZoo.add_leg()` now builds thigh + shin + a
  hinged knee (same total reach, so the stance search is unchanged). The gallery
  stands each creature at `reach_fraction` 0.9 and runs `ChainIK` from hip to
  planted foot with a forward pole, drawing one bone per solved segment plus a
  knee joint — so **the biped, quadruped and hexapod now stand on visibly bent
  knees** instead of straight sticks.
- **Tested**: `test_chain_ik.gd` (two-bone exact + clamped + pole flips the knee
  side + mirror symmetry; 1-segment hinge; 3-segment FABRIK converges) →
  `CHAIN_IK_TEST: ALL PASS`; and `test_gallery.gd` now asserts every leg's IK
  reaches its planted foot. Re-run:
  `<godot> --headless --path . --script res://scripts/locomotion/test_chain_ik.gd`

## M5 (walk done) / stage 6 — gait: it walks
- **`gait_oscillator.gd` (GaitOscillator)** — one normalised phase per support
  limb (TDD §7.4). A global phase advances with cadence; each limb reads it through
  its own OFFSET and is in STANCE for `duty` of the cycle, then SWING. Coupled
  offsets ARE the gait: biped walk = two limbs half a cycle apart; quadruped trot =
  diagonal pairs together — no recorded poses.
- **`gait_controller.gd` (GaitController)** — the per-frame walk (TDD §7). Planted
  feet are **world-locked** (no sliding); a swing foot arcs (`sin` lift, smoothed
  lerp) to the next predicted plant **ahead** of the body; the root advances by the
  desired velocity and **sways laterally toward its support** for balance; every leg
  is posed by `ChainIK`. All distances scale from morphology (§7.5): `stride` and
  `step_height` from reach. Not biped-specific — hand it N offsets and it schedules
  N supports (that's how the quadruped trots).
- **Bug the test caught**: feet were planting at the last *sampled* swing point (a
  discrete `t≈0.9`, ~3 cm up) and then floating through stance. Fixed by planting at
  the planned **landing** (exactly on the ground).
- **Tested** (`test_gait.gd`): walking a biped 5 s — at least one foot always down,
  planted feet never move (0 slip), planted feet exactly on the ground, swing feet
  lift to exactly the step height, the body advances at the commanded 0.6 m/s, and
  no foot ever leaves reach. `GAIT_TEST: ALL PASS`. Re-run:
  `<godot> --headless --path . --script res://scripts/locomotion/test_gait.gd`
- **Terrain-following** (M5 refinement): `GaitController.set_ground(height_fn)` drops
  each plant onto the terrain and re-projects the stance; the `RootPoseSolver` pitch
  built in M6 then tilts the torso to the slope. `test_terrain.gd` walks a quadruped
  up a 0.12 ramp — it **climbs 0.39 m over 3 m, feet exactly on the slope, torso
  nose-up (0.11 rad), no slide, still 3+ supported**. `TERRAIN_TEST: ALL PASS`.
- **Turning** (M5 finish): `GaitController.set_intent(speed, turn_rate)` turns a
  heading over time; the body walks where it faces, feet plant under the turned hips
  (`facing * rest_offset`), and `RootPoseSolver` yaws the torso to match. `test_turning.gd`
  turns a walking quadruped ~100°: the path curves, the torso yaws, feet don't slide,
  and it stays 3+ supported and in reach. `TURNING_TEST: ALL PASS`.
- **Only longer-horizon trajectory prediction** remains as an M5 nicety; walk,
  terrain and turning are done.

## M6 (done) / stages 7-9 — generalized supports & torso pose
- **`gait_pattern.gd` (GaitPattern)** — classify each leg by side and column
  (front/mid/rear) from its ground position, then emit the phase offsets + duty for
  a FAMILY: `biped_walk`, `quadruped_walk` (lateral-sequence, statically stable —
  duty 0.78, one foot swinging at a time → 3 always down), `quadruped_trot`
  (diagonal pairs), `tripod` (alternating insect gait), and a metachronal `wave`
  for any N. `recommend()` picks by leg count. Coupled offsets are the only thing
  that differs between families.
- **`root_pose_solver.gd` (RootPoseSolver)** — derive the torso pose from the
  PLANTED contacts (TDD §7.6): height rides the mean contact; PITCH comes from the
  front-vs-rear contact groups, ROLL from right-vs-left. Level on flat ground, tilts
  on a slope/step. Wired into `GaitController` (a lifted swing foot is excluded, so
  it can't tilt the body).
- **Tuning learned**: a walking quadruped stands more upright than the splayed
  max-stability stance (`reach_fraction` ~0.72) with a shorter stride, and a
  statically stable body barely weight-shifts. That last point is now **automatic**:
  `GaitController` scales the sway by support count (`_balance_base * (3 − planted)/2`),
  so a biped in single support swings fully and a 3+-foot body ~0 — no manual
  `balance_gain` to mis-set. (Stance splay is now its own `stance_width` knob,
  independent of `reach_fraction`; see Stage 3.)
- **Tested**: `test_gait_pattern.gd` — classification; each family's support count
  (walk 3+, trot 2, tripod 3+); and a live quadruped WALK and hexapod TRIPOD (both
  stay 3+ supported, never slide, keep feet in reach — max strain 0.92 / 0.86 — and
  hold the torso level). `test_root_pose.gd` — flat→level, front-higher→nose-up,
  right-higher→roll, height rides the mean. Both `ALL PASS`.

## M7 (core done) — damage, detachment & recompilation
- **`body_graph.gd`** grew `connected_components(cut_joint)`, `component_containing`,
  and `subgraph(part_ids, root, cut_joint)` — treat joints as undirected
  attachments, so cutting one edge of the tree yields exactly two connected groups,
  and a group can be rebuilt into a fresh standalone `BodyGraph`.
- **`detachment.gd` (Detachment)** — `sever(graph, joint, core_id)` (TDD §10): split
  the graph, keep the component holding the CORE part (the head — identity, §11) as
  `controlled`, recompile it (fresh sub-graph + a new `StanceGenerator` pass →
  `standing` or `collapsed`), and hand every other component back as `detached`.
  `joint_attaching(part)` lets a caller sever a limb by name.
- **Tested** (`test_detachment.gd`): a biped that loses a leg keeps the head but
  **collapses** (can't stand on one); when the **head detaches**, control follows
  the head (a headless body is just `detached` debris, no longer the character); and
  a **quadruped that loses a leg recompiles into a stable tripod** (fresh stance,
  margin +0.14). `DETACHMENT_TEST: ALL PASS`.
- **Deferred to the scene/node layer**: turning detached components into
  `RigidBody3D` physics (gravity, inherited velocity, hit impulse), collision grace,
  and transferring player possession — those need the node architecture (§12), not
  the pure-`RefCounted` core. The graph "brain" of M7 is done and headless-tested.

## M9 (core done) — procedural attacks
- **Manipulation effectors**: `BodyPart.manipulators` (a hand) parallel to support
  `endpoints` (a foot) — `graph.manipulators_world()`, `BodyMeasure.manipulation_chains()`.
  Hands are reached by attacks but **never planted**, so an armed biped still stands
  on its two feet. `LocomotionZoo.add_arm` / `biped_with_arms(arm_len)`.
- **`attack_controller.gd` (AttackController)** — an attack is a TASK-SPACE path, not
  a clip (TDD §9): the hand runs **wind-up → strike → follow-through** in a frame
  aimed at the target, sampled by phase and fed to `ChainIK`. `plan()` is the reach
  policy — hit in place, or report the `root_step` needed to close the distance;
  `sample()` gives the hand target, the **impact window**, and a torso lunge.
  `pick_chain()` selects the longest-reach hand, or returns none so a body without a
  hand falls back. Everything scales from morphology: a long arm hits what a short
  arm must step toward.
- **Tested** (`test_attack.gd`): hands don't bear weight; reach policy (in-reach vs a
  0.95 m root step); the swing winds up high & back and lands on the target; the
  impact window opens only at the strike; arm IK reaches every point on the path
  (err 0.0); and long-arm-hits / short-arm-steps. `ATTACK_TEST: ALL PASS`.
- **Deferred to the scene layer**: actual hit detection / sever damage during the
  impact window, and weapon meshes — those need the node architecture (§12).

## Watch it walk — the walk demo
`scenes/locomotion_walk.tscn`. In a running build press **6** anywhere to open it
(the `LocomotionDemoLauncher` autoload, `scripts/locomotion_demo_launcher.gd`);
**Esc** returns to the main menu, **R** resets. From the editor you can also open
the scene and press F6. A biped WALKS, a quadruped WALKS (statically stable), and a
hexapod does a TRIPOD gait — all across a striped ground from the SAME
`GaitController` + `GaitPattern`, differing only in family/offsets; swing feet glow
green, planted feet are amber, and the side-view camera tracks them.

Controls note: key **6** is a global demo hotkey, so the dummy testing
environment's ranged-enemy spawn moved from 6 to **7** (`testing_environment.gd`),
losing nothing. Headless scene-loads contend with an open editor's import lock, so
the walk *logic* is verified by `test_gait.gd`, not a scene smoke.

## Tuning it — the locomotion lab
`scenes/locomotion_lab.tscn` — in a running build press **8** (LocomotionDemoLauncher).
One creature walks while a live menu (top-right) exposes **every M2–M6 variable** and a
readout (top-left) shows the consequences: measured reach/mass (M2), the chosen stance's
height/margin/foot-count (M3), and the live support count / max reach strain / heading
(M5–M6). **Tab** hides the menu, **Esc** returns, **R** resets. The whole variable set is
the `SPEC` array at the top of `scripts/locomotion/locomotion_lab.gd` — the single place
to add or drop a knob:
- **M2 morphology**: creature (biped/quadruped/hexapod), leg_length.
- **M3 stance**: reach_fraction (height), **stance_width** (lateral splay, independent of
  height), contact_radius (foot patch).
- **M5 gait**: speed, turn_rate, stride_ratio, step_ratio, duty. *(Balance is now automatic —
  the sway is scaled by support count, so a biped in single support swings fully and a
  statically-stable quadruped barely sways; no manual knob.)*
- **M6**: family (auto / walk / trot / tripod / wave), slope (terrain).

Motion knobs (speed, turn_rate) apply live; structural ones re-stance and rebuild without
teleporting the creature. The variable set has been cleaned up from the first draft:
`stance_width` was **added** (previously `reach_fraction` conflated height and splay);
`balance_gain` was **removed** as a manual knob (now auto). `contact_radius` is kept but is a
weak knob for wide bases (it's the biped's whole margin, though). A cadence decoupled from
speed was considered and **skipped** — `stride_ratio` already trades step length for frequency
at a fixed speed.

### Gotcha: a short stride makes the legs look GLUED to the ground
Cadence is derived (`speed / stride`), so a **short stride means a high cadence and a
very brief swing**. The quadruped demo originally used `stride_ratio` 0.28 → stride
0.14 m → 3.6 Hz → each swing lasted **3.7 frames** at 60 fps: the foot did lift 8 cm,
but too briefly to see, so the legs read as glued. (The hexapod was the same at 5.6
frames; the biped was fine at 9.6.)

The stride couldn't simply be lengthened — the max-stability stance splays feet near
the reach limit, so a longer stride pushed them out of reach. The fix is
**`stance_width`**: rein the splay in (0.40) and the feet sit under the body, freeing
fore-aft room for a long stride. Demo/lab walkers now use `reach_fraction` 0.80,
`stance_width` 0.40, `stride_ratio` 0.75, `step_ratio` 0.28 → **11 frames of swing for
the quadruped, 22 for the hexapod**, larger foot lift (0.14 m), *lower* strain (0.89)
and a *better* stability margin than before. `test_gait_pattern.gd` now asserts
swing ≥ 8 frames and that feet visibly leave the ground, so this can't regress.

## Hitting things — the combat lab (action & reaction)
`scenes/locomotion_combat.tscn` — press **9** in a running build. An armed biped
swings a task-space attack at a receiver; at the impact window **the hand's world
position IS the contact point**.

- **`impact_response.gd` (ImpactResponse)** — an impulse at a contact point kicks a
  spring-damper that offsets a body's root: LINEAR knockback from the impulse, and
  ANGULAR tilt/twist from the torque **`r × F` about the centre of mass**. So *where*
  the blow lands shapes the motion — high hit → pitches away, side hit → twists, hit
  through the CoM → pure knockback — then it decays back to neutral (flinch → recover).
  Scales with morphology via `BodyMeasure.total_mass()` and the new
  `inertia_about_com()` (Σ m·r², TDD §4.3 "inertia hints").
- **Action AND reaction**: the receiver takes `+impulse` and the attacker takes
  `−impulse` at the same contact point (Newton's third law), each through its own
  `ImpactResponse`, so recoil is free and scaled by the attacker's own mass.
- **Tested** (`test_impact.gd`): a high hit pitches the top the way of the push
  (+0.385 rad), a side hit yaws instead, a CoM hit rotates ~0 but still knocks back,
  a 4× heavier body moves 4× less, the attacker recoils opposite, and it settles.
  `IMPACT_TEST: ALL PASS`.
- **Menu** (Space: strike · A: auto-repeat · Tab: hide · R: reset): aim
  (`target_height` / `target_side` / `target_distance` — move these to see the
  contact point change the reaction), attack (style, duration, impulse), receiver
  reaction (knockback/torque scale, stiffness, damping) and attacker `recoil_scale`.
- **Save / bake** → `res://data/locomotion_profiles/`:
  - **Save profile (.json)** — the tuned numbers, reusable and morphology-independent
    (the motion is regenerated procedurally on any body). This is the real output.
  - **Bake last strike (.tres)** — records the strike into a Godot `Animation` with
    position/rotation tracks per part, for inspection or export. ⚠ A baked clip is
    tied to the exact body it was recorded on and breaks on different proportions or
    after limb loss — the thing this system exists to avoid. Use it as a reference,
    not as the pipeline.

## Viewing it — the locomotion gallery
`scenes/locomotion_gallery.tscn` — press **F6** (Play Scene). For every creature
in `locomotion_zoo.gd` it runs the real StanceSelector and draws, per ground
tile: parts as their assembled boxes, each leg as a bone from hip to planted foot,
the support polygon, foot patches, and the CoM plumb line — **green inside the
base (stable), red outside (tips over)**. Biped, quadruped and hexapod stand from
the SAME code; a **snake** (curved 10-segment chain, no legs) rests on its belly;
a biped with a heavy off-centre boom reads red. Legs are two-segment (thigh +
shin) and solved with `ChainIK`, so knees bend from hip to planted foot. Data-layer
smoke test:
`<godot> --headless --path . --script res://scripts/locomotion/test_gallery.gd`
(`GALLERY_TEST: ALL PASS`).

### Conventions later milestones rely on
- A part's ORIGIN is its own local (0,0,0); `size` is the full box centred at
  `center_offset`. Sockets and CoM are all in that origin frame, so a part is
  self-describing and reusable wherever it is socketed.
- Endpoint sockets (a leg's `tip`) are the contact candidates the stance selector
  plants and the contact planner locks.
- All new modules are pure `RefCounted` and headless-testable; the shipping
  animator is never touched.
