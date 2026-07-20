class_name RetargetedLocomotion
extends RefCounted

# Drives a CC skeleton from the mannequin animation library: an AnimationTree
# blends idle<->walk on the (hidden) source skeleton by speed, and a
# SkeletonRetargeter copies the blended pose onto the CC skeleton each frame.
#
# Reusable by any scene that has the CC skeleton — the demo and, later, the player.

var tree: AnimationTree
var retargeter: SkeletonRetargeter
var _blend := 0.0


func _init(source_model: Node, cc_skeleton: Skeleton3D, tree_parent: Node,
		idle_clip: String, walk_clip: String) -> void:
	var src := _skel(source_model)
	var ap := _find_ap(source_model)
	for clip in [idle_clip, walk_clip]:
		if ap != null and ap.has_animation(clip):
			ap.get_animation(clip).loop_mode = Animation.LOOP_LINEAR

	var blend := AnimationNodeBlendSpace1D.new()
	var idle_node := AnimationNodeAnimation.new()
	idle_node.animation = idle_clip
	var walk_node := AnimationNodeAnimation.new()
	walk_node.animation = walk_clip
	blend.add_blend_point(idle_node, 0.0)
	blend.add_blend_point(walk_node, 1.0)

	tree = AnimationTree.new()
	tree.tree_root = blend
	tree_parent.add_child(tree)
	tree.anim_player = tree.get_path_to(ap)
	tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	tree.active = true

	retargeter = SkeletonRetargeter.new(src, cc_skeleton)


# Advance the animation for `delta` at the given 0..1 gait speed and copy the pose
# to the CC skeleton.
func update(delta: float, speed_ratio: float) -> void:
	_blend = clampf(speed_ratio, 0.0, 1.0)
	tree.set("parameters/blend_position", _blend)
	tree.advance(delta)
	retargeter.apply()


func _skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _skel(c)
		if f != null:
			return f
	return null


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null
