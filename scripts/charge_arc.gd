extends Control

# A circular charge gauge: an arc spanning `arc_fraction` of a full circle (2/5 = 144°).
# `ratio` (0..1) fills the arc from one end; drawn centred on this Control's position.

@export var arc_fraction: float = 0.4    # 2/5 of a circle
@export var radius: float = 54.0
@export var thickness: float = 12.0

var ratio: float = 0.0


func set_ratio(v: float) -> void:
	var nr := clampf(v, 0.0, 1.0)
	if not is_equal_approx(nr, ratio):
		ratio = nr
		queue_redraw()


func _draw() -> void:
	var span := arc_fraction * TAU
	var start := -span * 0.5                  # bulge points RIGHT, so the concave inside faces screen centre (left)
	# background track
	draw_arc(Vector2.ZERO, radius, start, start + span, 64, Color(0.0, 0.0, 0.0, 0.5), thickness, true)
	# fill (yellow -> red as it approaches the limit)
	if ratio > 0.001:
		var col := Color(1.0, 0.85, 0.2).lerp(Color(1.0, 0.25, 0.1), ratio)
		draw_arc(Vector2.ZERO, radius, start, start + span * ratio, 64, col, thickness, true)
