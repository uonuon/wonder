extends Control
# Home: ONE clean page — character in the middle, timer + length + Start below,
# bottom tabs (drawn by Main). No cards/sheets.

signal start_focus(minutes, pomodoro)
signal dev_grew(stage)

const W := 540.0
const BG := Color8(249, 244, 235)

var t := 0.0
var presets := [5, 15, 25, 50]
var selected_min := 25
var custom_min := 30
var custom_mode := false
var pomodoro := false

var preset_btns := []
var custom_btn: Button
var minus_btn: Button
var plus_btn: Button
var pomo_btn: Button
var start_btn: Button
var dev_btn: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	AppState.changed.connect(queue_redraw)

func _process(dt: float) -> void:
	t += dt
	queue_redraw()

func _build() -> void:
	pomo_btn = UI.button("⏳ " + Loc.t("pomodoro"), 148, 30, BG, UI.TERRA, 13)
	pomo_btn.position = Vector2(W - 162, 432)
	pomo_btn.pressed.connect(_toggle_pomo)
	add_child(pomo_btn)

	var cw := 88.0
	var n := presets.size() + 1
	var total := n * cw + (n - 1) * 8
	var sx := (W - total) / 2.0
	for i in presets.size():
		var m: int = presets[i]
		var b := UI.button("%d" % m, cw, 44, UI.CARD, UI.INK, 18)
		b.position = Vector2(sx + i * (cw + 8), 502)
		b.pressed.connect(_pick.bind(m))
		add_child(b)
		preset_btns.append({"btn": b, "min": m})
	custom_btn = UI.button(Loc.t("custom"), cw, 44, UI.CARD, UI.INK, 15)
	custom_btn.position = Vector2(sx + presets.size() * (cw + 8), 502)
	custom_btn.pressed.connect(_toggle_custom)
	add_child(custom_btn)

	minus_btn = UI.button("−", 46, 40, UI.CARD_DK, UI.INK, 24)
	minus_btn.position = Vector2(W / 2.0 - 96, 558)
	minus_btn.pressed.connect(_step.bind(-5))
	add_child(minus_btn)
	plus_btn = UI.button("+", 46, 40, UI.CARD_DK, UI.INK, 24)
	plus_btn.position = Vector2(W / 2.0 + 50, 558)
	plus_btn.pressed.connect(_step.bind(5))
	add_child(plus_btn)

	start_btn = UI.button(Loc.t("start"), 320, 60, UI.GREEN_DK, Color8(255, 251, 242), 24)
	UI.style(start_btn, UI.GREEN_DK, Color8(255, 251, 242), 30)
	start_btn.position = Vector2((W - 320) / 2.0, 612)
	start_btn.pressed.connect(_start)
	add_child(start_btn)

	dev_btn = UI.button("⏩ +session", 150, 28, UI.TEAL, Color8(255, 251, 242), 13)
	dev_btn.position = Vector2((W - 150) / 2.0, 688)
	dev_btn.pressed.connect(_dev_session)
	dev_btn.visible = AppState.fast
	add_child(dev_btn)
	_refresh()

func relocalize() -> void:
	custom_btn.text = Loc.t("custom")
	pomo_btn.text = "⏳ " + Loc.t("pomodoro")
	start_btn.text = Loc.t("start")
	queue_redraw()

func _refresh() -> void:
	for p in preset_btns:
		p.btn.visible = not pomodoro
		var sel: bool = not custom_mode and p.min == selected_min
		UI.style(p.btn, UI.GOLD if sel else UI.CARD, UI.INK if sel else UI.TEXT, 22, UI.LINE if not sel else UI.GOLD_DK)
	custom_btn.visible = not pomodoro
	UI.style(custom_btn, UI.GOLD if custom_mode else UI.CARD, UI.INK if custom_mode else UI.TEXT, 22, UI.LINE if not custom_mode else UI.GOLD_DK)
	minus_btn.visible = custom_mode and not pomodoro
	plus_btn.visible = custom_mode and not pomodoro
	UI.style(pomo_btn, UI.TERRA if pomodoro else BG, Color8(255, 251, 242) if pomodoro else UI.TERRA, 15)
	queue_redraw()

func _cur_min() -> int:
	if pomodoro: return 25
	return custom_min if custom_mode else selected_min

func _pick(m: int) -> void:
	selected_min = m; custom_mode = false; _refresh()

func _toggle_custom() -> void:
	custom_mode = not custom_mode; _refresh()

func _step(d: int) -> void:
	custom_min = clampi(custom_min + d, 5, 120); _refresh()

func _toggle_pomo() -> void:
	pomodoro = not pomodoro; _refresh()

func _start() -> void:
	Audio.tap()
	start_focus.emit(_cur_min(), pomodoro)

func _dev_session() -> void:
	var pre := AppState.world_stage()
	AppState.complete_session(25)
	Audio.chime()
	if AppState.world_stage() > pre:
		dev_grew.emit(AppState.world_stage())
	queue_redraw()

func _clock(sec: int) -> String:
	return "%02d:%02d" % [int(sec / 60), sec % 60]

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, 884), BG)
	# header
	UI.text(self, "🔥 " + Loc.num(AppState.streak), 22, 44, 17, UI.TERRA)
	UI.text(self, "💧 " + Loc.num(AppState.coins), W - 22, 44, 17, UI.TEAL, HORIZONTAL_ALIGNMENT_RIGHT, W - 44)
	var st := AppState.world_stage()
	var prog := AppState.stage_name(st) + " · " + Loc.num(AppState.stones_in_wonder()) + "/" + Loc.num(AppState.stones_needed())
	var pw := UI.text_w(prog, 14) + 26
	UI.pill(self, Rect2((W - pw) / 2.0, 26, pw, 28), UI.CARD)
	UI.text(self, prog, W / 2.0, 45, 14, UI.INK, HORIZONTAL_ALIGNMENT_CENTER)

	# character (centered), gentle bob
	var bob := sin(t * 2.0) * 4.0
	Wardrobe.draw_character(self, Vector2(W / 2.0, 358 + bob), 268, 0.0)

	# timer + length
	UI.text(self, _clock(_cur_min() * 60), W / 2.0, 446, 50, UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	if custom_mode and not pomodoro:
		UI.text(self, "%d %s" % [custom_min, Loc.t("min_short")], W / 2.0, 590, 20, UI.GREEN_DK, HORIZONTAL_ALIGNMENT_CENTER)
	elif pomodoro:
		UI.text(self, "25 / 5 " + Loc.t("min_short"), W / 2.0, 474, 15, UI.TERRA, HORIZONTAL_ALIGNMENT_CENTER)
	else:
		UI.text(self, Loc.t("pick_len"), W / 2.0, 474, 15, UI.TEAL, HORIZONTAL_ALIGNMENT_CENTER)
