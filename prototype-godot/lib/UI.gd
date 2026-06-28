extends RefCounted
class_name UI
# Shared drawing + widget helpers so every screen looks consistent.

# landscape canvas + persistent left rail
const SW := 960.0
const SH := 540.0
const RAIL := 224.0          # left control/nav rail width
const CONTENT_X := 224.0     # right content area origin
const CONTENT_W := 736.0     # SW - RAIL

# palette (warm desert UI chrome)
const BG := Color8(243, 233, 207)
const CARD := Color8(255, 251, 242)
const CARD_DK := Color8(236, 226, 202)
const PANEL := Color8(249, 241, 224)
const GOLD_DK := Color8(212, 156, 56)
const INK := Color8(58, 47, 40)
const TEXT := Color8(92, 78, 66)
const MUTE := Color8(150, 134, 112)
const GREEN := Color8(111, 174, 90)
const GREEN_DK := Color8(79, 138, 62)
const GOLD := Color8(230, 179, 74)
const TERRA := Color8(200, 98, 60)
const TEAL := Color8(58, 154, 150)
const PINK := Color8(232, 154, 130)
const LINE := Color8(214, 202, 178)

static func text(ci: CanvasItem, s: String, x: float, y: float, sz: int, col: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	var f: Font = Loc.font
	if align == HORIZONTAL_ALIGNMENT_CENTER and width < 0:
		var w := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
		ci.draw_string(f, Vector2(x - w / 2.0, y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, col)
	else:
		ci.draw_string(f, Vector2(x, y), s, align, width, sz, col)

static func text_w(s: String, sz: int) -> float:
	return Loc.font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x

static func card(ci: CanvasItem, r: Rect2, col := CARD, radius := 18.0, shadow := true) -> void:
	if shadow:
		_round_rect(ci, Rect2(r.position + Vector2(0, 3), r.size), Color(0, 0, 0, 0.06), radius)
	_round_rect(ci, r, col, radius)

static func _round_rect(ci: CanvasItem, r: Rect2, col: Color, rad: float) -> void:
	rad = min(rad, min(r.size.x, r.size.y) / 2.0)
	# center cross
	ci.draw_rect(Rect2(r.position.x + rad, r.position.y, r.size.x - 2 * rad, r.size.y), col)
	ci.draw_rect(Rect2(r.position.x, r.position.y + rad, r.size.x, r.size.y - 2 * rad), col)
	# corners
	ci.draw_circle(r.position + Vector2(rad, rad), rad, col)
	ci.draw_circle(r.position + Vector2(r.size.x - rad, rad), rad, col)
	ci.draw_circle(r.position + Vector2(rad, r.size.y - rad), rad, col)
	ci.draw_circle(r.position + Vector2(r.size.x - rad, r.size.y - rad), rad, col)

static func pill(ci: CanvasItem, r: Rect2, col: Color) -> void:
	_round_rect(ci, r, col, r.size.y / 2.0)

static func bar(ci: CanvasItem, r: Rect2, frac: float, bg: Color, fg: Color) -> void:
	pill(ci, r, bg)
	frac = clampf(frac, 0.0, 1.0)
	if frac > 0.01:
		pill(ci, Rect2(r.position, Vector2(max(r.size.y, r.size.x * frac), r.size.y)), fg)

# ---- buttons ----
static func button(txt: String, w: float, h: float, bg: Color, fg := Color8(255, 251, 242), fsize := 20) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(w, h)
	b.size = Vector2(w, h)
	b.focus_mode = Control.FOCUS_NONE
	if Loc.font:
		b.add_theme_font_override("font", Loc.font)
	b.add_theme_font_size_override("font_size", fsize)
	style(b, bg, fg, min(16.0, h / 2.0))
	return b

static func style(b: Button, bg: Color, fg: Color, radius := 14.0, border := Color(0, 0, 0, 0)) -> void:
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb := StyleBoxFlat.new()
		var c := bg
		if st == "hover": c = Color(min(1.0, bg.r + 0.06), min(1.0, bg.g + 0.06), min(1.0, bg.b + 0.06), bg.a)
		if st == "pressed": c = Color(bg.r * 0.92, bg.g * 0.92, bg.b * 0.92, bg.a)
		if st == "disabled": c = Color(bg.r, bg.g, bg.b, 0.45)
		sb.bg_color = c
		sb.set_corner_radius_all(radius)
		sb.content_margin_left = 6; sb.content_margin_right = 6
		if border.a > 0:
			sb.set_border_width_all(2); sb.border_color = border
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_color_override("font_color", fg)
	b.add_theme_color_override("font_hover_color", fg)
	b.add_theme_color_override("font_pressed_color", fg)
	b.add_theme_color_override("font_focus_color", fg)
