extends InteractStation
class_name ScavengeStation
## A puppet pile you can pick over: E grants a random bundle of crafting materials from the
## loot table, a few times, then the pile is picked clean. Auto-attached to the pile models
## by scavenge_root.gd (loot chosen per pile type); also droppable by hand as
## scavenge_station.tscn. Materials go straight into the CraftingSystem autoload.

@export var loot: Array = []      # [{id, min, max, chance}] — rolled independently per entry
@export var charges: int = 3      # how many times the pile can be scavenged

var _left: int = 0


func _init() -> void:
	prompt_text = "Press E to scavenge"


func _ready() -> void:
	super()
	_left = charges
	_refresh_prompt()


func _can_interact() -> bool:
	return _left > 0


func _on_interact() -> void:
	var sys = system()
	if sys == null:
		flash("No crafting system loaded.")
		return
	var bundle := roll()
	sys.add_materials(bundle)
	_left -= 1
	var parts: Array = []
	for id in bundle:
		parts.append("+%d %s" % [int(bundle[id]), sys.material_name(id)])
	flash(", ".join(parts) if not parts.is_empty() else "Nothing useful...")
	_refresh_prompt()


## Roll the loot table into a {material_id: qty} bundle.
func roll() -> Dictionary:
	var out: Dictionary = {}
	for e in loot:
		if randf() <= float(e.get("chance", 1.0)):
			var q: int = randi_range(int(e.get("min", 1)), int(e.get("max", 1)))
			if q > 0:
				var id := str(e.get("id", ""))
				out[id] = int(out.get(id, 0)) + q
	return out


func _refresh_prompt() -> void:
	set_prompt("Press E to scavenge  (%d left)" % _left if _left > 0 else "Picked clean")
