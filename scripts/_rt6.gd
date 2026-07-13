extends SceneTree
func _initialize() -> void:
	var main := (load("res://scenes/rig_test.tscn") as PackedScene).instantiate()
	get_root().add_child(main)
	var rig = main.get_node("RigTestPlayer/VisualRoot/ModularSkeletonRig")
	var rarm = rig.get_socket("right_arm")
	var arm_rot0: float = 0.0
	for i in range(4):
		await physics_frame
	arm_rot0 = rarm.rotation.x
	print("grey torso visible=", rig.base_visuals["body"].visible)
	print("arm grey hidden=", rig.base_visuals["right_arm"].visible == false, " foot grey hidden=", rig.base_visuals["right_foot"].visible == false)
	print("arm socket X=", rig.get_socket("right_arm").position.x, " (closer, was 0.42)")
	for i in range(16):
		await physics_frame
	# player fell/idle; nudge velocity via animator to check swing still animates sockets
	var anim = main.get_node("RigTestPlayer/VisualRoot/ProceduralAnimator")
	for i in range(15):
		anim.update_from_player(0.05, Vector3(6, 0, 0), 6.0, Vector3(1, 0, 0), [])
	print("arm socket still swings=", absf(rarm.rotation.x - arm_rot0) > 0.001)
	quit()
