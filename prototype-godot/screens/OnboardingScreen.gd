extends Control
# First-run onboarding (portrait): welcome → name your camel → daily goal.

signal finished

var step := 0
var name_edit: LineEdit
var goal := 60
var next_btn: Button
var lang_btn: Button
var minus: Button
var plus: Button
var t := 0.0

const W := 540.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	lang_btn = UI.button("العربية", 150, 40, UI.CARD, UI.TERRA, 16)
	lang_btn.position = Vector2((W - 150) / 2.0, 500)
	lang_btn.pressed.connect(_toggle_lang)
	add_child(lang_btn)

	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Zumurrud"
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_edit.size = Vector2(300, 54)
	name_edit.position = Vector2((W - 300) / 2.0, 440)
	name_edit.max_length = 16
	if Loc.font: name_edit.add_theme_font_override("font", Loc.font)
	name_edit.add_theme_font_size_override("font_size", 24)
	add_child(name_edit)

	minus = UI.button("−", 54, 50, UI.CARD_DK, UI.INK, 26)
	minus.position = Vector2(W / 2.0 - 120, 446)
	minus.pressed.connect(_goal.bind(-15))
	add_child(minus)
	plus = UI.button("+", 54, 50, UI.CARD_DK, UI.INK, 26)
	plus.position = Vector2(W / 2.0 + 66, 446)
	plus.pressed.connect(_goal.bind(15))
	add_child(plus)

	next_btn = UI.button(Loc.t("next"), 280, 58, UI.GREEN_DK, Color8(255, 251, 242), 23)
	UI.style(next_btn, UI.GREEN_DK, Color8(255, 251, 242), 29)
	next_btn.position = Vector2((W - 280) / 2.0, 820)
	next_btn.pressed.connect(_next)
	add_child(next_btn)
	_refresh()

func _toggle_lang() -> void:
	AppState.language = "ar" if AppState.language == "en" else "en"
	Audio.tap(); _refresh()

func _goal(d: int) -> void:
	goal = clampi(goal + d, 15, 240)
	queue_redraw()

func _next() -> void:
	Audio.tap()
	if step < 2:
		step += 1; _refresh()
	else:
		var nm := name_edit.text.strip_edges()
		AppState.camel_name = nm if nm != "" else ("جمل" if Loc.is_rtl() else "Camel")
		AppState.daily_goal_min = goal
		AppState.onboarded = true
		AppState.save_data()
		finished.emit()

func _refresh() -> void:
	lang_btn.text = "English" if AppState.language == "ar" else "العربية"
	lang_btn.visible = step == 0
	name_edit.visible = step == 1
	minus.visible = step == 2
	plus.visible = step == 2
	next_btn.text = Loc.t("lets_go") if step == 2 else Loc.t("next")
	queue_redraw()

func _process(dt: float) -> void:
	t += dt
	if step == 0:
		queue_redraw()

func _camel(stage_idx: int, foot: Vector2) -> void:
	var tex := Assets.tex("camel_s%d" % stage_idx)
	if tex:
		draw_colored_polygon(Art.ellipse(foot + Vector2(0, 6), 100, 16), Color(0, 0, 0, 0.12))
		Assets.draw_anchored(self, tex, foot, 220)
	else:
		Art.camel(self, foot, 2.1, stage_idx, Catalog.skin("classic"), t, 0.0)

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, 960), UI.BG)
	for i in 3:
		var c = UI.GOLD if i == step else UI.CARD_DK
		draw_circle(Vector2(W / 2.0 - 16 + i * 16, 900), 5, c)

	var bob := sin(t * 2.0) * 5.0
	_camel(1 if step < 2 else 2, Vector2(W / 2.0, 330 + bob))

	match step:
		0:
			UI.text(self, Loc.t("welcome"), W / 2.0, 400, 30, UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
			_wrap(Loc.t("ob_intro"), 444, W - 80)
		1:
			UI.text(self, Loc.t("name_camel"), W / 2.0, 405, 26, UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
		2:
			UI.text(self, Loc.t("set_goal"), W / 2.0, 405, 26, UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
			UI.text(self, str(goal) + " " + Loc.t("min_short"), W / 2.0, 540, 26, UI.GREEN_DK, HORIZONTAL_ALIGNMENT_CENTER)

func _wrap(s: String, y: float, maxw: float) -> void:
	var words := s.split(" ")
	var line := ""
	var yy := y
	for word in words:
		var test := (line + " " + word).strip_edges()
		if UI.text_w(test, 16) > maxw and line != "":
			UI.text(self, line, W / 2.0, yy, 16, UI.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
			yy += 26
			line = word
		else:
			line = test
	if line != "":
		UI.text(self, line, W / 2.0, yy, 16, UI.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
