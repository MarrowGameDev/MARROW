extends Control

# The player's LIFE as a row of bones, top-left. Each bone is one hit: FULL or OUTLINE (empty).
# Damage empties the bones RIGHT -> LEFT, so the far-left bone is the last life left.
#
# Self-contained: it listens on the GameEvents bus for player_health_changed and needs no wiring
# beyond being added to a CanvasLayer. Robust to any max_health (maps hp proportionally to the
# bones); with max_health = bone_count it maps 1 hit = 1 bone.

const BONE_FULL: Texture2D = preload("res://assets/ui/bone_full.svg")
const BONE_OUTLINE: Texture2D = preload("res://assets/ui/bone_outline.svg")

@export var bone_count: int = 4
@export var bone_size: Vector2 = Vector2(44, 39)   # ~1.14:1 to match the 45°-tilted cropped bone art (844x742)
@export var bone_gap: float = 3.0
@export var margin: Vector2 = Vector2(20, 14)

var _bones: Array[TextureRect] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	for i in bone_count:
		var b := TextureRect.new()
		b.texture = BONE_FULL
		b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE   # DON'T inherit the texture's native size (891px) — honour bone_size
		b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		b.custom_minimum_size = bone_size
		b.size = bone_size
		b.position = Vector2(margin.x + i * (bone_size.x + bone_gap), margin.y)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(b)
		_bones.append(b)
	GameEvents.player_health_changed.connect(_on_health)


func _on_health(_player: Node, hp: int, max_hp: int) -> void:
	# how many bones remain full (ceil so any HP > 0 always shows at least one bone)
	var full := clampi(int(ceil(float(hp) / float(maxi(max_hp, 1)) * bone_count)), 0, bone_count)
	for i in _bones.size():
		# bones fill from the LEFT, so the rightmost empty first
		_bones[i].texture = BONE_FULL if i < full else BONE_OUTLINE
