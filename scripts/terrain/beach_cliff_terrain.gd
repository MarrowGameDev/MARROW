@tool
class_name BeachCliffTerrain
extends Node3D

# Procedural beach -> cliff terrain, generated as a single heightmap mesh:
#   front:   underwater slope -> shoreline
#   middle:  gently rising sand beach
#   back:    a steep cliff face rising to a plateau
# The coast/cliff line wobbles with noise so it isn't a straight ramp, and the
# surface is coloured per-vertex by SLOPE and HEIGHT (wet sand near the water, dry
# sand on the flats, rock on the steep cliff, a grass tint on the plateau top).
# Adds a trimesh StaticBody so things can walk on it, and a translucent water plane.
#
# Drop this node into any scene (it builds on _ready, and re-builds in the editor
# when you tick "regenerate"). Tune everything from the Inspector.

@export var regenerate: bool = false: set = _set_regenerate

@export_group("Size")
@export var width: float = 64.0          # x extent (metres)
@export var depth: float = 64.0          # z extent (metres); -z = sea, +z = cliff
@export var resolution: int = 110        # grid cells per side

@export_group("Shape")
@export var water_level: float = -1.4
@export var shore_z: float = -20.0       # where the water meets the beach
@export var beach_top: float = 1.1       # sand height at the base of the cliff
@export var cliff_start_z: float = 3.0
@export var cliff_end_z: float = 17.0
@export var cliff_height: float = 11.0
@export var coast_wobble: float = 4.5     # how much the cliff/coast line meanders in x

@export_group("Noise")
@export var noise_seed: int = 1337
@export var noise_frequency: float = 0.045
@export var noise_amplitude: float = 1.7

@export_group("Colors")
@export var wet_sand: Color = Color(0.55, 0.47, 0.35)
@export var dry_sand: Color = Color(0.84, 0.74, 0.54)
@export var rock: Color = Color(0.48, 0.46, 0.44)
@export var grass: Color = Color(0.38, 0.48, 0.26)
@export var add_water: bool = true
@export var water_color: Color = Color(0.16, 0.42, 0.55, 0.7)

var _noise: FastNoiseLite


func _ready() -> void:
	build()


func _set_regenerate(v: bool) -> void:
	regenerate = false
	if is_inside_tree():
		build()


func build() -> void:
	_noise = FastNoiseLite.new()
	_noise.seed = noise_seed
	_noise.frequency = noise_frequency
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	for c in get_children():
		c.queue_free()

	var res := maxi(resolution, 4)
	var n := res + 1
	var eps := (width / res)
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	verts.resize(n * n); normals.resize(n * n); uvs.resize(n * n); colors.resize(n * n)

	for j in range(n):
		for i in range(n):
			var x := -width * 0.5 + width * float(i) / res
			var z := -depth * 0.5 + depth * float(j) / res
			var y := _height(x, z)
			# Analytic-ish normal from a finite-difference height gradient.
			var hx := (_height(x + eps, z) - _height(x - eps, z)) / (2.0 * eps)
			var hz := (_height(x, z + eps) - _height(x, z - eps)) / (2.0 * eps)
			var nrm := Vector3(-hx, 1.0, -hz).normalized()
			var idx := j * n + i
			verts[idx] = Vector3(x, y, z)
			normals[idx] = nrm
			uvs[idx] = Vector2(float(i) / res, float(j) / res)
			colors[idx] = _color(y, nrm.y)

	var indices := PackedInt32Array()
	for j in range(res):
		for i in range(res):
			var a := j * n + i
			var b := a + 1
			var c := a + n
			var d := c + 1
			indices.append_array([a, b, c, b, d, c])   # wind so the top surface faces up

	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_COLOR] = colors
	arr[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

	var mi := MeshInstance3D.new()
	mi.name = "TerrainMesh"
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.metallic_specular = 0.15                  # kill the grazing sky sheen on flat sand
	mat.vertex_color_is_srgb = true               # colours below are authored as sRGB
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED   # double-sided; safe against winding
	mi.material_override = mat
	add_child(mi)

	var body := StaticBody3D.new()
	body.name = "TerrainBody"
	var col := CollisionShape3D.new()
	col.shape = mesh.create_trimesh_shape()
	body.add_child(col)
	add_child(body)

	if add_water:
		var wm := MeshInstance3D.new()
		wm.name = "Water"
		var pm := PlaneMesh.new()
		pm.size = Vector2(width * 1.4, depth * 1.4)
		wm.mesh = pm
		wm.position.y = water_level
		var wmat := StandardMaterial3D.new()
		wmat.albedo_color = water_color
		wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		wmat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS   # sort against the terrain
		wmat.roughness = 0.12
		wmat.metallic = 0.25
		wm.material_override = wmat
		add_child(wm)


# Height at (x, z). The coast/cliff lines are shifted per-column by noise so they
# meander instead of running dead straight.
func _height(x: float, z: float) -> float:
	var shift := _noise.get_noise_2d(x, -900.0) * coast_wobble
	var s_z := shore_z + shift
	var c0 := cliff_start_z + shift
	var c1 := cliff_end_z + shift * 0.5
	var h: float
	if z <= s_z:
		var t := clampf((s_z - z) / maxf(s_z + depth * 0.5, 0.01), 0.0, 1.0)
		h = lerpf(0.0, water_level - 1.2, t)              # underwater slope
	elif z <= c0:
		var t := (z - s_z) / maxf(c0 - s_z, 0.01)
		h = lerpf(0.0, beach_top, t)                       # beach
	elif z <= c1:
		var t := (z - c0) / maxf(c1 - c0, 0.01)
		h = lerpf(beach_top, cliff_height, smoothstep(0.0, 1.0, t))  # cliff face
	else:
		h = cliff_height

	# Surface detail: gentle on the flat beach, rockier on the cliff/plateau.
	var amp := noise_amplitude * (0.3 if z <= c0 else 1.0)
	h += _noise.get_noise_2d(x, z) * amp
	if z > c1:
		h += _noise.get_noise_2d(x * 0.5 + 300.0, z * 0.5) * 1.2   # plateau undulation
	return h


func _color(y: float, slope: float) -> Color:
	var c := dry_sand
	# Steep faces -> rock.
	c = c.lerp(rock, smoothstep(0.82, 0.5, slope))
	# High + flattish -> grass on the plateau top.
	if slope > 0.8:
		c = c.lerp(grass, smoothstep(cliff_height * 0.55, cliff_height * 0.9, y) * 0.75)
	# Near / below the waterline -> darker wet sand.
	c = c.lerp(wet_sand, smoothstep(water_level + 1.1, water_level - 0.6, y))
	return c
