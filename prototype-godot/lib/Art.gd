extends RefCounted
class_name Art
# Hand-authored vector art for Tarkeez, drawn procedurally onto any CanvasItem.
# Single-hump (Arabian/dromedary) camel + desert-oasis decor. All functions are
# static and take the CanvasItem `ci` to draw into, so World/Shop can reuse them.

const INK := Color8(58, 47, 40)

# ---- geometry helpers ------------------------------------------------
static func ellipse(c: Vector2, rx: float, ry: float, seg := 24) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in seg:
		var a := TAU * i / seg
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts

static func _blob(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color) -> void:
	ci.draw_colored_polygon(ellipse(c, rx, ry), col)

static func _outline(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, w := 2.0) -> void:
	var pts := ellipse(c, rx, ry)
	pts.append(pts[0])
	ci.draw_polyline(pts, col, w, true)

# ---- the camel -------------------------------------------------------
# center = ground point under the camel; s = overall scale (~1.0 = 70px tall).
# stage 0 baby … 3 majestic. skin = a Catalog.skin() dict. blink in 0..1.
static func camel(ci: CanvasItem, center: Vector2, s: float, stage: int, skin: Dictionary, t: float, blink := 0.0) -> void:
	var coat: Color = skin.get("coat", Color8(214, 170, 110))
	var coat_dk: Color = skin.get("coat_dk", Color8(184, 140, 86))
	var sad: Color = skin.get("sad", Color8(200, 98, 60))
	var accent: Color = skin.get("accent", Color8(230, 179, 74))

	# proportions per growth stage (baby = chunky head, short legs)
	var P = [
		{"bw": 22, "bh": 15, "leg": 12, "neck": 16, "head": 9, "hump": 9, "eye": 2.6},
		{"bw": 27, "bh": 17, "leg": 16, "neck": 20, "head": 9.5, "hump": 12, "eye": 2.4},
		{"bw": 33, "bh": 20, "leg": 22, "neck": 25, "head": 10, "hump": 15, "eye": 2.3},
		{"bw": 38, "bh": 22, "leg": 27, "neck": 29, "head": 11, "hump": 18, "eye": 2.3},
	][clampi(stage, 0, 3)]

	var bob := sin(t * 2.0) * 1.2 * s
	var bw: float = P.bw * s
	var bh: float = P.bh * s
	var leg: float = P.leg * s
	var body_c := center + Vector2(0, -leg - bh * 0.7 + bob)

	# soft ground shadow
	ci.draw_colored_polygon(ellipse(center + Vector2(2, -2 * s), bw * 0.95, 5 * s), Color(0, 0, 0, 0.13))

	# back legs first (behind body)
	_leg(ci, body_c + Vector2(bw * 0.55, bh * 0.2), leg, s, coat_dk, t, 0.7)
	_leg(ci, body_c + Vector2(-bw * 0.55, bh * 0.2), leg, s, coat_dk, t, 1.9)

	# body
	_blob(ci, body_c, bw, bh, coat)
	# hump (single, Arabian)
	var hump: float = P.hump * s
	var hump_c := body_c + Vector2(bw * 0.02, -bh * 0.78)
	_blob(ci, hump_c, hump * 0.9, hump, coat)
	# belly shade
	_blob(ci, body_c + Vector2(0, bh * 0.35), bw * 0.8, bh * 0.45, Color(coat_dk.r, coat_dk.g, coat_dk.b, 0.4))
	# top highlight
	_blob(ci, body_c + Vector2(-bw * 0.1, -bh * 0.4), bw * 0.55, bh * 0.3, Color(1, 1, 1, 0.12))

	# saddle blanket over the hump/back
	var sad_pts := PackedVector2Array([
		body_c + Vector2(-bw * 0.5, -bh * 0.25),
		hump_c + Vector2(-hump * 0.7, -hump * 0.2),
		hump_c + Vector2(hump * 0.7, -hump * 0.2),
		body_c + Vector2(bw * 0.55, -bh * 0.2),
		body_c + Vector2(bw * 0.5, bh * 0.05),
		body_c + Vector2(-bw * 0.45, bh * 0.0)])
	ci.draw_colored_polygon(sad_pts, sad)
	# blanket trim dots
	for i in 4:
		var tx := lerpf(-bw * 0.4, bw * 0.45, i / 3.0)
		ci.draw_circle(body_c + Vector2(tx, bh * 0.02), 1.6 * s, accent)

	# front legs (in front of body)
	_leg(ci, body_c + Vector2(bw * 0.42, bh * 0.25), leg, s, coat, t, 1.2)
	_leg(ci, body_c + Vector2(-bw * 0.42, bh * 0.25), leg, s, coat, t, 0.2)

	# tail
	var tail_a := 0.4 + sin(t * 1.7) * 0.18
	var tail_root := body_c + Vector2(-bw * 0.95, -bh * 0.1)
	var tail_tip := tail_root + Vector2(-6 * s, (8 + 4 * sin(tail_a)) * s)
	ci.draw_line(tail_root, tail_tip, coat_dk, 2.2 * s, true)
	ci.draw_circle(tail_tip, 2.4 * s, INK)

	# neck + head (facing right)
	var neck_len: float = P.neck * s
	var neck_base := body_c + Vector2(bw * 0.78, -bh * 0.55)
	var head_c := neck_base + Vector2(neck_len * 0.55, -neck_len * 0.85)
	# neck as a tapered quad
	var nw := 6.5 * s
	var ndir := (head_c - neck_base).normalized()
	var nperp := Vector2(-ndir.y, ndir.x)
	ci.draw_colored_polygon(PackedVector2Array([
		neck_base + nperp * nw, neck_base - nperp * nw,
		head_c - nperp * (nw * 0.6), head_c + nperp * (nw * 0.6)]), coat)
	# head
	var hr: float = P.head * s
	_blob(ci, head_c, hr * 1.15, hr, coat)
	# snout
	var snout := head_c + Vector2(hr * 1.05, hr * 0.25)
	_blob(ci, snout, hr * 0.62, hr * 0.5, coat_dk)
	ci.draw_circle(snout + Vector2(hr * 0.35, -hr * 0.05), 1.1 * s, INK) # nostril
	# ear
	ci.draw_colored_polygon(PackedVector2Array([
		head_c + Vector2(-hr * 0.4, -hr * 0.8),
		head_c + Vector2(-hr * 0.05, -hr * 1.5),
		head_c + Vector2(hr * 0.2, -hr * 0.7)]), coat_dk)
	# eye (blink closes it)
	var eye_c := head_c + Vector2(hr * 0.15, -hr * 0.1)
	if blink > 0.5:
		ci.draw_line(eye_c + Vector2(-2.4 * s, 0), eye_c + Vector2(2.4 * s, 0), INK, 1.6 * s, true)
	else:
		ci.draw_circle(eye_c, P.eye * s, INK)
		ci.draw_circle(eye_c + Vector2(-0.7 * s, -0.7 * s), 0.9 * s, Color(1, 1, 1, 0.9))
		# long lashes – charm
		ci.draw_line(eye_c + Vector2(1.4 * s, -1.4 * s), eye_c + Vector2(3.0 * s, -3.0 * s), INK, 1.0, true)
	# smile
	ci.draw_arc(snout + Vector2(0, hr * 0.15), hr * 0.4, 0.15 * PI, 0.85 * PI, 10, INK, 1.3 * s)
	# blush for the baby
	if stage == 0:
		ci.draw_circle(head_c + Vector2(-hr * 0.2, hr * 0.45), 2.2 * s, Color(0.95, 0.5, 0.45, 0.4))

static func _leg(ci: CanvasItem, top: Vector2, length: float, s: float, col: Color, t: float, phase: float) -> void:
	var sway := sin(t * 2.0 + phase) * 1.0 * s
	var foot := top + Vector2(sway, length)
	ci.draw_line(top, foot, col, 4.2 * s, true)
	ci.draw_circle(foot, 2.6 * s, Art.INK)

# ---- flora -----------------------------------------------------------
static func palm(ci: CanvasItem, base: Vector2, s: float, t: float, leaf_col: Color) -> void:
	var sway := sin(t * 1.1 + base.x * 0.05) * 0.12
	var top := base + Vector2(sin(sway) * 14 * s, -54 * s)
	# trunk – slight curve via 2 segments
	var mid := base.lerp(top, 0.5) + Vector2(4 * s, 0)
	ci.draw_polyline(PackedVector2Array([base, mid, top]), Color8(120, 86, 54), 5.0 * s, true)
	# trunk rings
	for i in range(1, 5):
		var p: Vector2 = base.lerp(top, i / 5.0)
		ci.draw_line(p + Vector2(-3 * s, 0), p + Vector2(3 * s, 0), Color8(100, 70, 44), 1.5, true)
	# fronds
	var leaf_dk := Color(leaf_col.r * 0.8, leaf_col.g * 0.8, leaf_col.b * 0.8)
	for i in 7:
		var a := PI + (i / 6.0) * PI            # spread across the top
		var dir := Vector2(cos(a), sin(a) - 0.35).normalized()
		var tip := top + dir * 26 * s
		var ctrl := top + dir * 14 * s + Vector2(0, -6 * s)
		var col := leaf_col if i % 2 == 0 else leaf_dk
		ci.draw_polyline(PackedVector2Array([top, ctrl, tip]), col, 3.2 * s, true)
	# dates
	ci.draw_circle(top + Vector2(2 * s, 3 * s), 2.0 * s, Color8(150, 70, 50))
	ci.draw_circle(top + Vector2(-3 * s, 4 * s), 2.0 * s, Color8(150, 70, 50))

static func cactus(ci: CanvasItem, base: Vector2, s: float) -> void:
	var col := Color8(86, 140, 78)
	var col_dk := Color8(66, 116, 60)
	ci.draw_line(base, base + Vector2(0, -20 * s), col, 7 * s, true)
	ci.draw_circle(base + Vector2(0, -20 * s), 3.5 * s, col)
	# arms
	ci.draw_polyline(PackedVector2Array([base + Vector2(0, -10 * s), base + Vector2(7 * s, -10 * s), base + Vector2(7 * s, -16 * s)]), col, 4 * s, true)
	ci.draw_polyline(PackedVector2Array([base + Vector2(0, -14 * s), base + Vector2(-6 * s, -14 * s), base + Vector2(-6 * s, -19 * s)]), col, 4 * s, true)
	ci.draw_line(base + Vector2(-1 * s, -4 * s), base + Vector2(1 * s, -18 * s), Color(col_dk.r, col_dk.g, col_dk.b, 0.5), 1.4, true)
	# flower
	ci.draw_circle(base + Vector2(0, -23 * s), 2.2 * s, Color8(232, 120, 150))

static func sprout(ci: CanvasItem, base: Vector2, s: float, t: float) -> void:
	var g := Color8(111, 174, 90)
	ci.draw_line(base, base + Vector2(0, -8 * s), g, 2.0, true)
	var w := sin(t * 2.0) * 0.1
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(0, -6 * s), base + Vector2(5 * s, -10 * s + w), base + Vector2(1 * s, -11 * s)]), g)
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(0, -6 * s), base + Vector2(-5 * s, -10 * s - w), base + Vector2(-1 * s, -11 * s)]), g)

static func flower(ci: CanvasItem, at: Vector2, s: float, col: Color) -> void:
	ci.draw_line(at, at + Vector2(0, 7 * s), Color8(79, 138, 62), 1.6, true)
	for k in 5:
		var a := k * TAU / 5.0
		ci.draw_circle(at + Vector2(cos(a), sin(a)) * 3.0 * s, 2.2 * s, col)
	ci.draw_circle(at, 1.8 * s, Color8(230, 179, 74))

static func grass_tuft(ci: CanvasItem, at: Vector2, s: float, col: Color) -> void:
	for k in 3:
		var dx := (k - 1) * 3.0 * s
		ci.draw_line(at + Vector2(dx, 0), at + Vector2(dx * 1.5, -7 * s), col, 1.6, true)

# ---- water -----------------------------------------------------------
static func pond(ci: CanvasItem, c: Vector2, rx: float, ry: float, t: float, water: Color) -> void:
	ci.draw_colored_polygon(ellipse(c, rx + 3, ry + 2), Color8(150, 120, 80))   # muddy rim
	ci.draw_colored_polygon(ellipse(c, rx, ry), water)
	var light := Color(min(1.0, water.r + 0.25), min(1.0, water.g + 0.25), min(1.0, water.b + 0.25), 0.9)
	# shimmer lines
	for i in 3:
		var yy := c.y - ry * 0.3 + i * ry * 0.45
		var off := sin(t * 1.5 + i) * rx * 0.18
		ci.draw_line(Vector2(c.x - rx * 0.45 + off, yy), Vector2(c.x + rx * 0.45 + off, yy), Color(light.r, light.g, light.b, 0.5), 1.6, true)
	ci.draw_colored_polygon(ellipse(c + Vector2(0, -ry * 0.45), rx * 0.45, ry * 0.25), Color(1, 1, 1, 0.18))

# ---- camp ------------------------------------------------------------
static func tent(ci: CanvasItem, base: Vector2, s: float, accent: Color) -> void:
	var terra := Color8(200, 98, 60)
	var terra_dk := Color8(168, 78, 48)
	var w := 26 * s
	var h := 24 * s
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(-w, 0), base + Vector2(w, 0), base + Vector2(0, -h)]), terra)
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(0, 0), base + Vector2(w, 0), base + Vector2(0, -h)]), terra_dk)
	# door slit
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(-4 * s, 0), base + Vector2(4 * s, 0), base + Vector2(0, -h * 0.55)]), Color8(60, 40, 34))
	# stripes
	for i in 3:
		var yy := -h * 0.25 * (i + 1)
		var hw := w * (1.0 - (i + 1) * 0.25)
		ci.draw_line(base + Vector2(-hw, yy), base + Vector2(hw, yy), accent, 1.4, true)
	# pole flag
	ci.draw_line(base + Vector2(0, -h), base + Vector2(0, -h - 8 * s), Art.INK, 1.4, true)
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(0, -h - 8 * s), base + Vector2(7 * s, -h - 6 * s), base + Vector2(0, -h - 4 * s)]), accent)

static func campfire(ci: CanvasItem, base: Vector2, s: float, t: float) -> void:
	# logs
	ci.draw_line(base + Vector2(-6 * s, 0), base + Vector2(6 * s, -2 * s), Color8(120, 86, 54), 3 * s, true)
	ci.draw_line(base + Vector2(-6 * s, -2 * s), base + Vector2(6 * s, 0), Color8(100, 70, 44), 3 * s, true)
	# flames
	var f := 1.0 + sin(t * 8.0) * 0.18
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(-5 * s, -2 * s), base + Vector2(5 * s, -2 * s), base + Vector2(0, -16 * s * f)]), Color8(230, 120, 50))
	ci.draw_colored_polygon(PackedVector2Array([base + Vector2(-3 * s, -2 * s), base + Vector2(3 * s, -2 * s), base + Vector2(0, -11 * s * f)]), Color8(245, 196, 80))

static func lantern(ci: CanvasItem, at: Vector2, s: float, t: float, lit: bool) -> void:
	var gold := Color8(230, 179, 74)
	ci.draw_line(at + Vector2(0, -9 * s), at + Vector2(0, -13 * s), Art.INK, 1.4, true)
	# glow
	if lit:
		var g := 0.4 + sin(t * 3.0 + at.x) * 0.12
		ci.draw_circle(at, 12 * s, Color(1.0, 0.85, 0.4, 0.18 * g + 0.12))
	ci.draw_colored_polygon(PackedVector2Array([at + Vector2(-4 * s, -9 * s), at + Vector2(4 * s, -9 * s), at + Vector2(5 * s, 7 * s), at + Vector2(-5 * s, 7 * s)]), gold)
	ci.draw_colored_polygon(PackedVector2Array([at + Vector2(-2.5 * s, -5 * s), at + Vector2(2.5 * s, -5 * s), at + Vector2(3 * s, 4 * s), at + Vector2(-3 * s, 4 * s)]),
		Color8(255, 226, 140) if lit else Color8(150, 110, 60))
	ci.draw_line(at + Vector2(-5 * s, 7 * s), at + Vector2(5 * s, 7 * s), Art.INK, 1.4, true)

# ---- second/caravan camel (small silhouette) -------------------------
static func mini_camel(ci: CanvasItem, base: Vector2, s: float, col: Color) -> void:
	var c := base + Vector2(0, -8 * s)
	_blob(ci, c, 9 * s, 6 * s, col)
	_blob(ci, c + Vector2(0, -5 * s), 5 * s, 5 * s, col)             # hump
	ci.draw_line(c + Vector2(7 * s, -1 * s), c + Vector2(11 * s, -9 * s), col, 3 * s, true)   # neck
	_blob(ci, c + Vector2(12 * s, -10 * s), 3 * s, 3 * s, col)       # head
	for dx in [-5, -2, 2, 5]:
		ci.draw_line(c + Vector2(dx * s, 4 * s), c + Vector2(dx * s, 9 * s), col, 1.8 * s, true)

# ---- sky bodies ------------------------------------------------------
static func sun(ci: CanvasItem, at: Vector2, r: float, col: Color) -> void:
	ci.draw_circle(at, r * 1.7, Color(col.r, col.g, col.b, 0.18))
	ci.draw_circle(at, r, col)

static func moon(ci: CanvasItem, at: Vector2, r: float) -> void:
	ci.draw_circle(at, r * 1.6, Color(1, 1, 1, 0.10))
	ci.draw_circle(at, r, Color8(245, 240, 220))
	ci.draw_circle(at + Vector2(r * 0.4, -r * 0.2), r * 0.85, Color8(210, 220, 240))  # crescent cut via overpaint of sky done by caller normally
	ci.draw_circle(at + Vector2(-r * 0.35, r * 0.1), r * 0.18, Color8(220, 218, 200))

static func star(ci: CanvasItem, at: Vector2, s: float, tw: float) -> void:
	var a := 0.4 + 0.6 * (0.5 + 0.5 * sin(tw))
	ci.draw_circle(at, s, Color(1, 1, 1, a))

static func crescent(ci: CanvasItem, at: Vector2, r: float, sky: Color) -> void:
	# Islamic crescent: full moon minus an offset sky-colored disc.
	ci.draw_circle(at, r * 1.7, Color(1, 1, 1, 0.08))
	ci.draw_circle(at, r, Color8(245, 240, 220))
	ci.draw_circle(at + Vector2(r * 0.45, -r * 0.25), r * 0.92, sky)
