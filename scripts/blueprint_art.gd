extends Control
class_name BlueprintArt
## The picture on a blueprint: one schematic per recipe, drawn in pale ink on a transparent
## ground (only the alpha matters — the sheet shader colours it). Rendered by the prop's
## SubViewport onto the sheet, landscape: left -> right is the long side of the sheet and the
## top is the far edge of the bench. The bottom band is kept clear for the floating title.

var recipe: Dictionary = {}
var draw_count := 0            # for tests: how many times the picture was (re)drawn

const INK := Color(1.0, 1.0, 1.0, 0.95)
const FAINT := Color(1.0, 1.0, 1.0, 0.42)
const LINE := 3.0


func _draw() -> void:
	draw_count += 1
	var w := size.x
	var h := size.y
	_frame(w, h)
	var box := Rect2(w * 0.07, h * 0.08, w * 0.58, h * 0.64)   # the drawing area
	match str(recipe.get("id", "")):
		"wooden_arm": _arm(box)
		"wooden_leg": _leg(box)
		"wooden_head": _head(box)
		"plank_club": _club(box)
		"screw_spike": _spike(box)
		"plank_chest": _chest(box)
		"glued_shell": _shell(box)
		"wooden_torso": _torso(box)
		_: _unknown(box)
	_notes(Rect2(w * 0.70, h * 0.10, w * 0.24, h * 0.62))
	_title_block(w, h)


# ---- the schematics -------------------------------------------------------------------
func _arm(box: Rect2) -> void:
	var sh := _at(box, 0.05, 0.40)
	var el := _at(box, 0.42, 0.28)
	var wr := _at(box, 0.72, 0.46)
	var tip := _at(box, 0.97, 0.52)
	var th := box.size.y * 0.15
	_plank(sh, el, th)
	_plank(el, wr, th * 0.85)
	_joint(sh, th * 0.42)
	_joint(el, th * 0.40)
	_joint(wr, th * 0.32)
	for t in [0.2, 0.8]:
		_screw(sh.lerp(el, t))
		_screw(el.lerp(wr, t))
	var palm_end := wr.lerp(tip, 0.42)
	_plank(wr, palm_end, th * 0.9, 1)
	var d := (tip - wr).normalized()
	for i in 4:
		var base := palm_end + Vector2(0.0, (float(i) - 1.5) * th * 0.26)
		var reach := box.size.x * 0.13 * (1.0 - 0.12 * absf(float(i) - 1.5))
		_seg(base, base + d * reach, INK, 3.0)
		_joint(base + d * reach * 0.5, 4.0)
	_dim(sh + Vector2(0.0, th * 1.1), tip + Vector2(0.0, th * 0.6), Vector2(0.0, box.size.y * 0.24), "REACH")
	_text(_at(box, 0.04, 0.95), "PIN JOINTS ×3 · GLUE THE PALM", 18, FAINT)


func _leg(box: Rect2) -> void:
	var hip := _at(box, 0.38, 0.06)
	var knee := _at(box, 0.46, 0.50)
	var ankle := _at(box, 0.40, 0.86)
	var toe := _at(box, 0.68, 0.90)
	var th := box.size.x * 0.10
	_plank(hip, knee, th)
	_plank(knee, ankle, th * 0.85)
	_plank(ankle + Vector2(-th * 0.4, 0.0), toe, th * 0.7, 1)
	_joint(hip, th * 0.45)
	_joint(knee, th * 0.40)
	_joint(ankle, th * 0.30)
	_rope(knee.lerp(ankle, 0.16), knee.lerp(ankle, 0.44), th, 5)
	_screw(hip.lerp(knee, 0.2))
	_screw(hip.lerp(knee, 0.8))
	_screw(knee.lerp(ankle, 0.78))
	_dim(hip + Vector2(-th, 0.0), ankle + Vector2(-th, 0.0), Vector2(-box.size.x * 0.16, 0.0), "STRIDE")
	_text(_at(box, 0.62, 0.30), "ROPE-BOUND KNEE", 18, FAINT)
	_dashed(_at(box, 0.61, 0.34), knee + Vector2(th * 0.6, 0.0))


func _head(box: Rect2) -> void:
	var c := _at(box, 0.38, 0.42)
	var rx := box.size.x * 0.22
	var ry := box.size.y * 0.36
	_ellipse(c, rx, ry)
	_seg(c + Vector2(-rx * 0.92, ry * 0.35), c + Vector2(rx * 0.92, ry * 0.35), FAINT, 2.0)   # jaw seam
	for sx in [-0.42, 0.42]:                                                                  # empty sockets
		var e := c + Vector2(rx * sx, -ry * 0.15)
		draw_arc(e, rx * 0.2, 0.0, TAU, 24, FAINT, 2.0, true)
		_seg(e + Vector2(-rx * 0.1, -rx * 0.1), e + Vector2(rx * 0.1, rx * 0.1), FAINT, 2.0)
		_seg(e + Vector2(rx * 0.1, -rx * 0.1), e + Vector2(-rx * 0.1, rx * 0.1), FAINT, 2.0)
	_poly(PackedVector2Array([c + Vector2(rx * 0.10, -ry), c + Vector2(rx * 0.04, -ry * 0.62),
		c + Vector2(rx * 0.20, -ry * 0.42), c + Vector2(rx * 0.12, -ry * 0.12)]), FAINT, 2.0, false)   # a crack
	var peg := Rect2(c.x - rx * 0.18, c.y + ry, rx * 0.36, ry * 0.36)                        # neck peg
	draw_rect(peg, INK, false, LINE)
	_screw(peg.get_center())
	var tv := _at(box, 0.82, 0.40)                                                            # top view
	_ring(tv, rx * 0.55)
	_dashed(tv + Vector2(-rx * 0.72, 0.0), tv + Vector2(rx * 0.72, 0.0))
	_dashed(tv + Vector2(0.0, -rx * 0.72), tv + Vector2(0.0, rx * 0.72))
	_text(_at(box, 0.78, 0.82), "TOP", 18, FAINT)
	_dim(c + Vector2(-rx, ry * 1.05), c + Vector2(rx, ry * 1.05), Vector2(0.0, box.size.y * 0.12), "Ø")
	_text(_at(box, 0.04, 0.95), "SOCKETS LEFT EMPTY", 18, FAINT)


func _club(box: Rect2) -> void:
	var a := _at(box, 0.04, 0.56)
	var b := _at(box, 0.96, 0.40)
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	var grip := box.size.y * 0.09
	var head := box.size.y * 0.30
	var g_end := a.lerp(b, 0.36)
	_poly(PackedVector2Array([a + n * grip * 0.5, g_end + n * grip * 0.5, b + n * head * 0.5,
		b - n * head * 0.5, g_end - n * grip * 0.5, a - n * grip * 0.5]))
	for k in [-0.25, 0.15]:                                                # grain along the head
		_seg(g_end.lerp(b, 0.12) + n * head * k * 0.6, g_end.lerp(b, 0.92) + n * head * k, FAINT, 1.5)
	_rope(a.lerp(b, 0.05), a.lerp(b, 0.31), grip, 9)
	for t in [0.62, 0.78, 0.92]:
		_screw(a.lerp(b, t) + n * head * 0.16)
	_dim(a - n * head * 0.62, b - n * head * 0.62, -n * box.size.y * 0.16, "LENGTH")
	_text(_at(box, 0.04, 0.95), "ROPE GRIP · TWO PLANKS GLUED", 18, FAINT)


func _spike(box: Rect2) -> void:
	var h0 := _at(box, 0.05, 0.50)
	var h1 := _at(box, 0.30, 0.50)
	var tip := _at(box, 0.96, 0.50)
	var th := box.size.y * 0.16
	_plank(h0, h1, th, 2)
	var half := box.size.y * 0.13
	_poly(PackedVector2Array([h1 + Vector2(0.0, -half), tip, h1 + Vector2(0.0, half)]))
	for i in 9:                                                            # the thread
		var t := 0.06 + float(i) * 0.09
		var p := h1.lerp(tip, t)
		var s := half * (1.0 - t) * 0.9
		_seg(p + Vector2(-8.0, -s), p + Vector2(8.0, s), FAINT, 2.0)
	for v in [-0.55, 0.0, 0.55]:                                           # screws through the collar
		_screw(h1 + Vector2(10.0, half * v * 1.3))
	_dim(h1 + Vector2(0.0, half * 1.5), tip + Vector2(0.0, half * 1.5), Vector2(0.0, box.size.y * 0.16), "SPIKE")
	_text(_at(box, 0.04, 0.95), "3 SCREWS THROUGH THE COLLAR", 18, FAINT)


func _chest(box: Rect2) -> void:
	var outline := PackedVector2Array([_at(box, 0.08, 0.10), _at(box, 0.52, 0.10), _at(box, 0.56, 0.30),
		_at(box, 0.50, 0.90), _at(box, 0.10, 0.90), _at(box, 0.04, 0.30)])
	_poly(outline)
	for v in [0.37, 0.64]:                                                 # three planks
		_seg(_at(box, 0.05, v), _at(box, 0.55, v), INK, 2.5)
	for v in [0.22, 0.50, 0.78]:                                           # grain
		_seg(_at(box, 0.12, v), _at(box, 0.48, v + 0.02), FAINT, 1.5)
	for side in [0.07, 0.53]:                                              # rope lacing down both sides
		var prev := _at(box, side, 0.14)
		for i in 7:
			var nxt := _at(box, side + (0.04 if i % 2 == 0 else 0.0) - 0.02, 0.14 + float(i + 1) * 0.1)
			_seg(prev, nxt, INK, 2.0)
			prev = nxt
	for p in [Vector2(0.14, 0.18), Vector2(0.46, 0.18), Vector2(0.12, 0.44), Vector2(0.48, 0.44),
			Vector2(0.14, 0.72), Vector2(0.46, 0.72)]:
		_screw(_at(box, p.x, p.y))
	var pts := PackedVector2Array()                                        # side profile
	for i in 25:
		var t := float(i) / 24.0
		pts.append(_at(box, 0.78 + sin(t * PI) * 0.10, 0.12 + t * 0.78))
	draw_polyline(pts, INK, LINE, true)
	for i in pts.size():
		pts[i] += Vector2(-18.0, 0.0)
	draw_polyline(pts, INK, LINE, true)
	_text(_at(box, 0.74, 0.97), "SIDE", 18, FAINT)
	_dim(_at(box, 0.04, 0.06), _at(box, 0.56, 0.06), Vector2(0.0, -box.size.y * 0.04), "CHEST")


func _shell(box: Rect2) -> void:
	var base := _at(box, 0.32, 0.86)
	var rx := box.size.x * 0.28
	var ry := box.size.y * 0.72
	_ellipse_arc(base, rx, ry, PI, TAU, INK, LINE)
	_seg(base + Vector2(-rx, 0.0), base + Vector2(rx, 0.0))
	for k in [0.72, 0.46]:                                                 # glue seams
		_ellipse_arc(base, rx * k, ry * k, PI, TAU, FAINT, 1.5)
	for cr in [[0.18, 0.30], [-0.22, 0.22], [0.06, 0.62]]:                  # glued cracks
		var s := base + Vector2(rx * cr[0], -ry * cr[1])
		_poly(PackedVector2Array([s, s + Vector2(9.0, 14.0), s + Vector2(-4.0, 26.0), s + Vector2(7.0, 40.0)]), INK, 2.0, false)
		for j in 3:
			var g := s + Vector2(0.0, 8.0 + float(j) * 12.0)
			_seg(g + Vector2(-9.0, 0.0), g + Vector2(9.0, 0.0), FAINT, 2.0)
	for dx in [-0.6, -0.1, 0.45]:                                          # drips at the rim
		var p := base + Vector2(rx * dx, 0.0)
		_seg(p, p + Vector2(0.0, 12.0), FAINT, 2.0)
		draw_arc(p + Vector2(0.0, 16.0), 4.0, 0.0, TAU, 12, FAINT, 2.0, true)
	var sc := _at(box, 0.82, 0.86)                                         # section
	_ellipse_arc(sc, rx * 0.42, ry * 0.42, PI, TAU, INK, LINE)
	_ellipse_arc(sc, rx * 0.30, ry * 0.30, PI, TAU, INK, LINE)
	for i in 7:
		var a := PI + PI * (float(i) + 0.5) / 7.0
		_seg(sc + Vector2(cos(a) * rx * 0.30, sin(a) * ry * 0.30), sc + Vector2(cos(a) * rx * 0.42, sin(a) * ry * 0.42), FAINT, 1.5)
	_text(_at(box, 0.76, 0.97), "SECTION", 18, FAINT)
	_text(_at(box, 0.04, 0.97), "TWO PLANKS BENT · LAYERS OF GLUE", 18, FAINT)


func _torso(box: Rect2) -> void:
	var l := 0.22
	var r := 0.68
	var body := PackedVector2Array([_at(box, l + 0.05, 0.08), _at(box, r - 0.05, 0.08), _at(box, r, 0.16),
		_at(box, r, 0.86), _at(box, r - 0.06, 0.92), _at(box, l + 0.06, 0.92), _at(box, l, 0.86), _at(box, l, 0.16)])
	_poly(body)
	var core := _at(box, 0.45, 0.50)
	_ring(core, box.size.y * 0.09)
	_seg(core + Vector2(-16.0, 0.0), core + Vector2(16.0, 0.0), INK, 2.0)
	_seg(core + Vector2(0.0, -16.0), core + Vector2(0.0, 16.0), INK, 2.0)
	_text(core + Vector2(-22.0, box.size.y * 0.09 + 22.0), "CORE", 18, FAINT)
	var sr := box.size.y * 0.07
	for s in [Vector2(0.45, 0.08), Vector2(l, 0.24), Vector2(r, 0.24), Vector2(l + 0.08, 0.92), Vector2(r - 0.08, 0.92)]:
		var p := _at(box, s.x, s.y)
		_ring(p, sr)
		draw_arc(p, sr * 0.55, 0.0, TAU, 24, FAINT, 2.0, true)
	_dashed(_at(box, r, 0.24) + Vector2(sr, 0.0), _at(box, 0.86, 0.20))
	_text(_at(box, 0.80, 0.16), "SOCKET ×5", 18, FAINT)
	for v in [0.40, 0.64]:                                                 # rope binding
		_rope(_at(box, l, v), _at(box, r, v), box.size.y * 0.05, 14)
	for p in [Vector2(l + 0.06, 0.14), Vector2(r - 0.06, 0.14), Vector2(l + 0.06, 0.84), Vector2(r - 0.06, 0.84)]:
		_screw(_at(box, p.x, p.y))
	_text(_at(box, 0.04, 0.97), "ANATOMY: %s" % str(recipe.get("anatomy", "normal")).to_upper(), 18, FAINT)


func _unknown(box: Rect2) -> void:
	draw_rect(box.grow(-box.size.y * 0.1), FAINT, false, 2.0)
	_seg(box.position, box.end, FAINT, 2.0)
	_seg(Vector2(box.end.x, box.position.y), Vector2(box.position.x, box.end.y), FAINT, 2.0)
	_text(box.get_center() + Vector2(-12.0, 14.0), "?", 40)


# ---- furniture: frame, notes column, title block ---------------------------------------
func _frame(w: float, h: float) -> void:
	draw_rect(Rect2(w * 0.03, h * 0.04, w * 0.94, h * 0.92), FAINT, false, 2.0)
	for c in [Vector2(w * 0.03, h * 0.04), Vector2(w * 0.97, h * 0.04), Vector2(w * 0.03, h * 0.96), Vector2(w * 0.97, h * 0.96)]:
		var sx := 1.0 if c.x < w * 0.5 else -1.0
		var sy := 1.0 if c.y < h * 0.5 else -1.0
		_seg(c, c + Vector2(sx * 22.0, 0.0), INK, 2.5)
		_seg(c, c + Vector2(0.0, sy * 22.0), INK, 2.5)
	var s0 := Vector2(w * 0.07, h * 0.88)                                  # scale bar
	for i in 4:
		var x0 := s0.x + float(i) * 22.0
		draw_rect(Rect2(x0, s0.y, 22.0, 6.0), INK if i % 2 == 0 else FAINT, i % 2 == 0)
	_text(s0 + Vector2(96.0, 7.0), "SCALE 1 : 4", 16, FAINT)


func _notes(rect: Rect2) -> void:
	var y := rect.position.y
	_text(Vector2(rect.position.x, y + 20.0), "MATERIALS", 22)
	_seg(Vector2(rect.position.x, y + 30.0), Vector2(rect.end.x, y + 30.0), FAINT, 1.5)
	y += 58.0
	for ing in recipe.get("ingredients", []):
		_text(Vector2(rect.position.x, y), "%s  ×%d" % [str(ing.get("id", "")).replace("_", " ").to_upper(), int(ing.get("qty", 0))], 20)
		y += 30.0
	y += 14.0
	_seg(Vector2(rect.position.x, y), Vector2(rect.end.x, y), FAINT, 1.5)
	_text(Vector2(rect.position.x, y + 30.0), "MAKES  %s" % str(recipe.get("result", "")).to_upper(), 18, FAINT)


func _title_block(w: float, h: float) -> void:
	var r := Rect2(w * 0.70, h * 0.78, w * 0.24, h * 0.14)
	draw_rect(r, INK, false, 2.5)
	_seg(Vector2(r.position.x, r.get_center().y), Vector2(r.end.x, r.get_center().y), FAINT, 1.5)
	_text(r.position + Vector2(12.0, 26.0), "MARROW WORKSHOP", 18)
	var id := str(recipe.get("id", ""))
	_text(r.position + Vector2(12.0, r.size.y - 12.0), "%s · No. %03d" % [str(recipe.get("category", "—")), 100 + absi(hash(id)) % 900], 16, FAINT)


# ---- pen strokes --------------------------------------------------------------------
static func _at(box: Rect2, u: float, v: float) -> Vector2:
	return box.position + Vector2(box.size.x * u, box.size.y * v)

func _seg(a: Vector2, b: Vector2, c: Color = INK, wd: float = LINE) -> void:
	draw_line(a, b, c, wd, true)

func _poly(points: PackedVector2Array, c: Color = INK, wd: float = LINE, closed: bool = true) -> void:
	var p := points.duplicate()
	if closed:
		p.append(points[0])
	draw_polyline(p, c, wd, true)

func _ring(centre: Vector2, r: float, c: Color = INK, wd: float = LINE) -> void:
	draw_arc(centre, r, 0.0, TAU, 48, c, wd, true)

func _ellipse(centre: Vector2, rx: float, ry: float, c: Color = INK, wd: float = LINE) -> void:
	_ellipse_arc(centre, rx, ry, 0.0, TAU, c, wd)

func _ellipse_arc(centre: Vector2, rx: float, ry: float, from: float, to: float, c: Color, wd: float) -> void:
	var pts := PackedVector2Array()
	for i in 49:
		var a := lerpf(from, to, float(i) / 48.0)
		pts.append(centre + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, c, wd, true)

func _joint(p: Vector2, r: float) -> void:                # a pin joint: ring + centre cross
	_ring(p, r)
	_seg(p + Vector2(-r * 0.5, 0.0), p + Vector2(r * 0.5, 0.0), FAINT, 2.0)
	_seg(p + Vector2(0.0, -r * 0.5), p + Vector2(0.0, r * 0.5), FAINT, 2.0)

func _screw(p: Vector2, r: float = 9.0) -> void:          # a screw head: ring + slot
	_ring(p, r, INK, 2.5)
	_seg(p + Vector2(-r * 0.6, -r * 0.6), p + Vector2(r * 0.6, r * 0.6), INK, 2.5)

func _plank(a: Vector2, b: Vector2, thick: float, grain: int = 3) -> void:
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x) * (thick * 0.5)
	_poly(PackedVector2Array([a + n, b + n, b - n, a - n]))
	for i in grain:
		var off := n * ((float(i) + 1.0) / (float(grain) + 1.0) * 2.0 - 1.0) * 0.8
		_seg(a.lerp(b, 0.12 + 0.1 * float(i)) + off, a.lerp(b, 0.85 - 0.07 * float(i)) + off, FAINT, 1.5)

func _rope(a: Vector2, b: Vector2, thick: float, turns: int) -> void:   # rope wrapped around
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x) * (thick * 0.6)
	for i in turns:
		_seg(a.lerp(b, float(i) / float(turns)) - n, a.lerp(b, (float(i) + 0.8) / float(turns)) + n, INK, 2.5)

func _dim(a: Vector2, b: Vector2, offset: Vector2, label: String = "") -> void:   # dimension line
	var o := offset.normalized()
	var a2 := a + offset
	var b2 := b + offset
	_seg(a, a2 + o * 8.0, FAINT, 1.5)
	_seg(b, b2 + o * 8.0, FAINT, 1.5)
	_seg(a2, b2, FAINT, 1.5)
	var d := (b2 - a2).normalized() * 10.0
	var n := Vector2(-d.y, d.x) * 0.4
	_seg(a2, a2 + d + n, FAINT, 1.5)
	_seg(a2, a2 + d - n, FAINT, 1.5)
	_seg(b2, b2 - d + n, FAINT, 1.5)
	_seg(b2, b2 - d - n, FAINT, 1.5)
	if label != "":
		_text((a2 + b2) * 0.5 + o * 20.0 + Vector2(-24.0, 6.0), label, 18, FAINT)

func _dashed(a: Vector2, b: Vector2, c: Color = FAINT) -> void:
	draw_dashed_line(a, b, c, 2.0, 10.0, true)

func _text(pos: Vector2, s: String, px: int = 22, c: Color = INK) -> void:
	draw_string(ThemeDB.fallback_font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, c)
