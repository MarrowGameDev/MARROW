extends Node3D
## Auto-attached to puppet_workshop.glb's root through its import setting (nodes/root_script),
## so EVERY placed workbench gets a craft station with zero editor wiring: walk up to the
## bench and "Press E to craft" appears. Fits the trigger to the bench's real bounds.
## If you drop a craft_station.tscn onto the bench by hand, this steps aside.

const STATION: PackedScene = preload("res://scenes/craft_station.tscn")


func _ready() -> void:
	if get_node_or_null("CraftStation") != null:
		return   # a hand-placed station already exists — don't double up
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
	var st: CraftStation = STATION.instantiate() as CraftStation
	st.name = "CraftStation"
	# exports are world metres: bench bounds x the workbench's placed scale, with approach room
	st.trigger_size = Vector3(aabb.size.x * 1.5 * s.x, aabb.size.y * 1.6 * s.y, aabb.size.z * 1.5 * s.z)
	st.prompt_height = (aabb.end.y + aabb.size.y * 0.25) * s.y
	st.position = Vector3(aabb.get_center().x, 0.0, aabb.get_center().z)
	add_child(st)
