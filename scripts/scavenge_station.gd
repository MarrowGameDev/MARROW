extends InteractStation
class_name ScavengeStation
## A box / pile / group you can pick over. While it still holds materials its mesh wears a
## pulsing white-grey OUTLINE glow. E rolls the loot table and puts the materials STRAIGHT
## into the inventory ("+2 Screws, +1 Glue"). A few charges, then it's picked clean and the
## outline fades out. (spill_as_spheres flips it to burst glowing MaterialPickup spheres
## instead — spheres are otherwise the form materials take when lying on the ground.)
## Auto-attached to the box/pile/group models by scavenge_root.gd; also droppable by hand.

@export var loot: Array = []       # [{id, min, max, chance}] — rolled independently per entry
@export var charges: int = 3       # how many times it can be scavenged
## Off (default): scavenged materials go STRAIGHT to the inventory. On: they spill out as
## glowing MaterialPickup spheres you walk over (spheres are otherwise for materials on the ground).
@export var spill_as_spheres: bool = false
@export var drop_height: float = 1.0      # world m above the station: where spilled spheres start
@export var drop_radius: float = 1.2      # world m: how far from the centre they land
@export var outline_target_path: NodePath # optional: mesh to outline when placed by hand
## The outline only shows when the player is this close (world metres from the station's box —
## edge distance, so a wide pile lights up as you walk up to any side of it).
@export var glow_range: float = 1.0

var outline_target: MeshInstance3D = null   # set by scavenge_root.gd (or resolved from the path)

var _left: int = 0
var _outline: OutlineGlow = null
var _outline_level := 0.0    # 0..1 — fades in when the player comes close, out once picked clean
var _t := 0.0
var _seed := 0.0
var _near_player: Node3D = null   # the player, looked up by group when it isn't inside our trigger
var _lookup_in := 0.0


func _init() -> void:
	prompt_text = "Press E to scavenge"


func _ready() -> void:
	super()
	_left = charges
	_seed = randf() * 100.0
	_refresh_prompt()
	if outline_target == null and not outline_target_path.is_empty():
		outline_target = get_node_or_null(outline_target_path) as MeshInstance3D
	if outline_target != null:
		_outline = OutlineGlow.attach(outline_target)
		_outline_level = 1.0


func _process(delta: float) -> void:
	super(delta)               # keeps the focus/prompt logic of the base running
	if _outline == null:
		return
	_t += delta
	var lit: bool = _left > 0 and _player_within(glow_range, delta)
	# quick in/out as the player comes and goes; a slow fade once the station is picked clean
	_outline_level = move_toward(_outline_level, 1.0 if lit else 0.0, delta * (0.8 if _left <= 0 else 3.0))
	_outline.set_intensity(_outline_level * GlowFX.fire(_t, _seed, 0.3))


## Is the player within `range_m` world metres of our trigger box (0 while touching it)?
func _player_within(range_m: float, delta: float) -> bool:
	var p: Node3D = _player
	if p == null:
		_lookup_in -= delta
		if _lookup_in <= 0.0 or not is_instance_valid(_near_player):
			_lookup_in = 0.5
			_near_player = get_tree().get_first_node_in_group("player") as Node3D
		p = _near_player
	if p == null or not is_instance_valid(p):
		return false
	return distance_to_box(p.global_position) <= range_m


## World-metre distance from a point to the station's trigger box (the same box the base class
## builds: trigger_size wide/deep around our origin, trigger_size.y tall from the floor up).
func distance_to_box(world_point: Vector3) -> float:
	var s: Vector3 = global_transform.basis.get_scale()
	var l: Vector3 = global_transform.affine_inverse() * world_point   # local, unscaled units
	var half: Vector3 = trigger_size * 0.5 / s
	var d := Vector3(
		maxf(absf(l.x) - half.x, 0.0),
		maxf(absf(l.y - half.y) - half.y, 0.0),
		maxf(absf(l.z) - half.z, 0.0))
	return (d * s).length()


func _can_interact() -> bool:
	return _left > 0


func _on_interact() -> void:
	var bundle := roll()
	_left -= 1
	if bundle.is_empty():
		flash("Nothing useful...")
	elif spill_as_spheres:
		_spill(bundle)
		flash("Materials spill out!")
	else:
		_grant(bundle)
	_refresh_prompt()


## Default: straight into the inventory, with a "+2 Screws, +1 Glue" flash.
func _grant(bundle: Dictionary) -> void:
	var sys = system()
	if sys == null:
		flash("No crafting system loaded.")
		return
	sys.add_materials(bundle)     # the Raft-style pickup feed itemizes the gains on the HUD
	flash("Scavenged!")


## Optional: burst the materials out as glowing spheres that land on the floor around us.
func _spill(bundle: Dictionary) -> void:
	var host: Node = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
	var origin: Vector3 = global_position + Vector3.UP * drop_height
	for id in bundle:
		var a := randf() * TAU
		var r: float = drop_radius * randf_range(0.6, 1.0)
		var land: Vector3 = global_position + Vector3(cos(a) * r, 0.0, sin(a) * r)
		land.y = _floor_y(land, origin.y)
		MaterialPickup.spawn(host, str(id), int(bundle[id]), origin, land)


## Roll the loot table into a {material_id: qty} bundle.
func roll() -> Dictionary:
	var out: Dictionary = {}
	for e in loot:
		if randf() <= float(e.get("chance", 1.0)):
			var q: int = randi_range(int(e.get("min", 1)), int(e.get("max", 1)))
			if q > 0:
				var id := str(e.get("id", ""))
				out[id] = int(out.get(id, 0)) + q
	return out


func spheres_out() -> int:
	return get_tree().get_nodes_in_group("material_pickups").size()


## Where the floor is under a landing spot (so spheres rest on the real ground).
func _floor_y(at: Vector3, from_y: float) -> float:
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(Vector3(at.x, from_y + 0.5, at.z), Vector3(at.x, from_y - 20.0, at.z))
	var hit := space.intersect_ray(q)
	return hit.position.y if not hit.is_empty() else global_position.y


func _refresh_prompt() -> void:
	set_prompt("Press E to scavenge  (%d left)" % _left if _left > 0 else "Picked clean")
