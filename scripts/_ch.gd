extends Node3D
const OUT := "/private/tmp/claude-501/-Users-juliantorres-Documents-Codex-2026-07-08-MARROW/2f7a6e17-54ce-4b7f-b243-8c47d83dcc3c/scratchpad/crabhead_opt.png"
var _f := 0
func _ready():
	var env := Environment.new(); env.background_mode=Environment.BG_COLOR; env.background_color=Color(0.4,0.55,0.7)
	env.ambient_light_color=Color(0.82,0.82,0.82); env.ambient_light_energy=0.7
	var we := WorldEnvironment.new(); we.environment=env; add_child(we)
	var l := DirectionalLight3D.new(); l.rotation_degrees=Vector3(-45,35,0); l.light_energy=2.0; add_child(l)
	var g := MeshInstance3D.new(); var bm := BoxMesh.new(); bm.size=Vector3(10,0.2,10); g.mesh=bm
	var gm := StandardMaterial3D.new(); gm.albedo_color=Color(0.5,0.6,0.42); g.material_override=gm; g.position.y=-0.1; add_child(g)
	var c := (load("res://assets/crab_head_character_optimized.glb") as PackedScene).instantiate()
	add_child(c); c.scale=Vector3.ONE*0.18
	var ap := _ap(c)
	if ap and ap.has_animation("armature idle"):
		ap.get_animation("armature idle").loop_mode = Animation.LOOP_LINEAR
		ap.play("armature idle"); ap.seek(1.4, true)
	var cam := Camera3D.new(); cam.fov=42.0; add_child(cam)
	cam.look_at_from_position(Vector3(2.4,1.6,4.2), Vector3(0,1.0,0), Vector3.UP)
func _ap(n):
	if n is AnimationPlayer: return n
	for c in n.get_children():
		var f=_ap(c)
		if f: return f
	return null
func _process(_d):
	_f+=1
	if _f==6:
		get_viewport().get_texture().get_image().save_png(OUT); print("SAVED"); get_tree().quit()
