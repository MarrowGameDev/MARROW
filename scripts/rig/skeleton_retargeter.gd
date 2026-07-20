class_name SkeletonRetargeter
extends RefCounted

# Play an animation authored for one humanoid skeleton (the Quaternius mannequin:
# pelvis / spine_01 / upperarm_l …) on another (the CC skeleton: CC_Base_*).
#
# Method (global-delta with anatomical alignment):
#   * Each frame, take the source bone's world rotation FROM ITS REST:
#         Wsrc = src_global · src_rest_global⁻¹
#   * The two skeletons don't face the same way in their own spaces, so rotate
#     that delta into the target's frame with an alignment A built from each
#     skeleton's own anatomy (hips→head = up, hip→hip = lateral):
#         Wcc = A · Wsrc · A⁻¹
#   * Apply to the target's rest and write back as a parent-local pose:
#         dst_global = Wcc · dst_rest_global ,  dst_local = dst_parentⁿᵒʷ⁻¹ · dst_global
# Bones are posed parent→child so each parent's updated global is available.
# The delta is rest-relative, so each skeleton keeps its own facing/proportions.

const MAP := {
	"pelvis": "CC_Base_Hip",
	"spine_01": "CC_Base_Waist",
	"spine_02": "CC_Base_Spine01",
	"spine_03": "CC_Base_Spine02",
	"neck_01": "CC_Base_NeckTwist01",
	"Head": "CC_Base_Head",
	"clavicle_l": "CC_Base_L_Clavicle",
	"upperarm_l": "CC_Base_L_Upperarm",
	"lowerarm_l": "CC_Base_L_Forearm",
	"hand_l": "CC_Base_L_Hand",
	"clavicle_r": "CC_Base_R_Clavicle",
	"upperarm_r": "CC_Base_R_Upperarm",
	"lowerarm_r": "CC_Base_R_Forearm",
	"hand_r": "CC_Base_R_Hand",
	"thigh_l": "CC_Base_L_Thigh",
	"calf_l": "CC_Base_L_Calf",
	"foot_l": "CC_Base_L_Foot",
	"thigh_r": "CC_Base_R_Thigh",
	"calf_r": "CC_Base_R_Calf",
	"foot_r": "CC_Base_R_Foot",
}

var src_skel: Skeleton3D
var dst_skel: Skeleton3D
var align: Basis = Basis()           # source frame -> target frame
var _pairs: Array = []               # {src, dst, grs_inv:Basis, grd:Basis, depth:int}


func _init(source: Skeleton3D, target: Skeleton3D) -> void:
	src_skel = source
	dst_skel = target
	align = _anatomy_frame(dst_skel, "CC_Base_Hip", "CC_Base_Head", "CC_Base_L_Thigh", "CC_Base_R_Thigh") \
		* _anatomy_frame(src_skel, "pelvis", "Head", "thigh_l", "thigh_r").inverse()

	for sname in MAP:
		var s := src_skel.find_bone(sname)
		var d := dst_skel.find_bone(MAP[sname])
		if s < 0 or d < 0:
			continue
		_pairs.append({
			"src": s, "dst": d,
			"grs_inv": _rest_global(src_skel, s).basis.orthonormalized().inverse(),
			"grd": _rest_global(dst_skel, d).basis.orthonormalized(),
			"depth": _depth(dst_skel, d),
		})
	_pairs.sort_custom(func(a, b): return a["depth"] < b["depth"])   # parent-first


func mapped_count() -> int:
	return _pairs.size()


func apply() -> void:
	var a_inv := align.inverse()
	for p in _pairs:
		var gcs: Basis = src_skel.get_bone_global_pose(p["src"]).basis
		var wsrc: Basis = gcs * (p["grs_inv"] as Basis)
		var wcc: Basis = align * wsrc * a_inv
		var desired: Basis = wcc * (p["grd"] as Basis)
		var par := dst_skel.get_bone_parent(p["dst"])
		var parent_basis: Basis = dst_skel.get_bone_global_pose(par).basis if par >= 0 else Basis()
		var local: Basis = parent_basis.inverse() * desired
		dst_skel.set_bone_pose_rotation(p["dst"], local.get_rotation_quaternion())


# Orthonormal frame from anatomy: y = hips->head, x = right-hip->left-hip, z = x×y.
# Built the SAME way for both skeletons, so align = frame_dst · frame_src⁻¹ maps
# one into the other regardless of each rig's axis conventions.
func _anatomy_frame(skel: Skeleton3D, hips: String, head: String, thigh_l: String, thigh_r: String) -> Basis:
	var hip_p := _rest_global(skel, skel.find_bone(hips)).origin
	var head_p := _rest_global(skel, skel.find_bone(head)).origin
	var lthigh := _rest_global(skel, skel.find_bone(thigh_l)).origin
	var rthigh := _rest_global(skel, skel.find_bone(thigh_r)).origin
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
