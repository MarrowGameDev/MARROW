extends Area3D

var exit_open: bool = false
var player_in_range: Node3D = null
var portal_material: StandardMaterial3D = null

@onready var portal_mesh: MeshInstance3D = $PortalMesh
@onready var portal_label: Label3D = $PortalLabel


func _ready() -> void:
	add_to_group("exit_portals")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_prepare_material()
	_update_visuals()


func _process(_delta: float) -> void:
	if exit_open and player_in_range != null:
		portal_label.text = "Tier 1 Complete"


func open_exit() -> void:
	exit_open = true
	_update_visuals()
	# If the player is already standing in the portal when it opens, win right away.
	if player_in_range != null:
		_reach_exit(player_in_range)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("get_equipped_bone_id"):
		player_in_range = body
		_update_visuals()
		if exit_open:
			_reach_exit(body)


func _on_body_exited(body: Node3D) -> void:
	if body == player_in_range:
		player_in_range = null
		_update_visuals()


# Tier 1F: tell the goal manager the player finished the course.
func _reach_exit(player: Node3D) -> void:
	GameEvents.exit_reached.emit(player)


func _prepare_material() -> void:
	var raw_material := portal_mesh.get_surface_override_material(0)
	if raw_material != null:
		portal_material = raw_material.duplicate() as StandardMaterial3D
	if portal_material == null:
		portal_material = StandardMaterial3D.new()
	portal_mesh.set_surface_override_material(0, portal_material)


func _update_visuals() -> void:
	if exit_open:
		_set_portal_color(Color(0.25, 1.0, 0.45, 1.0))
		portal_label.text = "Exit Open"
	else:
		_set_portal_color(Color(0.45, 0.45, 0.45, 1.0))
		portal_label.text = "Exit Locked\nComplete 3 trials"


func _set_portal_color(color: Color) -> void:
	if portal_material != null:
		portal_material.albedo_color = color
		portal_material.emission_enabled = true
		portal_material.emission = color
		portal_material.emission_energy_multiplier = 0.45

	if portal_label != null:
		portal_label.modulate = color
