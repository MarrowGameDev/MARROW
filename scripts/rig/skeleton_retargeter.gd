class_name SkeletonRetargeter
extends RefCounted

# Play an animation authored for one humanoid skeleton on the CC skeleton
# (CC_Base_*). Supports two source rigs, auto-detected from the bone names:
#   * Mixamo   (mixamorig_Hips, mixamorig_LeftUpLeg, mixamorig_LeftArm, …)
#   * Quaternius mannequin (pelvis, thigh_l, upperarm_l, …)
#
# Method (global-delta with anatomical alignment):
#   Wsrc = src_global · src_rest_global⁻¹                 (world delta from rest)
#   Wcc  = A · Wsrc · A⁻¹                                  (A = anatomy alignment)
#   dst_global = Wcc · dst_rest_global ; dst_local = dst_parentⁿᵒʷ⁻¹ · dst_global
# Bones are posed parent→child. The delta is rest-relative, so each skeleton keeps
# its own facing/proportions. apply(weight) blends the result toward the CC rest
# pose, giving a free idle (weight 0 = stand, weight 1 = full animation).

const _SCHEMES := {
	"mixamo": {
		"detect": "mixamorig_Hips",
		"anatomy": {"hips": "mixamorig_Hips", "head": "mixamorig_Head",
			"thigh_l": "mixamorig_LeftUpLeg", "thigh_r": "mixamorig_RightUpLeg"},
		"map": {
			"mixamorig_Hips": "CC_Base_Hip", "mixamorig_Spine": "CC_Base_Waist",
			"mixamorig_Spine1": "CC_Base_Spine01", "mixamorig_Spine2": "CC_Base_Spine02",
			"mixamorig_Neck": "CC_Base_NeckTwist01", "mixamorig_Head": "CC_Base_Head",
			"mixamorig_LeftShoulder": "CC_Base_L_Clavicle", "mixamorig_LeftArm": "CC_Base_L_Upperarm",
			"mixamorig_LeftForeArm": "CC_Base_L_Forearm", "mixamorig_LeftHand": "CC_Base_L_Hand",
			"mixamorig_RightShoulder": "CC_Base_R_Clavicle", "mixamorig_RightArm": "CC_Base_R_Upperarm",
			"mixamorig_RightForeArm": "CC_Base_R_Forearm", "mixamorig_RightHand": "CC_Base_R_Hand",
			"mixamorig_LeftUpLeg": "CC_Base_L_Thigh", "mixamorig_LeftLeg": "CC_Base_L_Calf",
			"mixamorig_LeftFoot": "CC_Base_L_Foot", "mixamorig_RightUpLeg": "CC_Base_R_Thigh",
			"mixamorig_RightLeg": "CC_Base_R_Calf", "mixamorig_RightFoot": "CC_Base_R_Foot",
		},
	},
	"quaternius": {
		"detect": "pelvis",
		"anatomy": {"hips": "pelvis", "head": "Head", "thigh_l": "thigh_l", "thigh_r": "thigh_r"},
		"map": {
			"pelvis": "CC_Base_Hip", "spine_01": "CC_Base_Waist", "spine_02": "CC_Base_Spine01",
			"spine_03": "CC_Base_Spine02", "neck_01": "CC_Base_NeckTwist01", "Head": "CC_Base_Head",
			"clavicle_l": "CC_Base_L_Clavicle", "upperarm_l": "CC_Base_L_Upperarm",
			"lowerarm_l": "CC_Base_L_Forearm", "hand_l": "CC_Base_L_Hand",
			"clavicle_r": "CC_Base_R_Clavicle", "upperarm_r": "CC_Base_R_Upperarm",
			"lowerarm_r": "CC_Base_R_Forearm", "hand_r": "CC_Base_R_Hand",
			"thigh_l": "CC_Base_L_Thigh", "calf_l": "CC_Base_L_Calf", "foot_l": "CC_Base_L_Foot",
			"thigh_r": "CC_Base_R_Thigh", "calf_r": "CC_Base_R_Calf", "foot_r": "CC_Base_R_Foot",
		},
	},
}

var src_skel: Skeleton3D
var dst_skel: Skeleton3D
var scheme := ""
var align: Basis = Basis()
var _pairs: Array = []   # {src, dst, grs_inv:Basis, grd:Basis, depth:int, rest:Quaternion}


func _init(source: Skeleton3D, target: Skeleton3D) -> void:
	src_skel = source
	dst_skel = target
	scheme = _detect_scheme()
	if scheme == "":
		return
	var s: Dictionary = _SCHEMES[scheme]
	var an: Dictionary = s["anatomy"]
	align = _anatomy_frame(dst_skel, "CC_Base_Hip", "CC_Base_Head", "CC_Base_L_Thigh", "CC_Base_R_Thigh") \
		* _anatomy_frame(src_skel, an["hips"], an["head"], an["thigh_l"], an["thigh_r"]).inverse()

	var map: Dictionary = s["map"]
	for sname in map:
		var sb := src_skel.find_bone(sname)
		var db := _fb(dst_skel, map[sname])
		if sb < 0 or db < 0:
			continue
		_pairs.append({
			"src": sb, "dst": db,
			"grs_inv": _rest_global(src_skel, sb).basis.orthonormalized().inverse(),
			"grd": _rest_global(dst_skel, db).basis.orthonormalized(),
			"depth": _depth(dst_skel, db),
			"rest": Quaternion(dst_skel.get_bone_rest(db).basis.orthonormalized()),
		})
	_pairs.sort_custom(func(a, b): return a["depth"] < b["depth"])


func mapped_count() -> int:
	return _pairs.size()


# Copy the source pose onto the CC skeleton, blended toward CC rest by (1-weight)
# so weight 0 stands at rest and weight 1 is the full animation.
func apply(weight: float = 1.0) -> void:
	var a_inv := align.inverse()
	for p in _pairs:
		var gcs: Basis = src_skel.get_bone_global_pose(p["src"]).basis
		var wcc: Basis = align * (gcs * (p["grs_inv"] as Basis)) * a_inv
		var desired: Basis = wcc * (p["grd"] as Basis)
		var par := dst_skel.get_bone_parent(p["dst"])
		var parent_basis: Basis = dst_skel.get_bone_global_pose(par).basis if par >= 0 else Basis()
		var q := (parent_basis.inverse() * desired).get_rotation_quaternion()
		if weight < 0.999:
			q = (p["rest"] as Quaternion).slerp(q, clampf(weight, 0.0, 1.0))
		dst_skel.set_bone_pose_rotation(p["dst"], q)


# ---- setup helpers --------------------------------------------------------

func _detect_scheme() -> String:
	for name in _SCHEMES:
		if src_skel.find_bone(_SCHEMES[name]["detect"]) >= 0:
			return name
	return ""


# Resolve a CC bone name with or without the "CC_Base_" prefix, so the same map
# drives both the CC_Base_* skeleton and the newer prefix-less character rig.
func _fb(skel: Skeleton3D, name: String) -> int:
	var b := skel.find_bone(name)
	if b < 0:
		b = skel.find_bone(name.trim_prefix("CC_Base_"))
	return b


func _anatomy_frame(skel: Skeleton3D, hips: String, head: String, thigh_l: String, thigh_r: String) -> Basis:
	var hip_p := _rest_global(skel, _fb(skel, hips)).origin
	var head_p := _rest_global(skel, _fb(skel, head)).origin
	var lthigh := _rest_global(skel, _fb(skel, thigh_l)).origin
	var rthigh := _rest_global(skel, _fb(skel, thigh_r)).origin
	var y := (head_p - hip_p).normalized()
	var x := (lthigh - rthigh).normalized()
	var z := x.cross(y).normalized()
	x = y.cross(z).normalized()
	if y.length() < 0.5 or z.length() < 0.5:
		return Basis()
	return Basis(x, y, z)


func _rest_global(skel: Skeleton3D, bone: int) -> Transform3D:
	var xf := Transform3D()
	var b := bone
	var chain: Array = []
	while b >= 0:
		chain.append(b)
		b = skel.get_bone_parent(b)
	for i in range(chain.size() - 1, -1, -1):
		xf = xf * skel.get_bone_rest(chain[i])
	return xf


func _depth(skel: Skeleton3D, bone: int) -> int:
	var d := 0
	var b := skel.get_bone_parent(bone)
	while b >= 0:
		d += 1
		b = skel.get_bone_parent(b)
	return d
