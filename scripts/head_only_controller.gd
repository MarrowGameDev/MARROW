extends Node3D

# HEAD-ONLY movement — CODE-DRIVEN (mesh-based).
#
# The head's authored object animation ("head in armature") does NOT survive glTF export:
# the head mesh is skinned, and Godot ignores a skinned mesh's own object transform. So we
# move the head as a rigid object here instead — the owning CharacterBody3D drives travel,
# and we add a procedural hop + lean for life. Only the head (and neck stump) is shown.

const GLB: PackedScene = preload("res://assets/crab_head_character_optimized.glb")
const POSE_CLIP := "head in armature"   # played for the authored head pose (bob is procedural)

@export var character_scale: float = 0.18
@export var ground_offset: float = 0.0                       # fine-tune height on top of auto-grounding
@export var settle_percentile: float = 0.06                  # head+torso: seat this height-percentile of the hips on the floor (skips low leg-stump verts)
@export var visible_parts: Array[String] = ["head"]          # head only — no neck
@export var run_speed: float = 4.0
@export var hop_height: float = 0.52                         # jump height while moving (metres)
@export var hop_height_variation: float = 0.18               # ± random height per hop so the walk doesn't look repetitive
@export var hop_rate: float = 1.5                            # jumps/sec — higher = faster, snappier, less floaty
@export var rise_frac: float = 0.50                          # portion of each hop spent rising; higher = FASTER fall
@export var lean_deg: float = 14.0                           # forward lean on the way up
@export var fall_tilt_deg: float = 34.0                      # tilt the head BACK as it falls
@export var jump_stretch: float = 0.40                       # stretch TALL mid-air (deform / character)
@export var land_squash: float = 0.32                        # squash FLAT on landing (impact weight)
@export var hop_spring_frac: float = 0.22                     # portion of each hop compressed on the floor (spring load)
@export var hop_synced_move: bool = true                     # ease forward travel with the hop (glide airborne, slow on the floor)
@export var move_gate_floor: float = 0.5                     # min fraction of walk speed kept during the on-floor recoil (0 = full stop, 1 = constant)
@export var wobble_deg: float = 5.0                          # side wobble
@export var idle_squash: float = 0.05
@export var body_idle_squash_frac: float = 0.25             # assembled, the idle breath is this fraction of idle_squash (the tall body + segment slide moves the head too much otherwise)
@export_group("Little arms (assembled)")
@export var arm_react_gain: float = 0.35                    # how strongly the little arms react to the body's up/down motion (inertia)
@export var arm_swing_stiffness: float = 55.0              # spring pulling them back to rest
@export var arm_swing_damping: float = 10.0               # higher = settles faster / less wobble
@export var arm_swing_deg: float = 28.0                  # max SHOULDER swing (deg)
@export var arm_swing_dist: float = 0.5                 # max IK-target (claw) lift
@export var arm_swing_hand_deg: float = 40.0          # max hand tilt (deg)
@export_subgroup("Torso spine bend (walk)")
@export var torso_tilt_scale: float = 0.15                 # how much of the whole-body walk LEAN to keep once a torso is on (0..1; low = barely tilts)
@export var torso_bend_air_deg: float = 20.0           # torso bends BACK this much at the top of the hop
@export var torso_bend_land_deg: float = 15.0          # ...and FORWARD this much as it lands
@export var torso_bend_lower_frac: float = 0.15        # share of the bend on the lower spine (root) — small, or it tilts the whole body
@export var torso_bend_mid_frac: float = 0.9          # share on the mid spine (torso trunk) — this is the real torso bend
@export var torso_bend_smooth: float = 13.0           # how quickly it eases between the air/landing poses
@export var spine_head_stabilize: float = 0.7        # keep the head level while the torso bends (1 = steady, 0 = head rides the bend)
@export_subgroup("")
@export var squash_node_frac: float = 0.3                   # once assembled, only this much of the squash is uniform node-scale; the rest SLIDES the parts (head/neck/torso) together and apart along the spine
@export var head_neck_close: float = 0.6                    # pull the head IN toward the neck at rest (<1 = closer); the rig's default gap sits the head too high
@export var reground_dur: float = 0.5                        # when a part attaches, the body eases up to its new grounded height over this time (s)
@export var reground_jump: float = 0.12                      # small settle-hop on that rise (the big leap comes from the head's own jump)                        # gentle breathing squash when still

@export_group("Run (blends in as speed nears run_speed)")
@export var run_hop_height: float = 0.32                     # LOWER hops when running -> quicker air at the SAME gravity
@export var run_lean_deg: float = 30.0                       # deeper forward lean, driving into the run
@export var run_stretch: float = 0.6                         # more airborne stretch (dynamic bound)
@export var run_fall_tilt_deg: float = 16.0                 # less back-brace on the fall (forward-driving)
@export var run_gate_floor: float = 0.72                     # keep more forward drive through the recoil

@export_group("Crouch (Ctrl)")
@export var read_crouch_input: bool = true                   # player holds Ctrl; AI can call set_crouch()
@export var crouch_wobble_deg: float = 16.0                  # side-to-side roll while crouch-sliding
@export var crouch_bob_deg: float = 5.0                      # small pitch bob (2x the roll) for an organic wobble
@export var crouch_lean_deg: float = 8.0                     # gentle forward lean of the crouch-creep
@export var crouch_sway: float = 0.05                        # side sway (metres) synced with the roll
@export var crouch_wobble_rate: float = 8.0                  # wobble speed (rad/s) at full move speed
@export var crouch_jump_time: float = 0.5                    # head+torso: seconds for the head to jump off the socket down onto the ground (and back)
@export var crouch_jump_leap: float = 0.45                   # head+torso: how high the head leaps OFF the neck socket before dropping (× the head's own height, so it clears the socket)

@export_group("Jump (Space)")
@export var read_jump_input: bool = true                     # player reads Space; enemies call trigger_jump()
@export var jump_height: float = 0.4                         # apex ~= neck altitude on the standing rig (0.40 m above feet)
@export var jump_duration: float = 0.82                      # total jump time (s)
@export var jump_anticipate: float = 0.12                    # crouch before launch (s)
@export var jump_recover: float = 0.15                       # landing recovery (s)
@export var jump_crouch: float = 0.30                        # anticipation + impact squash depth (deform)
@export var jump_tilt_deg: float = 28.0                      # head tilts back through the fall
@export var jump_tilt_start: float = 0.3                     # when the back-tilt begins (fraction of air time; <0.5 = during the rise)
@export var jump_rise_frac: float = 0.5                      # portion of air time RISING; 0.5 = symmetric arc (apex at mid-distance)
@export var jump_stretch_hold: float = 0.45                  # fraction of the RISE the launch stretch lasts (lower = briefer)
@export var jump_move_lean_deg: float = 16.0                 # lean into travel direction when steering mid-jump
@export var jump_move_boost: float = 1.5                     # a MOVING jump (Space + WASD) is this × higher AND longer

signal hit_landed   # emitted the instant the headbutt connects (for camera shake, sfx, ...)

@export_group("Attack (Left-click)")
@export var read_attack_input: bool = true                   # player reads Attack; AI calls trigger_attack()
@export var attack_duration: float = 0.8                     # forward-leap headbutt (s) — whole cycle scales with this
@export var attack_windup: float = 0.28                      # coil/crouch portion (0..1 of duration)
@export var attack_reach: float = 0.9                        # forward leap distance (metres)
@export var attack_hop: float = 0.7                          # how high the head leaps on a HIT ram (stay near the target)
@export var attack_flip_height: float = 1.9                  # how high the head leaps on a MISS somersault (the flourish)
@export var attack_slam: float = 0.12                        # how far it drops below base on the headbutt
@export var attack_charge_lift: float = 0.0                  # lift while loading (only needed if you re-add a rear-back)
@export var attack_coil: float = 0.30                        # how far the head draws BACK to load the headbutt (× reach)
@export var attack_load: float = 0.28                        # compression while loading the windup (spring load)
@export var attack_windup_tilt: float = 0.0                  # rear the head BACK while winding up (0 = no backward tilt)
@export var attack_stretch: float = 0.45                     # forward stretch on the leap (ram)
@export var attack_chomp: float = 0.34                       # squash on the headbutt impact
@export var attack_lean_deg: float = 34.0                    # pitch forward, ramming forehead-first
@export var attack_forward_sign: float = 1.0                 # flip to -1 if the headbutt drives the wrong way
@export var attack_damage: int = 3                           # MAX damage (at full charge); scales down with less charge
@export var attack_charge_time: float = 1.0                  # hold time (s) to reach a full charge
@export var attack_min_power: float = 0.45                   # leap/power floor for a quick tap (uncharged)
@export var attack_hitstop: float = 0.08                     # freeze on impact (hit-stop) for weight
@export var attack_impact_crush: float = 0.38                # how hard the head crushes on contact
@export var attack_flip_turns: float = 1.0                   # full forward somersaults on a MISS (0 = no flip)
@export var attack_style_count: int = 3                      # attack variety: 1=only somersault, 2=+twirl, 3=+barrel roll
@export_subgroup("Combo (detached head)")
@export var combo_strike_time: float = 0.32                   # one combo hit: leap + dive + strike (s)
@export var combo_recover_time: float = 0.4                   # window on the ground to click the NEXT hit before it flies home
@export var combo_return_time: float = 0.5                    # jump from the ground back onto the socket (s)
@export var head_ground_clear: float = 0.28                   # height of the head's centre above the FLOOR while it fights on the ground (m)
@export var combo_leap: float = 1.1                           # apex height of each dive-strike (m) — big arcing leaps
@export var combo_return_leap: float = 0.95                   # apex of the jump back to the body (m)
@export var combo_max: int = 4                               # cap on chained hits before it must return
@export var reattach_jump_dist: float = 1.5                  # body within this of the fallen head -> hop straight back on; beyond -> WALK back first
@export var head_walk_speed: float = 3.2                     # head-only walk speed the fallen head uses to catch a far body
@export var head_walk_hop: float = 0.28                      # hop height of that walk-back
@export var head_walk_hop_rate: float = 2.4                  # hops/sec of the walk-back
@export var head_walk_stretch: float = 0.22                  # airborne stretch of the walking head (head-only-style squash/stretch)
@export var head_walk_squash: float = 0.18                   # landing squash of the walking head
@export var head_walk_lean: float = 16.0                     # forward lean/back-tilt bob of the walking head (deg)
@export var head_catch_up_mult: float = 1.5                  # if the body RUNS, the head walks at body_speed * this so it catches up
@export_subgroup("Aim assist")
@export var attack_aim_range: float = 3.0                     # lock onto a target within this distance to headbutt it
@export var attack_aim_cone_deg: float = 60.0               # ...and within this half-angle of where we're facing
@export var attack_aim_turn: float = 11.0                    # how fast the body swings to face the locked target during windup

@export_group("Reattach orbit")
@export var orbit_duration: float = 1.1                      # time to spiral into the neck socket (s)
@export var orbit_turns: float = 1.75                        # how many times it circles the body on the way in
@export var orbit_stretch: float = 0.8                       # G-force stretch along the motion (0 = none)
@export var orbit_ref_speed: float = 9.0                     # motion speed (m/s) at which the stretch maxes out
@export var orbit_min_radius: float = 0.6                    # smallest orbit radius (so it circles even if it starts on top)
@export var orbit_settle_duration: float = 0.42             # recoil/settle time after it seats, before locking (s)
@export var orbit_recoil_dist: float = 0.20                 # how far the head jiggles on the recoil (world units)
@export var orbit_recoil_squash: float = 0.24              # squash on the settle impact
@export var orbit_recoil_wobbles: float = 2.0              # how many times it jiggles before locking
@export var orbit_lean_deg: float = 32.0                  # lean OPPOSITE the arrival momentum as it seats (deg)
@export_group("Detach (hop off the body)")
@export var detach_duration: float = 0.75                 # time to leap off the neck and land (s)
@export var detach_jump: float = 0.7                      # extra leap height off the neck socket
@export var detach_turns: float = 1.0                     # somersaults on the way off

var _model: Node3D
var _ap: AnimationPlayer
var _body: Node3D
var _phase := 0.0
var _jt := 0.0
var _hop_amt := 0.0        # latched hop strength; >0 = a jump is committed (runs to completion)
var _hop_vary := 1.0       # per-hop random height multiplier (re-rolled each hop; anti-repetition)
var _hop_h := 0.52         # latched peak height for the current hop (drives arc AND its air time)
var _jump_active := false  # a real (Space) jump action is playing
var _jump_t := 0.0
var _jump_from_y := 0.0     # pose captured at jump start, to blend OUT of the walk cycle
var _jump_from_pitch := 0.0
var _jump_from_scale := 1.0
var _jump_scale := 1.0       # 1.0 stationary jump; jump_move_boost when launched while moving
var _jump_no_stretch := false # true = this jump keeps the body from elongating (squash only)
var _attack_active := false # a headbutt attack is playing
var _attack_t := 0.0
var _attack_from_y := 0.0   # height captured at attack start, to blend out of the walk
var _attack_from_pitch := 0.0     # pitch captured at attack start (blend out of the walk pose)
var _attack_from_scale := Vector3.ONE   # squash captured at attack start (blend out of the walk pose)
var _attack_contact_flip := 0.0   # flip angle (rad) frozen at contact, for the hit-stop pose
var _attack_checked := false # contact tested once at the ram
var _attack_hit := false     # true = rammed something -> recoil; false = miss -> follow through
var _attack_advance := 0.0   # body distance already carried forward on a miss
var _attack_target: Node = null  # what the ram will hit (damage dealt at contact)
var _hitstop_t := 0.0            # remaining hit-stop freeze time
var _attack_buffered := false    # a click landed mid-attack; fire one more the instant this ends
var _attack_style := 0           # which attack variant this swing is (spin axis): 0 somersault, 1 twirl, 2 roll
var _aim_target: Node3D = null   # target the headbutt locked onto (steer toward it during the windup)
var _attack_head: Node3D = null  # the detached HEAD that flies out to headbutt when the body is assembled
var _attack_detached := false    # this swing is a detached-head headbutt (torso stays planted)
enum DAtk { STRIKE, RECOVER, WALK, REATTACH }
var _datk := DAtk.STRIKE          # detached-head combo phase
var _datk_t := 0.0                # time in the current phase
var _datk_from := Vector3.ZERO    # world pos this phase's arc starts from
var _datk_anchor := Vector3.ZERO  # FIXED world spot the head fell to and fights from (stays put as the body moves)
var _head_pos := Vector3.ZERO     # head's tracked ground position while walking back to a far body
var _walk_phase := 0.0            # walk-back hop phase
var _walk_body_spd := 0.0         # smoothed peak body speed, so the walking head catches a running body
var _combo := 0                   # chained hits so far this session
var _datk_hit_done := false       # struck once this dive?
var _crouching := false          # Ctrl held: no hops — grounded wobble-slide (head keeps its size)
var _crouch_phase := 0.0
var _charging := false           # holding attack -> loading a charged headbutt
var _charge := 0.0               # 0..1 charge accumulated while held
var _attack_charge := 1.0        # charge the in-flight attack fired with (scales leap + damage)
var _charge_from_y := 0.0        # walk pose captured when charging starts (blend INTO the load)
var _charge_from_pitch := 0.0
var _charge_from_scale := Vector3.ONE
var _speed := 0.0
var _base_y := 0.0
var _grounded := false
var _gframe := 0
var _ground_target := 0.0     # model.position.y that seats the lowest visible part on the floor
var _ground_inited := false
var _reground := false        # animating a grounding change (a part attached) as a jump-into-place
var _settle_pending := false  # re-ground to the floor the next time the body is at rest (kills levitation)
var _reground_t := 0.0
var _reground_from := 0.0
var _skel: Skeleton3D = null  # the model's skeleton, for the segmented (part-sliding) squash
var _spine_bones: Array[int] = []   # head/neck/torso bones (NOT the root hips) to slide vertically
var _spine_rest: Array = []         # their rest local positions
var _lower_spine := -1              # bone 0 "Lowest spine." (root/hips) — coils the whole trunk
var _mid_spine := -1               # bone 1 "MId SPINE" (torso trunk) — bends on top of the base
var _lower_rest_rot := Quaternion.IDENTITY
var _mid_rest_rot := Quaternion.IDENTITY
var _head_rest_rot := Quaternion.IDENTITY   # to counter-rotate the head so the coil doesn't swing it
var _spine_swing := 0.0            # current coil amount (spring)
var _spine_swing_vel := 0.0
var _spine_y_prev := 0.0           # last node y, for the hop velocity that drives the coil
var _head_bone := -1          # the head bone — keeps its FULL mesh squash even when the torso barely scales
var _seg_squash := false      # true once >1 part is on -> squash slides the parts instead of scaling
var _crouch_crawl := false    # head+torso crouch: head-only crawling, torso/hips detached to trail
var _crouch_p := 0.0          # 0 upright/assembled .. 1 head fully down on the ground (drives the jump-off arc)
var _head_h := 0.0            # head's height above the floor when assembled (cached; how far it drops onto the ground)
var _idle_anim: Animation = null    # the GLB's "armature idle" clip, sampled for the little arms only
var _idle_arm_tracks: Array = []    # per little-arm bone: {bone, pos, rot, scl} track indices
var _idle_arm_t := 0.0        # playhead into the idle clip
var _idle_arm_w := 0.0        # 0 (rest / moving) .. 1 (full idle fidget), eased
var _arm_up_bones: Array = [] # little-arm SHOULDER bones + their "flung up" target rotation & mirror sign
var _vis_y_prev := 0.0        # last frame's visual height, for the reactive swing
var _arm_swing := 0.0         # signed inertia swing: + up (body dropping), - down (body rising); springs to 0
var _arm_swing_vel := 0.0
var _move_gate := 1.0      # 0..1 fraction of intended travel allowed this frame (0 = planted, recoiling)
var _intent := -1.0        # externally-set intended ground speed; <0 = fall back to the body velocity
var _orbit_active := false # spiralling into the body's neck socket to reattach
var _orbit_t := 0.0
var _orbit_center := Vector3.ZERO   # body's vertical axis (world XZ)
var _orbit_socket := Vector3.ZERO   # where the head seats (world)
var _orbit_r0 := 0.0                 # start radius / angle / height (so it works from ANY approach)
var _orbit_a0 := 0.0
var _orbit_h0 := 0.0
var _orbit_prev := Vector3.ZERO
var _orbit_arrival_dir := Vector3.ZERO   # horizontal motion direction as it seats (for the recoil)
var _orbit_arrival_yaw := 0.0            # WORLD yaw of the motion as it seats
var _orbit_socket_yaw := 0.0             # WORLD yaw the head should face when locked (the body's facing)
signal orbit_finished   # emitted the instant the head locks into the socket
var _detaching := false                  # leaping off the neck socket back to head-only
var _detach_t := 0.0
var _detach_start := Vector3.ZERO        # socket world (up on the body)
var _detach_land := Vector3.ZERO         # grounded home world (where it lands)
signal detach_finished   # emitted when it lands and head-only resumes


func _ready() -> void:
	_model = GLB.instantiate()
	add_child(_model)
	scale = Vector3.ONE * character_scale
	position.y += ground_offset
	_base_y = position.y
	_ap = _find_ap(_model)
	_apply_visibility(_model)
	# Do NOT play "head in armature" — its only motion is an Armature-root bob that would
	# drift the head up/down and sink it through the floor. Keep the head at its stable rest
	# pose; all the life comes from the procedural hop + squash below.
	if _ap != null and _ap.is_playing():
		_ap.stop()
	_skel = _find_skel(_model)
	_cache_spine()          # head/neck/torso bones for the segmented squash
	_cache_idle_arms()      # the little-arm idle fidget (sampled, not played)
	_update_seg_flag()
	_body = _find_body(self)
	# configure the owning body to traverse uneven/unstable terrain (walk + jump)
	if _body is CharacterBody3D:
		var cb := _body as CharacterBody3D
		cb.floor_snap_length = 0.6           # stay glued to the ground over bumps/downhill
		cb.floor_max_angle = deg_to_rad(55.0) # climb steeper slopes
		cb.floor_block_on_wall = false
		cb.slide_on_ceiling = true


func _apply_visibility(n: Node) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).visible = visible_parts.has(n.name)
	for c in n.get_children():
		_apply_visibility(c)


# Assembly progression: reveal a recovered part on the body (arm/leg). Re-grounds afterwards so a
# newly-added LOWER part (a leg) re-seats the body on its feet instead of poking through the floor.
func equip_part(part_name: String) -> bool:
	if visible_parts.has(part_name):
		return false
	visible_parts.append(part_name)
	if _model != null:
		_apply_visibility(_model)
		_update_seg_flag()   # torso now on -> squash slides the parts
		_ground_head()
	return true


func has_part(part_name: String) -> bool:
	return visible_parts.has(part_name)


# Where a part seats on the assembled body (its skinned centroid in world) — valid even while the
# part is still hidden, since the skeleton rest pose exists. A returning part orbits into this point.
func part_socket_world(part_name: String) -> Vector3:
	var skel := _find_skel(_model)
	var mi := _find_mesh(_model, part_name)
	if skel == null or mi == null or mi.skin == null or mi.mesh == null:
		return global_position + Vector3(0.0, 0.5, 0.0)
	var arr := mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var wts: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var skin := mi.skin
	var mats: Array[Transform3D] = []
	for bi in skin.get_bind_count():
		var b := skin.get_bind_bone(bi)
		if b < 0:
			b = bi
		mats.append(skel.get_bone_global_pose(b) * skin.get_bind_pose(bi))
	var sum := Vector3.ZERO
	var n := 0
	var step := maxi(1, verts.size() / 300)
	var i := 0
	while i < verts.size():
		var sk := Vector3.ZERO
		var per := bones.size() / maxi(verts.size(), 1)   # this rig is 8 bones/vertex, not 4
		for j in per:
			var w := wts[i * per + j]
			if w > 0.0001:
				sk += w * (mats[bones[i * per + j]] * verts[i])
		sum += sk
		n += 1
		i += step
	if n == 0:
		return global_position + Vector3(0.0, 0.5, 0.0)
	return skel.global_transform * (sum / n)


func _process(delta: float) -> void:
	# skinned-mesh transforms aren't valid on frame 0 — wait a few frames, then ground the head
	if not _grounded:
		_gframe += 1
		if _gframe < 3:
			return
		_ground_head()
		_grounded = true

	# A grounding change (a part just attached) plays out as the head JUMPING into its new, higher
	# perch — arcing up over the path and settling — so the body reads as building itself underneath.
	if _reground:
		_reground_t += delta
		var re := clampf(_reground_t / maxf(reground_dur, 0.01), 0.0, 1.0)
		var se := smoothstep(0.0, 1.0, re)
		var arc := maxf(_ground_target - _reground_from, 0.05) * reground_jump * sin(PI * re)
		_model.position.y = lerpf(_reground_from, _ground_target, se) + arc
		if re >= 1.0:
			_model.position.y = _ground_target
			_reground = false

	# REATTACH ORBIT owns the head entirely while it spirals into the body's socket
	if _orbit_active:
		_do_orbit_return(delta)
		return
	# DETACH owns the head while it leaps off the neck back to head-only
	if _detaching:
		_do_detach(delta)
		return

	var v := Vector3.ZERO
	if _body != null:
		var vv: Variant = _body.get("velocity")
		if vv is Vector3:
			v = vv
	# Drive the hop off the INTENDED speed, not the body's actual velocity: with hop-synced
	# movement the body is gated to a stop while recoiling, and reading that would make the
	# controller think we stopped and drop the hop mid-stride.
	var spd := _intent if _intent >= 0.0 else Vector3(v.x, 0.0, v.z).length()
	_speed = lerpf(_speed, spd, 1.0 - exp(-10.0 * delta))

	# little arms: idle-fidget when still, fling UP while falling, BOUNCE on landing, rest while moving.
	# Runs before the state branches (which don't touch the little-arm bones), so it survives returns.
	_do_little_arms(delta)
	_do_spine_expr(delta)   # lower + mid spine COIL with the hop for a more expressive torso walk

	# one-time clean re-ground once the assembled body is truly at rest, so the HIPS sit ON the floor
	# (the rest grounding was baked during the noisy assembly and can't read the skinless cloth hips)
	if _settle_pending and _seg_squash and _hop_amt <= 0.001 and not _jump_active and not _attack_active \
			and not _charging and not _crouching and _speed < 0.2:
		_settle_pending = false
		settle_to_floor()

	# real JUMP action owns the head while it plays (overrides hop/idle)
	if read_jump_input and Input.is_action_just_pressed("jump") and not _attack_active and not _charging:
		trigger_jump()
	if _jump_active:
		_do_jump(delta)
		return

	# ATTACK: HOLD Left-click to CHARGE (the head recoils more and more), RELEASE to fire.
	# More charge -> higher leap + more damage; a quick tap -> a weak headbutt.
	# During an active attack, a fresh click QUEUES the next combo hit (chained on the ground).
	if read_attack_input and not _jump_active:
		if _attack_active:
			if Input.is_action_just_pressed("attack"):
				trigger_attack()   # buffer the next combo hit
		elif Input.is_action_pressed("attack"):
			if not _charging:
				_begin_charge()
			_charge = minf(_charge + delta / maxf(attack_charge_time, 0.001), 1.0)
		elif _charging and not Input.is_action_pressed("attack"):
			_charging = false
			trigger_attack(_charge, true)   # release: fire straight from the loaded pose
			_charge = 0.0
	if _charging:
		_do_charge(delta)
		return
	if _attack_active:
		_do_attack(delta)
		# a detached-head combo only drives the HEAD; if the body is MOVING, fall through so the torso
		# keeps playing its WALK animation (the head is hidden/off attacking, so it's excluded)
		if not (_attack_detached and _speed > 0.2):
			return

	var moving := _speed > 0.2

	# CROUCH (Ctrl) — never engages mid-attack (the detached combo owns the head)
	if read_crouch_input and not _attack_active:
		_crouching = Input.is_physical_key_pressed(KEY_CTRL)
	# HEAD+TORSO crouch: the head JUMPS OFF the neck socket down onto the GROUND and crawls head-only;
	# the torso/hips/neck DETACH and the harness rolls them along behind it.
	var want_crawl := _crouching and _seg_squash
	_crouch_p = move_toward(_crouch_p, 1.0 if want_crawl else 0.0, delta / maxf(crouch_jump_time, 0.05))
	# stay "detached" (head-only, parts trailing) through the WHOLE transition — down AND back up — so the
	# hidden body isn't shown buried mid-arc; only re-attach once the head is fully home again
	# the harness hides/shows the body in lock-step with spawning/despawning the trailing parts, so the
	# body-mesh <-> loose-part swap has no 1-frame visibility gap; we only track the state here
	_crouch_crawl = want_crawl or _crouch_p > 0.001
	if _seg_squash and _model != null and _skel != null and _crouch_p > 0.0001:
		if _head_h <= 0.0:
			_head_h = _compute_head_h()
		# leap UP off the neck socket (sin arc), then settle down onto the FLOOR (drop -> head_h at p=1).
		# both terms are in the head's own (local) units so the leap actually clears the socket.
		var drop := _head_h * smoothstep(0.0, 1.0, _crouch_p)
		var leap := _head_h * crouch_jump_leap * sin(PI * _crouch_p)
		_model.position.y = _ground_target - drop + leap
	# head/head+torso crouch: grounded, no hops — the head rocks/sways (wobbles) as it slides
	if _crouching and not _attack_active:
		_hop_amt = 0.0   # drop any in-flight hop
		_do_crouch(delta, moving)
		return

	var strength := maxf(clampf(spd / (run_speed * 0.5), 0.0, 1.0), 0.35)   # raw speed -> full first hop

	# RUN blend: as speed climbs toward run_speed the walk hop morphs into a faster, more
	# forward-driving RUN gait (quicker cadence, deeper lean, more stretch, less ground contact).
	var run_t := smoothstep(run_speed * 0.6, run_speed, _speed)
	var e_hop_height := lerpf(hop_height, run_hop_height, run_t)
	var e_lean := lerpf(lean_deg, run_lean_deg, run_t)
	var e_fall_tilt := lerpf(fall_tilt_deg, run_fall_tilt_deg, run_t)
	var e_stretch := lerpf(jump_stretch, run_stretch, run_t)
	var e_gate_floor := lerpf(move_gate_floor, run_gate_floor, run_t)

	# start a jump when we're grounded and moving. Begin at the LAUNCH point (skip the
	# post-landing recoil, which assumes a prior landing) so the first hop after standing/
	# attacking/jumping pushes off cleanly from the ground instead of snapping to a braced pose.
	if _hop_amt <= 0.001 and moving:
		_jt = hop_spring_frac
		_hop_amt = strength
		_roll_hop_vary()
		_hop_h = e_hop_height * _hop_vary

	# A committed jump ALWAYS runs to completion — even if the player stops mid-air we let it
	# land instead of shrinking/reversing. Advance the clock; on landing, chain into the next
	# jump if still moving, otherwise drop the hop and settle to idle.
	if _hop_amt > 0.001:
		# The AIRBORNE arc is ballistic — it must take the same real time at ANY walk speed, or
		# slow walking plays the hop in slow-motion and the head hangs up top (the "floating").
		# So only the on-floor dwell between hops stretches when creeping: slow walk = little quick
		# hops with more ground contact, never a slow hang in the air.
		var air_now := _jt >= hop_spring_frac
		var clk := 1.0
		if air_now:
			clk = sqrt(hop_height / maxf(_hop_h * _hop_amt, 0.01))   # lower hop -> faster air, SAME fall rate
		elif moving:
			clk = clampf(_speed / run_speed, 0.7, 1.0)
		_jt += delta * hop_rate * clk
		if _jt >= 1.0:
			_jt = fposmod(_jt, 1.0)
			_hop_amt = strength if moving else 0.0
			if moving:
				_roll_hop_vary()
				_hop_h = e_hop_height * _hop_vary   # new hop -> new height (and thus air time)

	if _hop_amt > 0.001:
		# WALK HOP: a springy ground phase, then a smooth airborne arc with a rounded
		# (velocity-0) apex so rise->fall flows, and a landing compress that matches the
		# spring so the whole cycle is continuous.
		var p := _jt
		var y := 0.0
		var s := 1.0
		var pitch := deg_to_rad(e_lean)
		# hop-synced locomotion: EASE the forward speed with the hop instead of stopping dead —
		# it slows to move_gate_floor on the floor and glides at full speed airborne, all on one
		# smooth curve (floor=0 -> full stop while recoiling, floor=1 -> constant walk speed).
		if hop_synced_move:
			var glide := 0.0
			if p >= hop_spring_frac:
				var mp := (p - hop_spring_frac) / (1.0 - hop_spring_frac)
				glide = smoothstep(0.0, 0.22, mp) * (1.0 - smoothstep(0.80, 1.0, mp))
			_move_gate = lerpf(e_gate_floor, 1.0, glide)
		else:
			_move_gate = 1.0
		if p < hop_spring_frac:
			# planted: HOLD the compression to load the spring, then release into the launch
			var gp := p / hop_spring_frac                        # 0 landed .. 1 launch
			var rel := smoothstep(0.5, 1.0, gp)                  # 0 held-compressed .. 1 released
			s = 1.0 - land_squash * (1.0 - rel) * _hop_amt
			# organic recoil: it lands braced BACK (from the fall) and rocks FORWARD to push off
			pitch = lerpf(-deg_to_rad(e_fall_tilt), deg_to_rad(e_lean), smoothstep(0.0, 1.0, gp))
		else:
			# airborne: stretch tall; compress only as it nears the floor on the fall
			var ap := (p - hop_spring_frac) / (1.0 - hop_spring_frac)   # 0 launch .. 1 land
			var yn: float
			var comp := 0.0
			if ap < rise_frac:
				var rr := ap / rise_frac
				yn = sin(rr * PI * 0.5)                          # rise, easing INTO the apex
				# relax the forward lean toward neutral as it nears the apex (one smooth swing,
				# not a flat hold that snaps into the back-tilt at the top)
				pitch = deg_to_rad(e_lean) * (1.0 - smoothstep(0.0, 1.0, rr))
			else:
				var fp := (ap - rise_frac) / (1.0 - rise_frac)   # 0 apex -> 1 ground
				yn = cos(fp * PI * 0.5)                          # fall, easing OUT of the apex
				comp = clampf(1.0 - yn / 0.30, 0.0, 1.0)
				comp *= comp
				# lean progressively BACK through the descent, deepest as it lands (braces for
				# impact); the forward rock happens on the ground, so nothing flips at the apex
				pitch = -deg_to_rad(e_fall_tilt) * smoothstep(0.0, 1.0, fp)
			y = _hop_h * yn * _hop_amt
			# stretch scales with _hop_amt^2 so weak coast hops barely deform
			s = 1.0 + e_stretch * yn * _hop_amt * _hop_amt - land_squash * comp * _hop_amt
		position.y = _base_y + y
		# with a torso on, the whole-body fore/aft LEAN reads as too much tilt — dial it down and let the
		# subtle spine BEND (_do_spine_expr: back in air, forward on landing) carry the expression instead
		var tilt_k := torso_tilt_scale if _seg_squash else 1.0
		rotation.x = pitch * _hop_amt * tilt_k
		rotation.z = deg_to_rad(wobble_deg) * sin(p * TAU) * _hop_amt * tilt_k
		_set_squash(s)
	else:
		# resting on the floor — no lift, only a gentle breathing squash
		_move_gate = 1.0
		_phase += delta * TAU * 0.5
		var hb := absf(sin(_phase))
		position.y = _base_y
		rotation.x = lerp_angle(rotation.x, 0.0, 0.12)
		rotation.z = lerp_angle(rotation.z, 0.0, 0.12)
		# breathe DOWN only (never stretch); MUCH gentler once assembled so the head barely moves
		var iq := idle_squash * (body_idle_squash_frac if _seg_squash else 1.0)
		_set_squash(1.0 - iq * hb)


# --- external drive (the body's movement script reads these for hop-synced locomotion) -------

# Tell the controller how fast we INTEND to travel (used to keep the hop cadence alive even
# while the body is gated to a stop during the on-floor recoil).
func set_move_intent(speed: float) -> void:
	_intent = maxf(speed, 0.0)


# Fraction of intended horizontal travel to allow this frame (0 = planted/recoiling, 1 = gliding).
func move_gate() -> float:
	return _move_gate


# Shift the model so the visible head's LOWEST point sits at this node's origin — so the
# head rests on the floor and squash/stretch pivots at the ground-contact point. We measure
# the TRUE skinned geometry, NOT get_aabb(): the AABB is the bind-pose box, which can sit
# several units above where the skeleton's rest pose actually places the head (that gap was
# burying the head underground).
# Ask for a one-time re-ground the next time the body is fully at rest (the hips will end up on the floor).
func request_settle() -> void:
	_settle_pending = true


# Snap the model down so the LOWEST visible part (the hips, incl. the skinless cloth skirt) rests exactly
# on the floor — kills the levitation. Instant (no reground hop), meant to run at idle.
func settle_to_floor() -> void:
	if _skel == null or _model == null:
		return
	# Drop the model so the HIPS rest on the floor. Measure the actual rendered hips (world Y of its
	# verts) and seat a low PERCENTILE of them on the ground — that skips the few leg-"stump" verts that
	# dangle to the floor (grounding the raw lowest levitates the bulk) and the torso's stray verts.
	var mi := _find_mesh(_model, "hips")
	if mi == null or mi.mesh == null:
		return
	var v: PackedVector3Array = mi.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	if v.is_empty():
		return
	var ys := PackedFloat32Array()
	ys.resize(v.size())
	for i in v.size():
		ys[i] = (mi.global_transform * v[i]).y   # world Y of each hip vert
	ys.sort()
	var yp := ys[clampi(int(v.size() * settle_percentile), 0, v.size() - 1)]   # world Y to seat on the floor
	var wscale := maxf(global_transform.basis.get_scale().y, 0.001)
	_model.position.y -= (yp - ground_offset) / wscale   # lower the model so yp -> world 0
	_ground_target = _model.position.y
	_reground = false


func _ground_head() -> void:
	# Ground the LOWEST visible part on the floor, not just the head — so a head+torso body rests on
	# the torso's underside instead of burying it. (For head-only there's just "head", so unchanged.)
	var skel := _find_skel(_model)
	if skel == null:
		return
	var min_y := INF
	for pname in visible_parts:
		var mi := _find_mesh(_model, pname)
		if mi == null or mi.skin == null:
			continue
		min_y = minf(min_y, _skinned_min_y(mi, skel))
	if min_y == INF:
		return
	# model.position.y that seats the lowest visible part on the floor. min_y already includes the
	# current model offset, so this resolves to a stable absolute target regardless of an in-flight jump.
	var target := _model.position.y - min_y
	if not _ground_inited:
		_ground_inited = true
		_ground_target = target
		_model.position.y = target
		return
	if absf(target - _ground_target) < 0.002:
		return
	# the body grew (a part attached) -> the head JUMPS up into its new perch as the body fills in
	# beneath it, instead of the whole model snapping/teleporting to the taller pose
	_ground_target = target
	_reground_from = _model.position.y
	_reground_t = 0.0
	_reground = true


# How far the HEAD's underside sits above the floor when the body is assembled (grounded on the
# lowest part). That's exactly how far the head must drop to rest on the ground while crouch-crawling.
func _compute_head_h() -> float:
	if _skel == null or _model == null:
		return 0.0
	var head_mi := _find_mesh(_model, "head")
	if head_mi == null or head_mi.skin == null:
		return 0.0
	var lowest := INF
	for pname in visible_parts:
		var mi := _find_mesh(_model, pname)
		if mi != null and mi.skin != null:
			lowest = minf(lowest, _skinned_min_y(mi, _skel))
	if lowest == INF:
		return 0.0
	return maxf(0.0, _skinned_min_y(head_mi, _skel) - lowest)


# Lowest point of a skinned mesh (rest pose) in this node's local space, from the actual
# skinned vertices: pos = Σ weight_i · (boneGlobalPose_i · bindPose_i) · vertex.
func _skinned_min_y(mi: MeshInstance3D, skel: Skeleton3D) -> float:
	var arr := mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var wts: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var skin := mi.skin
	if verts.is_empty() or bones.is_empty() or skin == null:
		return INF
	var mats: Array[Transform3D] = []
	for bi in skin.get_bind_count():
		var bone_idx := skin.get_bind_bone(bi)
		if bone_idx < 0:
			bone_idx = bi
		mats.append(skel.get_bone_global_pose(bone_idx) * skin.get_bind_pose(bi))
	var xf := global_transform.affine_inverse() * skel.global_transform
	var min_y := INF
	for vi in verts.size():
		var v := verts[vi]
		var sk := Vector3.ZERO
		var per := bones.size() / maxi(verts.size(), 1)   # this rig is 8 bones/vertex, not 4
		for j in per:
			var w := wts[vi * per + j]
			if w > 0.0001:
				sk += w * (mats[bones[vi * per + j]] * v)
		min_y = minf(min_y, (xf * sk).y)
	return min_y


func _find_skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var r := _find_skel(c)
		if r != null:
			return r
	return null


func _find_mesh(n: Node, want: String) -> MeshInstance3D:
	if n is MeshInstance3D and n.name == want:
		return n as MeshInstance3D
	for c in n.get_children():
		var r := _find_mesh(c, want)
		if r != null:
			return r
	return null


# Give the next hop a fresh random height so the walk cycle doesn't look repetitive.
func _roll_hop_vary() -> void:
	_hop_vary = 1.0 + randf_range(-hop_height_variation, hop_height_variation)


func set_crouch(on: bool) -> void:
	_crouching = on


func is_crouching() -> bool:
	return _crouching


# Crouch locomotion: grounded, NO hops, NO squash — the head just rocks/sways (wobbles) as it
# slides. The wobble runs off movement so it's still when you stop.
func _do_crouch(delta: float, moving: bool) -> void:
	_move_gate = 1.0                                                          # slide continuously, no hop cadence
	position.y = lerpf(position.y, _base_y, 1.0 - exp(-15.0 * delta))         # ease to the ground (in case mid-hop)
	position.z = 0.0
	if moving:
		_crouch_phase += delta * crouch_wobble_rate * clampf(_speed / run_speed, 0.35, 1.0)
		var w := sin(_crouch_phase)
		rotation.z = deg_to_rad(crouch_wobble_deg) * w                        # rock side to side
		rotation.x = deg_to_rad(crouch_lean_deg) + deg_to_rad(crouch_bob_deg) * sin(_crouch_phase * 2.0)
		position.x = crouch_sway * w                                         # sway with the roll
	else:
		# crouched idle — settle to a low, still pose
		rotation.z = lerp_angle(rotation.z, 0.0, 0.15)
		rotation.x = lerp_angle(rotation.x, deg_to_rad(crouch_lean_deg), 0.15)
		position.x = lerpf(position.x, 0.0, 0.15)
	_set_squash(1.0)   # keep full size — no compression


# true while a head+torso is crouch-crawling (head-only; the harness trails the detached parts)
func is_crouch_crawling() -> bool:
	return _crouch_crawl


# 0 = fully standing/assembled .. 1 = head fully down on the ground. Falls back to 0 while standing up,
# so the harness can time the parts flying home to the body against it.
func crouch_phase() -> float:
	return _crouch_p


# The detached parts the harness should roll behind the head (everything on the body except the head).
func crouch_trail_parts() -> Array:
	var out := []
	for p in visible_parts:
		if p != "head":
			out.append(p)
	return out


# Harness-driven: hide the body (show ONLY the head) while its parts are detached and trailing, or
# restore the assembled body. Called in sync with the trailing parts so there's no gap at the seam.
func set_body_hidden(hidden: bool) -> void:
	if _model == null:
		return
	_apply_crouch_vis(_model, hidden)


func _apply_crouch_vis(n: Node, crawl: bool) -> void:
	if n is MeshInstance3D:
		var m := n as MeshInstance3D
		m.visible = (m.name == "head") if crawl else visible_parts.has(m.name)
	for c in n.get_children():
		_apply_crouch_vis(c, crawl)


func is_orbiting() -> bool:
	return _orbit_active


func is_detaching() -> bool:
	return _detaching


# Public: leap the head OFF the neck socket back to head-only. socket_world = where it starts
# (up on the body); the parent (body) should already be moved to the landing spot on the ground.
func trigger_detach(socket_world: Vector3) -> void:
	if _detaching:
		return
	_detaching = true
	_detach_t = 0.0
	_detach_start = socket_world
	var par := get_parent()
	# grounded "home" = where head-only would rest now that the body sits at the landing spot
	_detach_land = (par as Node3D).global_transform * Vector3(0.0, _base_y, 0.0) if par is Node3D else socket_world


func _do_detach(delta: float) -> void:
	_detach_t += delta
	var e := smoothstep(0.0, 1.0, _detach_t / maxf(detach_duration, 0.01))
	var pos := _detach_start.lerp(_detach_land, e)
	pos.y += detach_jump * sin(PI * e)                          # a leap-up arc on top of the drop to the ground
	global_position = pos
	rotation = Vector3(TAU * detach_turns * e * attack_forward_sign, 0.0, 0.0)   # somersault off
	var s := 1.0 + jump_stretch * sin(PI * e) * 0.6            # stretch through the leap
	var inv := 1.0 / sqrt(s)
	scale = Vector3(character_scale * inv, character_scale * inv, character_scale * s)
	if _detach_t >= detach_duration:
		_detaching = false
		position = Vector3(0.0, _base_y, 0.0)   # snap to the grounded head-only home
		rotation = Vector3.ZERO
		scale = Vector3.ONE * character_scale
		_hop_amt = 0.0
		detach_finished.emit()


# Public: spiral the head into the body's neck socket. center_world = the body's vertical axis,
# socket_world = where the head seats, socket_yaw = the body's WORLD facing (so the head ends
# aligned to the body, not to wherever the player last faced). Works from any approach angle.
func trigger_orbit_return(center_world: Vector3, socket_world: Vector3, socket_yaw: float = 0.0) -> void:
	if _orbit_active:
		return
	_orbit_active = true
	_orbit_t = 0.0
	_orbit_center = Vector3(center_world.x, 0.0, center_world.z)
	_orbit_socket = socket_world
	_orbit_socket_yaw = socket_yaw
	var hp := global_position
	_orbit_h0 = hp.y
	var off := Vector3(hp.x - _orbit_center.x, 0.0, hp.z - _orbit_center.z)
	_orbit_r0 = maxf(off.length(), orbit_min_radius)   # always big enough to actually circle
	_orbit_a0 = atan2(off.z, off.x)
	_orbit_prev = hp


# Spiral in: sweep around the body, pull the radius to 0 and rise to the socket. The head faces
# its own velocity and STRETCHES along it (G-force of the whip-around), relaxing as it seats.
func _do_orbit_return(delta: float) -> void:
	_orbit_t += delta
	# the head lives under the moving body, so convert a desired WORLD yaw into our local yaw
	var parent_yaw := 0.0
	var par := get_parent()
	if par is Node3D:
		parent_yaw = (par as Node3D).global_rotation.y
	if _orbit_t < orbit_duration:
		# SPIRAL IN — sweep around the body, pull to the socket, stretch along the motion
		var e := smoothstep(0.0, 1.0, _orbit_t / maxf(orbit_duration, 0.01))
		var angle := _orbit_a0 + orbit_turns * TAU * e
		var radius := lerpf(_orbit_r0, 0.02, e)
		var y := lerpf(_orbit_h0, _orbit_socket.y, e)
		var pos := _orbit_center + Vector3(cos(angle) * radius, y, sin(angle) * radius)
		var vel := (pos - _orbit_prev) / maxf(delta, 0.001)
		_orbit_prev = pos
		global_position = pos
		var flat := Vector3(vel.x, 0.0, vel.z)
		if flat.length() > 0.05:
			_orbit_arrival_yaw = atan2(flat.x, flat.z)   # WORLD heading; keep the last real one for the recoil
			_orbit_arrival_dir = flat.normalized()
		rotation = Vector3(0.0, _orbit_arrival_yaw - parent_yaw, 0.0)   # face motion (in world)
		var s := 1.0 + orbit_stretch * clampf(vel.length() / orbit_ref_speed, 0.0, 1.0) * (1.0 - e)
		var inv := 1.0 / sqrt(s)
		scale = Vector3(character_scale * inv, character_scale * inv, character_scale * s)
	else:
		# SETTLE — carry the momentum a hair past the socket, jiggle it out (damped), and LOCK,
		# turning to face the BODY's facing (socket_yaw) so it ends square, not looking to the side
		var st := clampf((_orbit_t - orbit_duration) / maxf(orbit_settle_duration, 0.01), 0.0, 1.0)
		var env := (1.0 - st) * exp(-st * 5.0)                 # decays cleanly to 0 at st=1
		var osc := sin(st * TAU * orbit_recoil_wobbles)
		global_position = _orbit_socket + _orbit_arrival_dir * (orbit_recoil_dist * env * osc)
		var want_yaw := lerp_angle(_orbit_arrival_yaw, _orbit_socket_yaw, smoothstep(0.0, 1.0, st))
		# LEAN opposite the arrival momentum (base overshoots, head lags back), rocking out as it
		# seats — the energy transitions instead of vanishing. Decompose the momentum into the
		# body's own frame so a forward arrival -> pitch, a sideways arrival -> roll.
		var fwd := Vector3(sin(_orbit_socket_yaw), 0.0, cos(_orbit_socket_yaw))
		var right := Vector3(cos(_orbit_socket_yaw), 0.0, -sin(_orbit_socket_yaw))
		var lean := deg_to_rad(orbit_lean_deg) * env * osc
		rotation = Vector3(-lean * _orbit_arrival_dir.dot(fwd), want_yaw - parent_yaw, -lean * _orbit_arrival_dir.dot(right))
		var s := maxf(1.0 - orbit_recoil_squash * env * absf(osc), 0.5)   # squash on each jiggle
		var inv := 1.0 / sqrt(s)
		scale = Vector3(character_scale * inv, character_scale * s, character_scale * inv)
		if _orbit_t >= orbit_duration + orbit_settle_duration:
			_orbit_active = false
			rotation = Vector3(0.0, _orbit_socket_yaw - parent_yaw, 0.0)   # locked, square to the body
			scale = Vector3.ONE * character_scale
			global_position = _orbit_socket
			orbit_finished.emit()


# Public: start a real jump (call from AI/code; the player also triggers this on Space).
func trigger_jump(scale_override: float = 0.0, no_stretch: bool = false) -> void:
	if not _jump_active:
		_jump_no_stretch = no_stretch
		# capture the CURRENT pose (wherever the walk hop is) so the jump blends out of it
		# instead of snapping to its ground-crouch — no "cut" when jumping mid-animation
		_jump_from_y = position.y - _base_y
		_jump_from_pitch = rotation.x
		_jump_from_scale = (scale.y / character_scale) if character_scale > 0.0 else 1.0
		_jump_active = true
		_jump_t = 0.0
		_hop_amt = 0.0     # drop any in-progress hop so it starts clean after landing
		_jt = 0.0
		# scale_override drives a big scripted leap (e.g. the reassembly jump); otherwise a jump
		# launched WHILE MOVING (Space + WASD) goes higher AND longer
		if scale_override > 0.0:
			_jump_scale = scale_override
		else:
			_jump_scale = jump_move_boost if _speed > 0.2 else 1.0


# A full, deformed jump: anticipation crouch -> launch -> apex hang -> fast fall (head thrown
# back) -> hard impact squash -> spring-back recovery. Volume-preserving squash/stretch
# throughout gives the head weight and a realistic feel.
func _do_jump(delta: float) -> void:
	_move_gate = 1.0   # normal air control during a real jump (not gated to the hop cadence)
	_jump_t += delta
	var t_ant := jump_anticipate
	var t_rec := jump_recover
	var t_air := maxf(0.1, jump_duration - t_ant - t_rec) * _jump_scale   # longer arc when moving
	var total := t_ant + t_air + t_rec
	var h := jump_height * _jump_scale                                    # higher when moving
	var y := 0.0
	var s := 1.0
	var pitch := 0.0

	if _jump_t < t_ant:
		# anticipation: crouch down before the launch
		var u := _jump_t / t_ant
		s = 1.0 - jump_crouch * sin(u * PI * 0.5)
	elif _jump_t < t_ant + t_air:
		# airborne: a BRIEF launch stretch that settles to normal well before the apex (so the
		# head isn't held stretched through the hang), then a fall stretch that builds into the
		# impact squash. Stretch is tied to SPEED, not height, so it's on only during the fast bits.
		var air_p := (_jump_t - t_ant) / t_air
		var yn: float
		if air_p < jump_rise_frac:
			var rr := air_p / jump_rise_frac
			yn = sin(rr * PI * 0.5)                            # rise, decelerating to the apex
			var rel := smoothstep(0.0, 0.10, rr)              # release out of the anticipation crouch
			var burst := jump_stretch * rel * (1.0 - smoothstep(0.10, jump_stretch_hold, rr))
			s = lerpf(1.0 - jump_crouch, 1.0, rel) + burst    # squash -> quick stretch burst -> normal
		else:
			var fp := (air_p - jump_rise_frac) / (1.0 - jump_rise_frac)  # 0 apex -> 1 ground
			yn = cos(fp * PI * 0.5)                            # fall, accelerating down
			var contact := clampf(1.0 - yn / 0.30, 0.0, 1.0)
			contact *= contact
			# normal at the apex, stretch as it speeds up, then squash into the impact
			s = 1.0 + jump_stretch * sin(fp * PI * 0.5) * (1.0 - contact) - jump_crouch * contact
		y = h * yn
		# backward tilt over the WHOLE arc: forward at launch, begins reclining at jump_tilt_start
		# (before the apex), eases to full back by landing
		pitch = lerpf(deg_to_rad(lean_deg), -deg_to_rad(jump_tilt_deg), smoothstep(jump_tilt_start, 1.0, air_p))
	else:
		# landing: spring back up from the impact squash
		var u := clampf((_jump_t - t_ant - t_air) / t_rec, 0.0, 1.0)
		s = 1.0 - jump_crouch * (1.0 - u) * (1.0 - u)
		if _jump_t >= total:
			_jump_active = false
			_hop_amt = 0.0

	# lean into the direction of travel so steering (WASD) reads while airborne
	var mlean := 0.0
	if _body != null:
		var bv: Variant = _body.get("velocity")
		if bv is Vector3:
			var hs := Vector3((bv as Vector3).x, 0.0, (bv as Vector3).z).length()
			mlean = deg_to_rad(jump_move_lean_deg) * clampf(hs / run_speed, 0.0, 1.0)
	# a scripted jump (e.g. the reassembly leap) can forbid elongation so the body doesn't stretch
	# on the way down / at the end — keep the squash (weight), just clamp any stretch (s>1) away
	if _jump_no_stretch:
		s = minf(s, 1.0)
	# blend from the captured walk pose into the jump over the anticipation -> smooth entry (no cut)
	var blend := clampf(_jump_t / maxf(0.001, jump_anticipate), 0.0, 1.0)
	position.y = _base_y + lerpf(_jump_from_y, y, blend)
	rotation.x = lerpf(_jump_from_pitch, pitch + mlean, blend)
	rotation.z = 0.0
	_set_squash(lerpf(_jump_from_scale, s, blend))


# Public: charge state, for a UI charge bar (the harness/game draws it).
func is_charging() -> bool:
	return _charging


func charge_ratio() -> float:
	return _charge


# Begin loading a charged headbutt (player holds Left-click). The head recoils, deepening
# with the charge; releasing fires trigger_attack(charge, true).
func _begin_charge() -> void:
	if _attack_active or _jump_active:
		return
	_charging = true
	_charge = 0.0
	_charge_from_y = position.y - _base_y
	_charge_from_pitch = rotation.x
	_charge_from_scale = scale
	_hop_amt = 0.0   # drop the walk hop; we plant to load
	_aim_target = _find_aim_target()   # lock the nearest thing in front so the charge turns to face it


# Hold the loading pose: rear back / draw back / compress, all deepening with the charge.
func _do_charge(delta: float) -> void:
	_move_gate = 0.0   # planted while loading
	_steer_to_aim(delta)   # turn to face the locked target as we load
	var cf := lerpf(0.6, 1.4, _charge)                       # windup depth grows with charge
	var rear := deg_to_rad(attack_windup_tilt) * cf
	var lift := attack_charge_lift * cf                       # keep the reared-back head ON the floor (not under)
	var loadd := attack_load * cf
	var s := maxf(1.0 - loadd, 0.4)                          # <1 = squashed DOWN into the ground
	var b := smoothstep(0.0, 0.15, _charge)                  # ease out of the walk pose
	position.y = lerpf(_base_y + _charge_from_y, _base_y + lift, b)
	position.z = lerpf(0.0, attack_forward_sign * -attack_reach * attack_coil * cf, b)
	scale = _charge_from_scale.lerp(_attack_deform(s), b)
	rotation.x = lerp_angle(_charge_from_pitch, -rear * attack_forward_sign, b)
	rotation.z = lerp_angle(rotation.z, 0.0, 0.3)


# Public: start a headbutt. charge (0..1) scales the leap height + damage; skip_windup fires
# straight from the loaded pose (used on charge release; AI can call with defaults).
func trigger_attack(charge: float = 1.0, skip_windup: bool = false) -> void:
	if _jump_active:
		return
	if _attack_active:
		_attack_buffered = true   # queue one more; it fires the instant this attack ends (combo chain)
		return
	_attack_active = true
	_attack_charge = clampf(charge, 0.0, 1.0)
	_aim_target = _find_aim_target()   # (re)lock the nearest target in front EACH swing (never a stale lock)
	# ASSEMBLED: the HEAD pops out of the socket and runs the EXACT SAME lunge as head-only (same
	# somersault + forward travel), retargeted from the socket; the torso stays planted, then the head
	# returns home when the lunge ends. NOT assembled: the whole node runs the lunge (the lone head).
	# ASSEMBLED: don't run the whole body through the headbutt — the HEAD pops out of the socket, strikes,
	# and flies home while the torso stays planted. Always play the full arc (pop-out included).
	_attack_detached = _seg_squash
	if _attack_detached:
		_ensure_attack_head()
		_set_head_hidden(true)             # hide the body's head; the flying head replaces it seamlessly
		_attack_t = 0.0
		# start the combo: the head leaps OFF the socket and FALLS to a fixed world spot out front,
		# where it stays and fights even as the body wanders off
		var _sk := part_socket_world("head")
		var _fw := _attack_world_fwd()
		if _fw == Vector3.ZERO:
			_fw = (-_body.global_transform.basis.z).normalized() if _body != null else Vector3.FORWARD
		_datk = DAtk.STRIKE
		_datk_t = 0.0
		_datk_from = _sk
		# anchor the fight spot to the FLOOR (not the socket, which bobs while walking -> the head would float)
		var _fl := _floor_y(_body.global_position) if _body != null else 0.0
		_datk_anchor = Vector3(_sk.x + _fw.x * attack_reach, _fl + head_ground_clear, _sk.z + _fw.z * attack_reach)
		_datk_hit_done = false
		_combo = 0
	else:
		_attack_t = (attack_windup * attack_duration) if skip_windup else 0.0   # skip the windup if pre-loaded
	_attack_from_y = position.y - _base_y   # capture the pose to blend OUT of it (no snap)
	_attack_from_pitch = rotation.x
	_attack_from_scale = scale
	_attack_checked = false
	_attack_hit = false
	_attack_advance = 0.0
	_attack_target = null
	_hitstop_t = 0.0
	_attack_buffered = false
	# pick a fresh attack variant for variety — a different one than the last swing
	var n := maxi(attack_style_count, 1)
	if n > 1:
		_attack_style = (_attack_style + 1 + (randi() % (n - 1))) % n
	else:
		_attack_style = 0


# The lunge's spin, applied to a different axis per attack variant so each swing reads distinct:
# 0 = forward SOMERSAULT (pitch), 1 = horizontal TWIRL (yaw), 2 = BARREL ROLL (roll).
func _apply_attack_rotation(ang: float) -> void:
	match _attack_style:
		1:
			rotation = Vector3(0.0, ang, 0.0)
		2:
			rotation = Vector3(0.0, 0.0, ang)
		_:
			rotation = Vector3(ang, 0.0, 0.0)


# Volume-preserving attack deform. COMPRESSION (f<1) squashes DOWN into the ground (short Y,
# bulge X/Z — the load/crouch). STRETCH (f>1) elongates FORWARD like a battering ram (long Z,
# thin X/Y — the lunge). One scalar picks the axis by whether we're compressing or stretching.
func _attack_deform(f: float) -> Vector3:
	var inv := 1.0 / sqrt(f)
	if f >= 1.0:
		return Vector3(character_scale * inv, character_scale * inv, character_scale * f)   # forward stretch
	return Vector3(character_scale * inv, character_scale * f, character_scale * inv)        # vertical squash


# Jump-forward HEADBUTT: coil/crouch -> leap up & forward (stretching like a battering ram) ->
# SLAM down & forward into the target (chomp squash on impact) -> recover back. All phase
# boundaries match so the motion is continuous; deformation carries the ram + impact.
func _do_attack(delta: float) -> void:
	if _attack_detached:
		_do_attack_detached(delta)   # assembled: only the HEAD flies out & back; torso stays planted
		return
	_move_gate = 1.0   # the attack drives the body itself; don't also gate it to the hop cadence
	if _hitstop_t > 0.0:
		# HIT-STOP: freeze jammed against the target (crushed) for a punchy impact
		_hitstop_t -= delta
		var cs := maxf(0.35, 1.0 - attack_impact_crush)
		var cinv := 1.0 / sqrt(cs)
		position.y = _base_y + attack_hop * lerpf(attack_min_power, 1.0, _attack_charge)
		position.z = attack_forward_sign * attack_reach
		scale = Vector3(character_scale * cinv, character_scale * cinv, character_scale * cs)
		_apply_attack_rotation(_attack_contact_flip * attack_forward_sign)   # frozen mid-spin on this variant's axis
		return
	_attack_t += delta
	var au := clampf(_attack_t / attack_duration, 0.0, 1.0)
	var fwd := 0.0     # forward reach (metres, + = forward)
	var up := 0.0      # vertical offset (metres, + = up)
	var zs := 1.0      # forward stretch factor
	var flip := 0.0    # full pitch rotation (rad) for the somersault; only meaningful in the lunge
	var flipping := false
	var cf := lerpf(0.6, 1.4, _attack_charge)          # load depth (matches _do_charge so release is seamless)
	var rear := deg_to_rad(attack_windup_tilt) * cf    # rear-back angle the flip springs from
	var draw := attack_reach * attack_coil * cf        # how far it was drawn back
	var lift := attack_charge_lift * cf                # load baseline lifts to keep it grounded
	var loadd := attack_load * cf
	var hop := attack_hop * lerpf(attack_min_power, 1.0, _attack_charge)   # leap height scales with charge
	if au < attack_windup:
		# anticipation: draw BACK, crouch and compress — loading the headbutt like the walk's
		# ground coil before it springs forward (the rear-back tilt is applied to pitch below)
		_steer_to_aim(delta)   # keep tracking the target through the windup so the lunge lands
		var wu := smoothstep(0.0, 1.0, au / attack_windup)
		fwd = -draw * wu
		up = lift * wu
		zs = 1.0 - loadd * wu
	else:
		flipping = true
		var t := (au - attack_windup) / (1.0 - attack_windup)
		# decide hit vs miss ONCE, at the start of the lunge
		if not _attack_checked:
			_attack_checked = true
			_attack_target = _raycast_target()
			_attack_hit = _attack_target != null
		var contact_flip := PI * 0.55   # how far into the flip the forehead connects with the target
		if _attack_hit:
			# HIT: flip forward INTO the target; on contact STOP mid-flip (hit-stop), then REVERSE
			# the flip and fall back down to the original spot.
			var t_contact := 0.34
			if t < t_contact:
				var lt := smoothstep(0.0, 1.0, t / t_contact)
				fwd = lerpf(-draw, attack_reach, lt)
				up = lerpf(lift, hop, lt)
				zs = lerpf(1.0 - loadd, 1.0 + attack_stretch, lt)
				flip = lerpf(-rear, contact_flip, lt)
			elif _attack_target != null:
				# IMPACT: damage + freeze mid-flip crushed on the target (hit-stop) + camera shake
				if is_instance_valid(_attack_target) and _attack_target.has_method("take_damage"):
					_attack_target.take_damage(clampi(int(round(lerpf(1.0, float(attack_damage), _attack_charge))), 1, attack_damage), _body.global_position, self)
				hit_landed.emit()
				_attack_contact_flip = contact_flip
				_hitstop_t = attack_hitstop
				_attack_target = null
				return
			else:
				# REVERSE: unwind the flip back to upright and fall back home to (0,0)
				var rt := (t - t_contact) / (1.0 - t_contact)
				fwd = lerpf(attack_reach, 0.0, smoothstep(0.0, 1.0, sqrt(clampf(rt, 0.0, 1.0))))
				up = hop * (1.0 - rt * rt)
				zs = lerpf(1.0 - attack_impact_crush, 1.0, smoothstep(0.0, 1.0, rt))
				flip = lerpf(contact_flip, 0.0, smoothstep(0.0, 1.0, rt))
		else:
			# MISS: a full forward SOMERSAULT (360 * attack_flip_turns) carried forward
			var mhop := attack_flip_height * lerpf(attack_min_power, 1.0, _attack_charge)   # HIGH flourish apex
			flip = lerpf(-rear, TAU * attack_flip_turns, smoothstep(0.0, 1.0, t))
			# leap up high, then land at the new forward spot
			if t < 0.45:
				up = lerpf(lift, mhop, smoothstep(0.0, 1.0, t / 0.45))
			else:
				up = mhop * (1.0 - smoothstep(0.0, 1.0, (t - 0.45) / 0.55))
			# release the draw-back to centre, then let the body carry the roll forward
			fwd = lerpf(-draw, 0.0, smoothstep(0.0, 1.0, minf(t / 0.3, 1.0)))
			zs = 1.0 + attack_stretch * sin(PI * clampf(t, 0.0, 1.0)) * 0.6
			var adv := attack_reach * smoothstep(0.0, 1.0, t)
			if _body != null:
				_body.global_position += _attack_world_fwd() * (adv - _attack_advance)
			_attack_advance = adv
	zs = maxf(zs, 0.4)
	var entry := clampf(au / maxf(0.001, attack_windup), 0.0, 1.0)   # blend the pose in over the windup
	position.y = _base_y + lerpf(_attack_from_y, up, entry)
	position.z = attack_forward_sign * fwd                           # forward = the head's facing (+Z here)
	scale = _attack_from_scale.lerp(_attack_deform(zs), entry)       # squash DOWN to load, stretch FORWARD to ram
	if flipping:
		_apply_attack_rotation(flip * attack_forward_sign)   # spin on this variant's axis
	else:
		# windup: rear back, blending OUT of the captured walk pose so a mid-stride attack doesn't snap
		var pt := -rear * attack_forward_sign * smoothstep(0.0, 1.0, au / attack_windup)
		rotation = Vector3(lerp_angle(_attack_from_pitch, pt, entry), 0.0, 0.0)
	if _attack_t >= attack_duration:
		_attack_active = false
		position.z = 0.0
		rotation = Vector3.ZERO   # end upright (clear any residual spin on any axis)
		if _attack_buffered:
			trigger_attack()   # chain straight into the next attack — no walk-hop pop between rapid clicks
		else:
			_hop_amt = 0.0   # drop the frozen hop so the walk restarts cleanly from a launch (no mid-air snap)


func is_attacking() -> bool:
	return _attack_active or _charging


# Nearest "attack_targets" node within range and inside the forward aim cone (or null for none).
func _find_aim_target() -> Node3D:
	if _body == null:
		return null
	var fwd := _attack_world_fwd()
	if fwd == Vector3.ZERO:
		return null
	var best: Node3D = null
	var best_d := attack_aim_range
	for t in get_tree().get_nodes_in_group("attack_targets"):
		if not (t is Node3D):
			continue
		var to: Vector3 = (t as Node3D).global_position - _body.global_position
		to.y = 0.0
		var d := to.length()
		if d < 0.05 or d > attack_aim_range:
			continue
		if rad_to_deg(fwd.angle_to(to / d)) > attack_aim_cone_deg:
			continue
		if d < best_d:
			best_d = d
			best = t as Node3D
	return best


# During the windup, swing the body to face the locked target so the straight lunge connects.
func _steer_to_aim(delta: float) -> void:
	if _body == null or _aim_target == null or not is_instance_valid(_aim_target):
		return
	var to: Vector3 = _aim_target.global_position - _body.global_position
	to.y = 0.0
	if to.length() < 0.05:
		return
	var want := atan2(to.x, to.z)   # same facing convention as the harness
	_body.rotation.y = lerp_angle(_body.rotation.y, want, clampf(attack_aim_turn * delta, 0.0, 1.0))


# ASSEMBLED HEADBUTT: the head POPS out of the neck socket, RAMS forward (pitching over), and flies
# BACK into the socket — the torso stays planted the whole time. Driven in world space about the
# head's socket so it reads as the head leaping off the body and returning.
func _do_attack_detached(delta: float) -> void:
	_move_gate = 1.0
	if _speed <= 0.2:
		# stationary -> the torso stays planted at rest while the head does the work
		position.y = lerpf(position.y, _base_y, 1.0 - exp(-14.0 * delta))
		position.z = 0.0
		rotation.x = lerp_angle(rotation.x, 0.0, 0.25)
		rotation.z = lerp_angle(rotation.z, 0.0, 0.25)
		_set_squash(1.0)
	# (moving -> the walk animation in _process drives the torso; the body is FREE to wander. The head
	#  fights at its fixed anchor and, if left behind, walks after the body on its own.)
	var socket := part_socket_world("head")   # the head's home on the (possibly moving) body
	var fwd := _attack_world_fwd()
	if fwd == Vector3.ZERO:
		fwd = (-_body.global_transform.basis.z).normalized() if _body != null else Vector3.FORWARD
	var right := fwd.cross(Vector3.UP).normalized()

	_datk_t += delta
	match _datk:
		DAtk.STRIKE:
			# leap off (socket, hit 1) or bounce up (anchor, chained) and DIVE — a full somersault,
			# like the lone head's headbutt — landing back at the FIXED anchor (never follows the body)
			var t := clampf(_datk_t / maxf(combo_strike_time, 0.01), 0.0, 1.0)
			var te := smoothstep(0.0, 1.0, t)
			var pos := _datk_from.lerp(_datk_anchor, te) + Vector3.UP * (combo_leap * sin(PI * te))
			_place_attack_head_spin(pos, right, fwd, TAU * te)
			if not _datk_hit_done and t >= 0.5:
				_datk_hit_done = true
				_try_hit_detached()
			if _datk_t >= combo_strike_time:
				_datk = DAtk.RECOVER
				_datk_t = 0.0
		DAtk.RECOVER:
			# on the ground at the anchor. If the BODY wandered too far -> walk after it; else chain the
			# next dive if queued; else, when the window elapses, hop home
			_place_attack_head_spin(_datk_anchor + Vector3.UP * (0.03 * sin(_datk_t * 12.0)), right, fwd, 0.0)
			var body_gap := Vector2(socket.x - _datk_anchor.x, socket.z - _datk_anchor.z).length()
			if body_gap > reattach_jump_dist:
				_head_pos = _datk_anchor
				_walk_phase = 0.0
				_datk = DAtk.WALK
				_datk_t = 0.0
			elif _attack_buffered and (_combo + 1) < combo_max:
				_attack_buffered = false
				_combo += 1
				_attack_style = (_attack_style + 1) % maxi(attack_style_count, 1)   # vary the spin each hit
				_datk_from = _datk_anchor
				_datk_hit_done = false
				_datk = DAtk.STRIKE
				_datk_t = 0.0
			elif _datk_t >= combo_recover_time:
				_attack_buffered = false
				_datk_from = _datk_anchor
				_datk = DAtk.REATTACH
				_datk_t = 0.0
		DAtk.WALK:
			# too far to hop back on — chase the body with the head-only WALK (hop + squash/stretch + lean).
			# When the body RUNS, speed the head up so it can actually catch a moving target.
			var to := Vector3(socket.x - _head_pos.x, 0.0, socket.z - _head_pos.z)
			var gap := to.length()
			var body_spd := 0.0
			if _body != null:
				body_spd = maxf(Vector2(_body.velocity.x, _body.velocity.z).length(), _speed)
			_walk_body_spd = maxf(_walk_body_spd * exp(-3.0 * delta), body_spd)   # hold the recent peak (robust to frame jitter)
			var walk_spd := maxf(head_walk_speed, _walk_body_spd * head_catch_up_mult)
			if gap > 0.001:
				_head_pos += to / gap * minf(walk_spd * delta, gap)
			_walk_phase += delta * head_walk_hop_rate * clampf(walk_spd / maxf(head_walk_speed, 0.01), 1.0, 2.5)
			var hop_n := absf(sin(_walk_phase * PI))          # 0 on the ground .. 1 at the apex
			var wy := _datk_anchor.y + head_walk_hop * hop_n
			var s := 1.0 + head_walk_stretch * hop_n - head_walk_squash * (1.0 - hop_n)   # stretch airborne, squash on landing
			var pitch := deg_to_rad(head_walk_lean) * cos(_walk_phase * PI)                # lean forward launching, brace back landing
			_place_attack_head_walk(Vector3(_head_pos.x, wy, _head_pos.z), to, s, pitch)
			if gap <= reattach_jump_dist * 0.8:
				_datk_from = Vector3(_head_pos.x, _datk_anchor.y, _head_pos.z)
				_datk = DAtk.REATTACH
				_datk_t = 0.0
		DAtk.REATTACH:
			# HEAD-BACK-TO-TORSO: jump from the ground up onto the (live) socket and re-attach
			var t := clampf(_datk_t / maxf(combo_return_time, 0.01), 0.0, 1.0)
			var te := smoothstep(0.0, 1.0, t)
			var pos := _datk_from.lerp(socket, te) + Vector3.UP * (combo_return_leap * sin(PI * te))
			_place_attack_head_spin(pos, right, fwd, 0.0)
			if _datk_t >= combo_return_time:
				_end_detached_attack()


func _place_attack_head_spin(pos: Vector3, right: Vector3, fwd: Vector3, spin: float) -> void:
	if _attack_head == null or not is_instance_valid(_attack_head):
		return
	var yaw := Quaternion.IDENTITY
	if _body != null:
		yaw = _body.global_transform.basis.get_rotation_quaternion()
	var q := Quaternion(_combo_spin_axis(fwd, right), spin) * yaw   # face the body, then spin on this variant's axis
	_attack_head.global_position = pos
	_attack_head.transform.basis = Basis(q).scaled(Vector3.ONE * character_scale)


# Spin axis for the current attack variant, applied to the flying head (like the head-only styles).
func _combo_spin_axis(fwd: Vector3, right: Vector3) -> Vector3:
	match _attack_style:
		1:
			return Vector3.UP                                                    # twirl (yaw)
		2:
			return fwd.normalized() if fwd.length() > 0.01 else Vector3.FORWARD   # barrel roll
		_:
			return right                                                         # somersault (pitch)


func _ensure_attack_head() -> void:
	if _attack_head == null or not is_instance_valid(_attack_head):
		_attack_head = load("res://scripts/attack_head.gd").new()
		var parent: Node = _body.get_parent() if _body != null else get_tree().current_scene
		if parent == null:
			parent = self
		parent.add_child(_attack_head)
	_attack_head.visible = true
	var yaw := Quaternion.IDENTITY
	if _body != null:
		yaw = _body.global_transform.basis.get_rotation_quaternion()
	_attack_head.global_position = part_socket_world("head")   # start exactly on the socket (seamless swap)
	_attack_head.transform.basis = Basis(yaw).scaled(Vector3.ONE * character_scale)


func _try_hit_detached() -> void:
	# the head strikes from its ANCHOR (not the body, which may have moved) — hit the locked target if
	# it's within striking distance of where the head is fighting
	var tgt := _aim_target
	if tgt == null or not is_instance_valid(tgt) or not tgt.has_method("take_damage"):
		return
	var gap := Vector2(tgt.global_position.x - _datk_anchor.x, tgt.global_position.z - _datk_anchor.z).length()
	if gap <= attack_reach + 0.7:
		var dmg := clampi(int(round(lerpf(1.0, float(attack_damage), _attack_charge))), 1, attack_damage)
		tgt.take_damage(dmg, _datk_anchor, self)
		hit_landed.emit()


# place the flying head at pos, facing a horizontal direction (used while it walks back to the body)
func _place_attack_head_face(pos: Vector3, dir: Vector3) -> void:
	if _attack_head == null or not is_instance_valid(_attack_head):
		return
	var yaw := atan2(dir.x, dir.z) if dir.length() > 0.01 else 0.0
	_attack_head.global_position = pos
	_attack_head.transform.basis = Basis(Quaternion(Vector3.UP, yaw)).scaled(Vector3.ONE * character_scale)


# like _place_attack_head_face but with the head-only WALK pose: forward/back lean + squash/stretch.
func _place_attack_head_walk(pos: Vector3, dir: Vector3, s: float, pitch: float) -> void:
	if _attack_head == null or not is_instance_valid(_attack_head):
		return
	var yaw := atan2(dir.x, dir.z) if dir.length() > 0.01 else 0.0
	var q := Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)   # face travel, then lean
	var inv := 1.0 / sqrt(maxf(s, 0.05))                                       # volume-preserving squash/stretch
	_attack_head.global_position = pos
	_attack_head.transform.basis = Basis(q).scaled(Vector3(character_scale * inv, character_scale * s, character_scale * inv))


func _end_detached_attack() -> void:
	_attack_active = false
	_attack_detached = false
	_set_head_hidden(false)   # show the body's head again (the flying head is back on the socket)
	if _attack_head != null and is_instance_valid(_attack_head):
		_attack_head.visible = false
	position.z = 0.0
	rotation = Vector3.ZERO
	if _attack_buffered:
		trigger_attack()   # chain the next swing
	else:
		_hop_amt = 0.0


# hide/show ONLY the head mesh on the body (the torso/neck/hips stay as they are)
func _set_head_hidden(hidden: bool) -> void:
	if _model != null:
		_apply_head_vis(_model, hidden)


func _apply_head_vis(n: Node, hidden: bool) -> void:
	if n is MeshInstance3D and (n as MeshInstance3D).name == "head":
		(n as MeshInstance3D).visible = not hidden
	for c in n.get_children():
		_apply_head_vis(c, hidden)


# World-space forward direction the headbutt drives in (the head's facing, flattened).
func _attack_world_fwd() -> Vector3:
	if _body == null:
		return Vector3.ZERO
	var f := attack_forward_sign * _body.global_transform.basis.z
	f.y = 0.0
	return f.normalized() if f.length() > 0.01 else Vector3.ZERO


# What will the ram hit? Cast forward from the body over the reach; return the first collider
# on layer 1 (wall/enemy/box), or null for a clean miss.
# Floor height under a point (ray straight down, layer 1). Used to seat the detached head's fight
# anchor on the ground regardless of the body's walk-hop bob.
func _floor_y(from: Vector3) -> float:
	if _body == null:
		return from.y
	var space := _body.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from + Vector3(0.0, 0.5, 0.0), from - Vector3(0.0, 6.0, 0.0))
	q.exclude = [_body.get_rid()]
	q.collision_mask = 1
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return from.y
	return (hit.get("position") as Vector3).y


func _raycast_target() -> Node:
	if _body == null:
		return null
	var fwd := _attack_world_fwd()
	if fwd == Vector3.ZERO:
		return null
	var space := _body.get_world_3d().direct_space_state
	var from := _body.global_position + Vector3(0.0, 0.25, 0.0)
	var q := PhysicsRayQueryParameters3D.create(from, from + fwd * (attack_reach + 0.2))
	q.exclude = [_body.get_rid()]
	q.collision_mask = 1
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return null
	return hit.get("collider") as Node


# Non-uniform scale that preserves volume: taller when s>1, flatter (and wider) when s<1.
# When assembled (head+torso), most of the squash SLIDES the parts along the spine (they draw
# together on a squash, spread apart on a stretch) and only a fraction is uniform node-scale — so
# the torso itself barely deforms; the body compresses/extends like stacked segments.
# A little torso expression on the walk: the spine bends BACK at the top of the hop and FORWARD as it
# lands (phase-driven off how airborne we are), with the head counter-rotated so it stays level. Eases
# to rest when idle (no hop). Assembled only (a lone head has no torso to bend).
func _do_spine_expr(delta: float) -> void:
	if not _seg_squash or _skel == null:
		return
	# 0 on the ground, ~1 near the apex — from the current hop's height
	var air := 0.0
	if _hop_amt > 0.001:
		air = clampf((position.y - _base_y) / maxf(_hop_h * _hop_amt, 0.01), 0.0, 1.0)
	# bend FORWARD on the ground/landing (air 0), BACK in the air (air 1). Full magnitude whenever we're
	# moving (not scaled by hop strength, so it reads at any walk speed); eases to rest when standing.
	var target := 0.0
	if _speed > 0.2:
		target = deg_to_rad(lerpf(torso_bend_land_deg, -torso_bend_air_deg, air))
	_spine_swing = lerpf(_spine_swing, target, 1.0 - exp(-torso_bend_smooth * delta))
	if _mid_spine >= 0:
		_skel.set_bone_pose_rotation(_mid_spine, _mid_rest_rot * Quaternion(Vector3.RIGHT, _spine_swing * torso_bend_mid_frac))
	if _lower_spine >= 0:
		_skel.set_bone_pose_rotation(_lower_spine, _lower_rest_rot * Quaternion(Vector3.RIGHT, _spine_swing * torso_bend_lower_frac))
	# keep the head level while the torso bends under it
	if _head_bone >= 0 and spine_head_stabilize > 0.0:
		var counter := -_spine_swing * (torso_bend_mid_frac + torso_bend_lower_frac) * spine_head_stabilize
		_skel.set_bone_pose_rotation(_head_bone, _head_rest_rot * Quaternion(Vector3.RIGHT, counter))


func _set_squash(s: float) -> void:
	var node_s := s
	if _seg_squash:
		node_s = lerpf(1.0, s, squash_node_frac)   # only a slice of the squash is node-scale
	var inv := 1.0 / sqrt(maxf(node_s, 0.05))
	scale = Vector3(character_scale * inv, character_scale * node_s, character_scale * inv)
	if _seg_squash and _skel != null:
		var seg := lerpf(1.0, s, 1.0 - squash_node_frac)   # the rest slides the parts along the spine
		for i in _spine_bones.size():
			var b: int = _spine_bones[i]
			var r: Vector3 = _spine_rest[i]
			var y := r.y * seg
			if b == _head_bone:
				y *= head_neck_close   # seat the head closer to the neck (rest gap is too big)
			_skel.set_bone_pose_position(b, Vector3(r.x, y, r.z))
		# but the HEAD keeps its FULL mesh squash: make up whatever the reduced node-scale didn't do,
		# so the head flattens/stretches like it does in head-only mode (volume-preserving)
		if _head_bone >= 0:
			var head_s := s / maxf(node_s, 0.05)
			var hinv := 1.0 / sqrt(maxf(head_s, 0.05))
			_skel.set_bone_pose_scale(_head_bone, Vector3(hinv, head_s, hinv))


# Cache the head/neck/torso spine bones (NOT the root hips, which stays as the ground anchor) so the
# segmented squash can slide them vertically toward/away from each other.
func _cache_spine() -> void:
	_spine_bones = []
	_spine_rest = []
	_head_bone = -1
	_lower_spine = -1
	_mid_spine = -1
	if _skel == null:
		return
	for b in _skel.get_bone_count():
		var nm := _skel.get_bone_name(b).to_lower()
		# the two coil bones — the LOWER spine is the root, so grab it before the root-skip below
		if nm.contains("lowest") and nm.contains("spine"):
			_lower_spine = b
			_lower_rest_rot = _skel.get_bone_rest(b).basis.get_rotation_quaternion()
		elif nm.contains("mid") and nm.contains("spine"):
			_mid_spine = b
			_mid_rest_rot = _skel.get_bone_rest(b).basis.get_rotation_quaternion()
		if _skel.get_bone_parent(b) < 0:
			continue   # skip the root (grounded hips) for the vertical slide
		if nm.contains("spine") or nm.contains("neck") or nm.contains("head"):
			_spine_bones.append(b)
			_spine_rest.append(_skel.get_bone_rest(b).origin)
			if nm.contains("head"):
				_head_bone = b
				_head_rest_rot = _skel.get_bone_rest(b).basis.get_rotation_quaternion()


func _update_seg_flag() -> void:
	# only slide the parts when there's actually a body to slide (more than the lone head)
	_seg_squash = _skel != null and not _spine_bones.is_empty() and visible_parts.size() > 1
	_head_h = 0.0   # parts changed -> recompute the head's ground-drop height on next crouch


# Find the "armature idle" clip and, for each LITTLE-ARM bone, the tracks that drive it. We SAMPLE
# this clip (never play it) so only the little arms get the idle fidget — the head/spine/root stay
# procedural and don't inherit the clip's armature-root bob.
func _cache_idle_arms() -> void:
	_idle_anim = null
	_idle_arm_tracks = []
	if _ap == null or _skel == null:
		return
	for a in _ap.get_animation_list():
		if String(a).to_lower().contains("idle"):
			_idle_anim = _ap.get_animation(a)
			break
	if _idle_anim == null:
		return
	var arm_bones := {}   # exact bone name -> index, for the LITTLE arms only
	for b in _skel.get_bone_count():
		var nm := _skel.get_bone_name(b).to_lower()
		if nm.contains("small") and (nm.contains("arm") or nm.contains("shoulder") or nm.contains("hand")):
			arm_bones[_skel.get_bone_name(b)] = b
	var by_bone := {}
	for t in _idle_anim.get_track_count():
		var path := String(_idle_anim.track_get_path(t))
		var colon := path.rfind(":")
		if colon < 0:
			continue
		var bname := path.substr(colon + 1)
		if not arm_bones.has(bname):
			continue
		var bi: int = arm_bones[bname]
		if not by_bone.has(bi):
			by_bone[bi] = {"pos": -1, "rot": -1, "scl": -1}
		match _idle_anim.track_get_type(t):
			Animation.TYPE_POSITION_3D: by_bone[bi]["pos"] = t
			Animation.TYPE_ROTATION_3D: by_bone[bi]["rot"] = t
			Animation.TYPE_SCALE_3D: by_bone[bi]["scl"] = t
	for bi in by_bone:
		_idle_arm_tracks.append({"bone": bi, "pos": by_bone[bi]["pos"], "rot": by_bone[bi]["rot"], "scl": by_bone[bi]["scl"]})
	# The little arm is FK shoulder->small arm PLUS an IK-driven Small hand (the claw). Drive all three
	# for the reactive swing: rotate the SHOULDER (local Z, mirrored L/R), lift the IK-arm TARGET, tilt
	# the HAND (mirrored). Store the mirror sign; the swing amount is applied live in _do_little_arms.
	_arm_up_bones = []
	for b in _skel.get_bone_count():
		var nm := _skel.get_bone_name(b).to_lower()
		var sign := 1.0 if nm.strip_edges().ends_with("l") else -1.0
		if nm.contains("small") and nm.contains("shoulder"):
			_arm_up_bones.append({"kind": "shoulder", "bone": b, "sign": sign})
		elif nm.contains("ik") and nm.contains("small") and nm.contains("arm"):
			_arm_up_bones.append({"kind": "ik", "bone": b, "rest": _skel.get_bone_rest(b).origin})
		elif nm.contains("small") and nm.contains("hand"):
			_arm_up_bones.append({"kind": "hand", "bone": b, "sign": sign})


# Drive the little arms from the idle clip when standing still; ease them back to rest when active.
func _do_idle_arms(delta: float, active: bool) -> void:
	if _idle_anim == null or _idle_arm_tracks.is_empty() or _skel == null:
		return
	if not visible_parts.has("torso"):   # the little arms live in the torso mesh — nothing to show otherwise
		return
	_idle_arm_w = move_toward(_idle_arm_w, 1.0 if active else 0.0, delta / 0.3)   # 0.3 s ease in/out
	if active:
		_idle_arm_t = fmod(_idle_arm_t + delta, maxf(_idle_anim.length, 0.01))
	if _idle_arm_w <= 0.001:
		return
	for e in _idle_arm_tracks:
		var b: int = e["bone"]
		var rest := _skel.get_bone_rest(b)
		var rq := rest.basis.get_rotation_quaternion()
		var rs := rest.basis.get_scale()
		var p: Vector3 = _idle_anim.position_track_interpolate(e["pos"], _idle_arm_t) if e["pos"] >= 0 else rest.origin
		var q: Quaternion = _idle_anim.rotation_track_interpolate(e["rot"], _idle_arm_t) if e["rot"] >= 0 else rq
		var sc: Vector3 = _idle_anim.scale_track_interpolate(e["scl"], _idle_arm_t) if e["scl"] >= 0 else rs
		_skel.set_bone_pose_position(b, rest.origin.lerp(p, _idle_arm_w))
		_skel.set_bone_pose_rotation(b, rq.slerp(q, _idle_arm_w))
		_skel.set_bone_pose_scale(b, rs.lerp(sc, _idle_arm_w))


# Little arms: fling UP while falling, then BOUNCE on landing; idle-fidget when still, rest when moving.
func _do_little_arms(delta: float) -> void:
	if _idle_anim == null or _idle_arm_tracks.is_empty() or _skel == null:
		return
	if not visible_parts.has("torso"):
		return
	# visual vertical speed (the hop/jump arc) -> airborne + falling
	var vy := (position.y - _vis_y_prev) / maxf(delta, 0.001)
	_vis_y_prev = position.y
	var on_floor := _body == null or (_body is CharacterBody3D and (_body as CharacterBody3D).is_on_floor())
	# REACTIVE swing: the little arms lag the body's vertical motion (inertia) and spring back to rest.
	# Body dropping (vy<0) -> arms swing UP; body rising (vy>0) -> arms swing DOWN; settle when steady.
	var target := clampf(-vy * arm_react_gain, -1.5, 1.5)
	_arm_swing_vel += (target - _arm_swing) * arm_swing_stiffness * delta
	_arm_swing_vel *= exp(-arm_swing_damping * delta)
	_arm_swing += _arm_swing_vel * delta

	# base pose: idle-fidget only when standing still and the arms have basically settled
	var idle_active := _speed < 0.2 and not _jump_active and not _attack_active and not _charging and not _crouching
	_do_idle_arms(delta, idle_active)

	# apply the swing FROM REST (so a bone with no idle track still homes) — symmetric via the mirror sign
	if absf(_arm_swing) > 0.02:
		for e in _arm_up_bones:
			var b: int = e["bone"]
			var rest := _skel.get_bone_rest(b)
			match e["kind"]:
				"shoulder":
					_skel.set_bone_pose_rotation(b, rest.basis.get_rotation_quaternion() * Quaternion(Vector3.BACK, deg_to_rad(arm_swing_deg) * _arm_swing * e["sign"]))
				"hand":
					_skel.set_bone_pose_rotation(b, rest.basis.get_rotation_quaternion() * Quaternion(Vector3.BACK, deg_to_rad(arm_swing_hand_deg) * _arm_swing * e["sign"]))
				"ik":
					_skel.set_bone_pose_position(b, e["rest"] + Vector3(0.0, arm_swing_dist * _arm_swing, 0.0))


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null


func _find_body(n: Node) -> Node3D:
	var p := n.get_parent()
	while p != null:
		if p is CharacterBody3D:
			return p as Node3D
		p = p.get_parent()
	return null
