extends SceneTree

# Visual differentiation by quality, checked on real materials.


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(4711)

	# --- 1 & 12. Normal (and legacy, which resolves to Normal) unchanged ---
	var base := _fresh_material()
	var normal_mat := _fresh_material()
	BoneQualityService.apply_to_material(normal_mat, BoneQualityService.QUALITY_NORMAL)
	if not _same_look(base, normal_mat):
		failures.append("Normal altered the base material: %s vs %s" % [_describe(base), _describe(normal_mat)])
	var legacy_mat := _fresh_material()
	BoneQualityService.apply_instance_to_material(legacy_mat, "arm_bone")
	if not _same_look(base, legacy_mat):
		failures.append("a legacy bone_id changed the base look")
	print("1/12. normal + legacy identical to base: ", _describe(normal_mat))

	# --- 2-6. every tier differs, and differs from every other -------------
	var looks: Dictionary = {}
	for quality_id in BoneQualityService.QUALITY_ORDER:
		var mat := _fresh_material()
		BoneQualityService.apply_to_material(mat, str(quality_id))
		looks[str(quality_id)] = _describe(mat)
		print("   %-9s %s" % [str(quality_id), _describe(mat)])
	var seen: Dictionary = {}
	for quality_id in looks:
		var look := str(looks[quality_id])
		if seen.has(look):
			failures.append("%s and %s render identically" % [str(quality_id), str(seen[look])])
		seen[look] = quality_id

	# Directional expectations from the brief.
	var frail: StandardMaterial3D = _tinted(BoneQualityService.QUALITY_FRAIL)
	var worn: StandardMaterial3D = _tinted(BoneQualityService.QUALITY_WORN)
	var strong: StandardMaterial3D = _tinted(BoneQualityService.QUALITY_STRONG)
	var pristine: StandardMaterial3D = _tinted(BoneQualityService.QUALITY_PRISTINE)
	var reference := _fresh_material()

	if frail.roughness <= reference.roughness:
		failures.append("Frail is not rougher than Normal")
	if _saturation(frail.albedo_color) >= _saturation(reference.albedo_color):
		failures.append("Frail is not desaturated")
	if frail.emission_energy_multiplier > 0.0 and frail.emission_enabled:
		failures.append("Frail must not emit")
	if worn.roughness <= reference.roughness:
		failures.append("Worn is not rougher than Normal")
	if worn.roughness >= frail.roughness:
		failures.append("Worn should be less rough than Frail")
	if _coolness(worn.albedo_color) >= _coolness(reference.albedo_color):
		failures.append("Worn is not warmer than the base palette")
	if strong.roughness >= reference.roughness:
		failures.append("Strong is not smoother than Normal")
	if _coolness(strong.albedo_color) <= _coolness(reference.albedo_color):
		failures.append("Strong is not cooler than the base palette")
	if strong.emission_enabled and strong.emission_energy_multiplier > 0.0:
		failures.append("Strong emits: it must look solid, not enchanted")
	if pristine.roughness >= strong.roughness:
		failures.append("Pristine is not the smoothest tier")
	if not pristine.emission_enabled or pristine.emission_energy_multiplier <= 0.0:
		failures.append("Pristine has no emission")
	if pristine.emission_energy_multiplier > 0.15:
		failures.append("Pristine emission %.3f is too strong to read as restrained" % pristine.emission_energy_multiplier)

	# --- 8. one instance must never change another ------------------------
	var shared_base := _fresh_material()
	var copy_a := shared_base.duplicate() as StandardMaterial3D
	var copy_b := shared_base.duplicate() as StandardMaterial3D
	BoneQualityService.apply_to_material(copy_a, BoneQualityService.QUALITY_PRISTINE)
	if not _same_look(shared_base, copy_b):
		failures.append("tinting one copy changed the sibling copy")
	if not _same_look(shared_base, _fresh_material()):
		failures.append("tinting mutated the shared base material")
	print("8. sibling material untouched: ", _describe(copy_b))

	# --- 6 & 7. two same-type pieces differ, and stay stable --------------
	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame
	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return

	var torso := BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_NORMAL)
	player.call("collect_bone", torso)
	await process_frame
	player.call("equip_bone", torso, EquipmentRulesService.slot_for_bone(torso))
	await process_frame

	var arm_frail := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_FRAIL)
	var arm_pristine := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	for piece in [arm_frail, arm_pristine]:
		player.call("collect_bone", piece)
		await process_frame

	var rig: Variant = player.get("rig")
	if rig == null:
		for child in player.get_children():
			if child is ModularSkeletonRig:
				rig = child
				break
	if rig != null:
		player.call("equip_bone", arm_frail, EquipmentRulesService.SLOT_LEFT_ARM)
		player.call("equip_bone", arm_pristine, EquipmentRulesService.SLOT_RIGHT_ARM)
		for i in range(4):
			await process_frame
		var left_look := _rig_look(rig, "left_arm")
		var right_look := _rig_look(rig, "right_arm")
		print("6. frail arm: %s" % left_look)
		print("   pristine arm: %s" % right_look)
		if left_look == "" or right_look == "":
			failures.append("could not read the rig materials back")
		elif left_look == right_look:
			failures.append("two same-type arms of different quality render identically on the rig")

		# --- 10 & 11. no material churn on re-equip -----------------------
		var before_count := _count_materials(rig)
		player.call("unequip_slot", EquipmentRulesService.SLOT_LEFT_ARM)
		player.call("equip_bone", arm_frail, EquipmentRulesService.SLOT_LEFT_ARM)
		for i in range(4):
			await process_frame
		var after_count := _count_materials(rig)
		print("10/11. rig materials before=%d after re-equip=%d" % [before_count, after_count])
		if after_count > before_count:
			failures.append("re-equipping grew the material count %d -> %d" % [before_count, after_count])
		# Idle frames must not allocate anything.
		var idle_before := _count_materials(rig)
		for i in range(30):
			await process_frame
		var idle_after := _count_materials(rig)
		if idle_after != idle_before:
			failures.append("materials changed while idle: %d -> %d (per-frame work?)" % [idle_before, idle_after])
		print("11. materials stable across 30 idle frames: %d" % idle_after)

	# --- 9. quality does not consume the other visual channels ------------
	if BoneRulesService.mutation_id_for("arm_bone") != BoneRulesService.mutation_id_for(arm_pristine):
		failures.append("quality changed the mutation channel")
	if BoneRulesService.durability_start_for("arm_bone") != BoneRulesService.durability_start_for(arm_pristine):
		failures.append("quality changed the durability channel")
	if BoneRulesService.rarity_for("arm_bone") != BoneRulesService.rarity_for(arm_pristine):
		failures.append("quality changed the rarity channel")
	print("9. mutation/durability/rarity unchanged by quality")

	print("")
	if failures.is_empty():
		print("QUALITY VISUAL CHECK: PASS")
	else:
		print("QUALITY VISUAL CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _fresh_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.90, 0.86, 0.70, 1.0)
	mat.roughness = 0.82
	return mat


func _tinted(quality_id: String) -> StandardMaterial3D:
	var mat := _fresh_material()
	BoneQualityService.apply_to_material(mat, quality_id)
	return mat


func _describe(mat: StandardMaterial3D) -> String:
	return "albedo=(%.3f,%.3f,%.3f) rough=%.3f spec=%.3f emit=%s/%.3f" % [
		mat.albedo_color.r, mat.albedo_color.g, mat.albedo_color.b,
		mat.roughness, mat.metallic_specular,
		str(mat.emission_enabled), mat.emission_energy_multiplier,
	]


func _same_look(a: StandardMaterial3D, b: StandardMaterial3D) -> bool:
	return _describe(a) == _describe(b)


# Blue relative to red: higher means cooler. Absolute b > r never happens on
# this project's warm bone palette, so coolness has to be measured as a shift.
func _coolness(c: Color) -> float:
	return c.b / maxf(0.001, c.r)


func _saturation(c: Color) -> float:
	return maxf(c.r, maxf(c.g, c.b)) - minf(c.r, minf(c.g, c.b))


# Reads the material of the part the rig actually equipped for a slot.
# Walking the socket subtree instead would find the hidden grey placeholder or
# the magenta socket debug marker, neither of which is the equipped piece.
func _rig_look(rig: Node, slot_id: String) -> String:
	var parts: Variant = rig.get("equipped_parts")
	if typeof(parts) != TYPE_DICTIONARY or not (parts as Dictionary).has(slot_id):
		return ""
	for part in (parts as Dictionary)[slot_id]:
		var found := _first_material(part as Node)
		if found != "":
			return found
	return ""


func _first_material(node: Node) -> String:
	# The rig hides the grey base visual instead of freeing it, so an
	# unfiltered walk finds that placeholder rather than the equipped piece.
	var visual := node as Node3D
	if visual != null and not visual.visible:
		return ""
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null:
		var mat := mesh_instance.material_override as StandardMaterial3D
		if mat != null:
			return _describe(mat)
	for child in node.get_children():
		var found := _first_material(child)
		if found != "":
			return found
	return ""


func _count_materials(node: Node) -> int:
	var total := 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.material_override != null:
		total += 1
	for child in node.get_children():
		total += _count_materials(child)
	return total


func _find_player(node: Node) -> Node:
	if node.get("inventory_ui") != null:
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null
