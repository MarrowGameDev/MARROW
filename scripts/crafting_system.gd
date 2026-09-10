extends Node
## Autoload "CraftingSystem" — the player's crafting MATERIALS, the ITEMS they've crafted, and
## the craft / improve rules. Recipes live here (single source of truth); crafting_ui.gd only
## renders what it's given. Materials come from scavenge stations on the puppet piles; items
## are what the Phase 1 parts model will turn into real sockets/abilities.
##
## TUTORIAL ECONOMY: four materials — wood plank, screws, rope, glue. Every tutorial recipe is
## built from these; later phases add more.
##
## Reached via get_node("/root/CraftingSystem") so it also works in headless tests where
## autoloads aren't registered.

signal materials_changed(materials: Dictionary)
signal items_changed(items: Array)
signal item_crafted(item: Dictionary)
signal item_improved(item: Dictionary)
signal craft_failed(recipe_id: String, reason: String)

const MAX_LEVEL := 5

const MATERIAL_NAMES := {
	"wood_plank": "Wood plank",
	"screws": "Screws",
	"rope": "Rope",
	"glue": "Glue",
}

## Recipe contract: id, name, category (PARTS/WEAPONS/ARMOR/TORSOS), desc, result,
## ingredients [{id, qty}] to craft, improve [{id, qty}] per level-up.
var recipes: Array = [
	# ---- PARTS ----
	{"id": "wooden_arm", "name": "Wooden Arm", "category": "PARTS", "result": "Arm part",
	 "desc": "A jointed puppet limb. Grants Strike I and a little reach.",
	 "ingredients": [{"id": "wood_plank", "qty": 2}, {"id": "screws", "qty": 2}, {"id": "glue", "qty": 1}],
	 "improve": [{"id": "wood_plank", "qty": 1}, {"id": "screws", "qty": 1}]},
	{"id": "wooden_leg", "name": "Wooden Leg", "category": "PARTS", "result": "Leg part",
	 "desc": "A sturdy puppet leg. Grants Speed I and Jump I.",
	 "ingredients": [{"id": "wood_plank", "qty": 2}, {"id": "screws", "qty": 2}, {"id": "rope", "qty": 1}],
	 "improve": [{"id": "wood_plank", "qty": 1}, {"id": "rope", "qty": 1}]},
	{"id": "wooden_head", "name": "Wooden Head", "category": "PARTS", "result": "Head part",
	 "desc": "A carved head with a hinged jaw. Grants Bite I.",
	 "ingredients": [{"id": "wood_plank", "qty": 1}, {"id": "screws", "qty": 1}, {"id": "glue", "qty": 1}],
	 "improve": [{"id": "glue", "qty": 1}, {"id": "screws", "qty": 1}]},
	# ---- WEAPONS ----
	{"id": "plank_club", "name": "Plank Club", "category": "WEAPONS", "result": "Weapon",
	 "desc": "A plank with a rope grip. Strike damage up.",
	 "ingredients": [{"id": "wood_plank", "qty": 2}, {"id": "rope", "qty": 1}],
	 "improve": [{"id": "wood_plank", "qty": 1}, {"id": "screws", "qty": 2}]},
	{"id": "screw_spike", "name": "Screw Spike", "category": "WEAPONS", "result": "Weapon",
	 "desc": "Screws driven through a plank. Grants Charge I.",
	 "ingredients": [{"id": "wood_plank", "qty": 1}, {"id": "screws", "qty": 3}],
	 "improve": [{"id": "screws", "qty": 2}, {"id": "glue", "qty": 1}]},
	# ---- ARMOR ----
	{"id": "plank_chest", "name": "Plank Chestplate", "category": "ARMOR", "result": "Armor",
	 "desc": "Planks lashed over the torso. Health up.",
	 "ingredients": [{"id": "wood_plank", "qty": 3}, {"id": "rope", "qty": 2}],
	 "improve": [{"id": "wood_plank", "qty": 1}, {"id": "rope", "qty": 1}]},
	{"id": "glued_shell", "name": "Glued Shell", "category": "ARMOR", "result": "Armor",
	 "desc": "Layered plank shell, glued tight. Health up, Sneak down.",
	 "ingredients": [{"id": "wood_plank", "qty": 2}, {"id": "glue", "qty": 2}],
	 "improve": [{"id": "glue", "qty": 1}, {"id": "screws", "qty": 1}]},
	# ---- TORSOS ----
	{"id": "animal_torso", "name": "Animal Torso", "category": "TORSOS", "result": "Torso core",
	 "desc": "A carved quadruped core: 4 leg sockets, head, tail. Becomes your body.",
	 "ingredients": [{"id": "wood_plank", "qty": 4}, {"id": "screws", "qty": 4}, {"id": "rope", "qty": 2}, {"id": "glue", "qty": 1}],
	 "improve": [{"id": "wood_plank", "qty": 2}, {"id": "screws", "qty": 2}]},
	{"id": "mech_torso", "name": "Mechanical Torso", "category": "TORSOS", "result": "Torso core",
	 "desc": "A screw-and-plank core: 2 wheel mounts, 2 arm mounts, head. Becomes your body.",
	 "ingredients": [{"id": "wood_plank", "qty": 4}, {"id": "screws", "qty": 6}, {"id": "glue", "qty": 2}],
	 "improve": [{"id": "screws", "qty": 3}, {"id": "glue", "qty": 1}]},
]

var materials: Dictionary = {}    # material id -> count
var items: Array = []             # crafted: {uid, recipe_id, name, category, level}
var _next_uid := 1


# ---- materials ---------------------------------------------------------------
static func material_name(id: String) -> String:
	return MATERIAL_NAMES.get(id, id.capitalize())

func count(id: String) -> int:
	return int(materials.get(id, 0))

func add_material(id: String, qty: int) -> void:
	if qty <= 0:
		return
	materials[id] = count(id) + qty
	materials_changed.emit(materials)

func add_materials(bundle: Dictionary) -> void:
	for id in bundle:
		var q: int = int(bundle[id])
		if q > 0:
			materials[id] = count(id) + q
	materials_changed.emit(materials)

func has_all(req: Array) -> bool:
	for ing in req:
		if count(str(ing.get("id", ""))) < int(ing.get("qty", 1)):
			return false
	return true

func _consume(req: Array) -> void:
	for ing in req:
		var id := str(ing.get("id", ""))
		materials[id] = count(id) - int(ing.get("qty", 1))
		if materials[id] <= 0:
			materials.erase(id)
	materials_changed.emit(materials)


# ---- recipes / ownership -------------------------------------------------------
func get_recipe(id: String) -> Dictionary:
	for r in recipes:
		if r.get("id", "") == id:
			return r
	return {}

## The best (highest-level) crafted item of a recipe, or {} if none owned.
func owned_of(recipe_id: String) -> Dictionary:
	var best: Dictionary = {}
	for it in items:
		if it.get("recipe_id", "") == recipe_id and int(it.get("level", 1)) > int(best.get("level", 0)):
			best = it
	return best

func owned_count(recipe_id: String) -> int:
	var n := 0
	for it in items:
		if it.get("recipe_id", "") == recipe_id:
			n += 1
	return n


# ---- craft / improve -----------------------------------------------------------
func can_craft(recipe_id: String) -> bool:
	var r := get_recipe(recipe_id)
	return not r.is_empty() and has_all(r.get("ingredients", []))

func craft(recipe_id: String) -> Dictionary:
	var r := get_recipe(recipe_id)
	if r.is_empty():
		craft_failed.emit(recipe_id, "unknown recipe")
		return {}
	if not has_all(r.get("ingredients", [])):
		craft_failed.emit(recipe_id, "missing materials")
		return {}
	_consume(r.get("ingredients", []))
	var item := {"uid": _next_uid, "recipe_id": recipe_id, "name": r.get("name", recipe_id),
		"category": r.get("category", ""), "level": 1}
	_next_uid += 1
	items.append(item)
	items_changed.emit(items)
	item_crafted.emit(item)
	return item

func can_improve(recipe_id: String) -> bool:
	var r := get_recipe(recipe_id)
	var it := owned_of(recipe_id)
	return not r.is_empty() and not it.is_empty() and int(it.get("level", 1)) < MAX_LEVEL and has_all(r.get("improve", []))

func improve(recipe_id: String) -> Dictionary:
	var r := get_recipe(recipe_id)
	var it := owned_of(recipe_id)
	if r.is_empty() or it.is_empty():
		craft_failed.emit(recipe_id, "nothing to improve")
		return {}
	if int(it.get("level", 1)) >= MAX_LEVEL:
		craft_failed.emit(recipe_id, "already max level")
		return {}
	if not has_all(r.get("improve", [])):
		craft_failed.emit(recipe_id, "missing materials")
		return {}
	_consume(r.get("improve", []))
	it["level"] = int(it.get("level", 1)) + 1
	items_changed.emit(items)
	item_improved.emit(it)
	return it
