extends Node3D
## Auto-attached to the puppet-pile models' roots through their import setting
## (nodes/root_script), so every placed pile becomes a scavenge point with zero editor wiring:
## walk up, "Press E to scavenge", get crafting materials. Loot depends on the pile type,
## picked from the model's node name. Steps aside if a station was placed by hand.

const STATION: PackedScene = preload("res://scenes/scavenge_station.tscn")

## Loot tables: [{id, min, max, chance}], rolled independently per entry.
const LOOT_BROKEN := [   # broken marionettes — pins, limbs, a little metal
	{"id": "brass_pin", "min": 1, "max": 2, "chance": 0.9},
	{"id": "wood_limb", "min": 1, "max": 2, "chance": 0.8},
	{"id": "wood_block", "min": 1, "max": 1, "chance": 0.5},
	{"id": "iron_nail", "min": 1, "max": 3, "chance": 0.5},
	{"id": "marrow", "min": 2, "max": 4, "chance": 1.0},
]
const LOOT_GROUP := [    # puppet groups — limbs and blocks
	{"id": "wood_limb", "min": 2, "max": 3, "chance": 1.0},
	{"id": "wood_block", "min": 1, "max": 1, "chance": 0.6},
	{"id": "rope", "min": 1, "max": 1, "chance": 0.5},
	{"id": "marrow", "min": 1, "max": 3, "chance": 1.0},
]
const LOOT_PILE := [     # the mountain of failed puppets — marrow-rich, rare metal
	{"id": "marrow", "min": 4, "max": 8, "chance": 1.0},
	{"id": "wood_limb", "min": 1, "max": 2, "chance": 0.7},
	{"id": "brass_pin", "min": 1, "max": 1, "chance": 0.5},
	{"id": "tin_plate", "min": 1, "max": 1, "chance": 0.35},
	{"id": "iron_spring", "min": 1, "max": 1, "chance": 0.35},
]
const LOOT_DEFAULT := [
	{"id": "wood_limb", "min": 1, "max": 2, "chance": 1.0},
	{"id": "marrow", "min": 1, "max": 3, "chance": 1.0},
]


func _ready() -> void:
	if get_node_or_null("ScavengeStation") != null:
		return
	var aabb := AABB()
	var first := true
	for mi in find_children("*", "MeshInstance3D", true, false):
		var b: AABB = (mi as MeshInstance3D).get_aabb()
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
	st.position = Vector3(aabb.get_center().x, 0.0, aabb.get_center().z)
	add_child(st)


static func loot_for(node_name: String) -> Array:
	var n := node_name.to_lower()
	if "broken" in n:
		return LOOT_BROKEN
	if "pile" in n:
		return LOOT_PILE
	if "group" in n:
		return LOOT_GROUP
	return LOOT_DEFAULT
