extends Control
# Full-screen reward moment shown when the oasis advances a stage.

signal closed

var stage := 1
var t := 0.0
var parts := []
var btn: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	btn = UI.button(Loc.t("continue"), 240, 54, UI.GREEN_DK, Color8(255, 251, 242), 22)
	UI.style(btn, UI.GREEN_DK, Color8(255, 251, 242), 27)
	btn.position = Vector2((540 - 240) / 2.0, 560)
	btn.pressed.connect(_close)
	add_child(btn)
	Audio.chime()
	_burst()

func _burst() -> void:
	for i in 46:
		var a := randf() * TAU
		var sp := randf_range(80, 280)
		parts.append({"pos": Vector2(270, 380), "vel": Vector2(cos(a), sin(a)) * sp,
			"life": 1.4, "max": 1.4, "col": [UI.GOLD, UI.GREEN, UI.PINK, UI.TEAL].pick_random()})

func _close() -> void:
	Audio.tap()
	closed.emit()
	queue_free()

func _process(dt: float) -> void:
	t += dt
	var keep := []
	for p in parts:
		p.life -= dt
		p.pos += p.vel * dt
		p.vel.y += 140 * dt
		if p.life > 0: keep.append(p)
	parts = keep
	queue_redraw()

func _draw() -> void:
	var fade: float = clampf(t * 2.0, 0.0, 1.0)
	draw_rect(Rect2(0, 0, 540, 960), Color(0.12, 0.10, 0.18, 0.62 * fade))
	# card (quick pop-in)
	var pop: float = clampf(t * 6.0, 0.0, 1.0)
	var cw := 400.0 * (0.7 + 0.3 * pop)
	var ch := 320.0 * (0.7 + 0.3 * pop)
	var cx := 270.0
	var cy := 380.0
	UI.card(self, Rect2(cx - cw / 2.0, cy - ch / 2.0, cw, ch), UI.CARD, 26)
	# content fades in
	var ca: float = clampf((t - 0.1) * 4.0, 0.0, 1.0)
	if ca <= 0.0:
		return
	_sparkle(Vector2(cx, cy - 92), 30 + sin(t * 4.0) * 3, ca)
	UI.text(self, Loc.t("grew_title"), cx, cy - 4, 28, Color(UI.INK.r, UI.INK.g, UI.INK.b, ca), HORIZONTAL_ALIGNMENT_CENTER)
	UI.text(self, AppState.stage_name(stage), cx, cy + 28, 19, Color(UI.GREEN_DK.r, UI.GREEN_DK.g, UI.GREEN_DK.b, ca), HORIZONTAL_ALIGNMENT_CENTER)
	UI.text(self, Loc.quote(stage), cx, cy + 66, 15, Color(UI.MUTE.r, UI.MUTE.g, UI.MUTE.b, ca), HORIZONTAL_ALIGNMENT_CENTER)
	_draw_parts()

func _sparkle(c: Vector2, r: float, a := 1.0) -> void:
	var g := Color(UI.GOLD.r, UI.GOLD.g, UI.GOLD.b, a)
	for k in 8:
		var ang := k * TAU / 8.0 + t * 0.6
		var l := r * (1.0 if k % 2 == 0 else 0.6)
		draw_line(c, c + Vector2(cos(ang), sin(ang)) * l, g, 3.0, true)
	draw_circle(c, r * 0.34, g)
	draw_circle(c, r * 0.22, Color(1.0, 0.94, 0.78, a))

func _draw_parts() -> void:
	for p in parts:
		var a: float = clampf(p.life / p.max, 0.0, 1.0)
		var c: Color = p.col
		draw_circle(p.pos, 3.0 * a + 1.0, Color(c.r, c.g, c.b, a))
