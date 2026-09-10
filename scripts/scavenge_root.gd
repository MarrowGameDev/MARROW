extends Node3D
## Auto-attached to the puppet-pile models' roots through their import setting
## (nodes/root_script), so every placed pile becomes a scavenge point with zero editor wiring:
## walk up, "Press E to scavenge", get crafting materials. Loot depends on the pile type,
## picked from the model's node name. Steps aside if a station was placed by hand.

const STATION: PackedScene = preload("res://scenes/scavenge_station.tscn")

## Loot tables: [{id, min, max, chance}], rolled independently per entry.
## TUTORIAL materials only: wood_plank, screws, rope, glue.
const LOOT_BROKEN := [   # broken marionettes — screws and planks, a little glue
	{"id": "screws", "min": 2, "max": 3, "chance": 1.0},
	{"id": "wood_plank", "min": 1, "max": 2, "chance": 0.8},
	{"id": "glue", "min": 1, "max": 1, "chance": 0.5},
	{"id": "rope", "min": 1, "max": 1, "chance": 0.3},
]
const LOOT_GROUP := [    # puppet groups — planks and rope
	{"id": "wood_plank", "min": 2, "max": 3, "chance": 1.0},
	{"id": "rope", "min": 1, "max": 2, "chance": 0.8},
	{"id": "screws", "min": 1, "max": 2, "chance": 0.6},
]
const LOOT_PILE := [     # the mountain of failed puppets — glue-rich, plenty of screws
	{"id": "glue", "min": 1, "max": 2, "chance": 1.0},
	{"id": "screws", "min": 2, "max": 4, "chance": 0.9},
	{"id": "rope", "min": 1, "max": 2, "chance": 0.7},
	{"id": "wood_plank", "min": 1, "max": 2, "chance": 0.6},
]
const LOOT_BOX := [      # crates / boxes — a supply cache, the richest and most rounded source
	{"id": "screws", "min": 2, "max": 4, "chance": 1.0},
	{"id": "glue", "min": 1, "max": 2, "chance": 0.8},
	{"id": "rope", "min": 1, "max": 2, "chance": 0.7},
	{"id": "wood_plank", "min": 1, "max": 3, "chance": 0.6},
]
const LOOT_DEFAULT := [
	{"id": "wood_plank", "min": 1, "max": 2, "chance": 1.0},
	{"id": "screws", "min": 1, "max": 2, "chance": 0.8},
]


func _ready() -> void:
	if get_node_or_null("ScavengeStation") != null:
		return
	var aabb := AABB()
	var first := true
	var mesh_node: MeshInstance3D = null
	for mi in find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if mesh_node == null:
			mesh_node = m
		var b: AABB = m.get_aabb()
		if first:
			aabb = b
			first = false
		else:
			aabb = aabb.merge(b)
	var s: Vector3 = global_transform.basis.get_scale()
	var st: ScavengeStation = STATION.instantiate() as ScavengeStation
	st.name = "ScavengeStation"
	st.loot = loot_for(name)
	st.charges = 3
	st.trigger_size = Vector3(aabb.size.x * 1.5 * s.x, aabb.size.y * 1.6 * s.y, aabb.size.z * 1.5 * s.z)
	st.prompt_height = (aabb.end.y + aabb.size.y * 0.25) * s.y
	# spheres start at the top of the thing and land in a ring just outside its footprint
	st.drop_height = aabb.end.y * s.y
	st.drop_radius = maxf(aabb.size.x * s.x, aabb.size.z * s.z) * 0.8
	st.outline_target = mesh_node            # the pulsing "contains materials" outline
	st.position = Vector3(aabb.get_center().x, 0.0, aabb.get_center().z)
	add_child(st)


static func loot_for(node_name: String) -> Array:
	var n := node_name.to_lower()
	if "crate" in n or "box" in n:
		return LOOT_BOX
	if "broken" in n:
		return LOOT_BROKEN
	if "pile" in n:
		return LOOT_PILE
	if "group" in n:
		return LOOT_GROUP
	return LOOT_DEFAULT
