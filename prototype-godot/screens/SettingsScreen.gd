extends Control
# Settings (portrait): a vertical list of rows.

signal locale_changed
signal want_plus

const M := 24.0
const W := 540.0
const CW := 492.0          # W - 2M
const TOGGLES := [
	{"key": "sound_on", "label": "sound", "icon": "🔊"},
	{"key": "notifications_on", "label": "notifications", "icon": "🔔"},
	{"key": "haptics_on", "label": "haptics", "icon": "📳"},
	{"key": "ramadan_mode", "label": "ramadan_mode", "icon": "🌙"},
]
const ROW_H := 54.0
const STEP := 62.0
const TOP := 88.0

var toggle_btns := {}
var lang_en_btn: Button
var lang_ar_btn: Button
var goal_minus: Button
var goal_plus: Button
var plus_btn: Button
var reset_btn: Button
var reset_armed := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	AppState.changed.connect(_refresh)

func _row_y(i: int) -> float:
	return TOP + i * STEP

func _build() -> void:
	for i in TOGGLES.size():
		var cfg = TOGGLES[i]
		var b := UI.button("", 92, 38, UI.GREEN_DK, Color8(255, 251, 242), 16)
		b.position = Vector2(M + CW - 100, _row_y(i) + 8)
		b.pressed.connect(_toggle.bind(cfg.key))
		add_child(b)
		toggle_btns[cfg.key] = b

	var ly := _row_y(4)
	lang_en_btn = UI.button("EN", 70, 38, UI.CARD, UI.INK, 16)
	lang_en_btn.position = Vector2(M + CW - 156, ly + 8)
	lang_en_btn.pressed.connect(_set_lang.bind("en"))
	add_child(lang_en_btn)
	lang_ar_btn = UI.button("ع", 70, 38, UI.CARD, UI.INK, 18)
	lang_ar_btn.position = Vector2(M + CW - 78, ly + 8)
	lang_ar_btn.pressed.connect(_set_lang.bind("ar"))
	add_child(lang_ar_btn)

	var gy := _row_y(5)
	goal_minus = UI.button("−", 46, 38, UI.CARD_DK, UI.INK, 22)
	goal_minus.position = Vector2(M + CW - 158, gy + 8)
	goal_minus.pressed.connect(_goal.bind(-15))
	add_child(goal_minus)
	goal_plus = UI.button("+", 46, 38, UI.CARD_DK, UI.INK, 22)
	goal_plus.position = Vector2(M + CW - 50, gy + 8)
	goal_plus.pressed.connect(_goal.bind(15))
	add_child(goal_plus)

	plus_btn = UI.button("", 130, 40, UI.GOLD_DK, Color8(255, 248, 230), 16)
	plus_btn.position = Vector2(M + CW - 142, 478)
	plus_btn.pressed.connect(_plus)
	add_child(plus_btn)

	reset_btn = UI.button(Loc.t("reset"), 240, 48, UI.TERRA, Color8(255, 251, 242), 18)
	UI.style(reset_btn, UI.TERRA, Color8(255, 251, 242), 24)
	reset_btn.position = Vector2((W - 240) / 2.0, 588)
	reset_btn.pressed.connect(_reset)
	add_child(reset_btn)
	_refresh()

func relocalize() -> void:
	reset_btn.text = Loc.t("reset_confirm") if reset_armed else Loc.t("reset")
	_refresh()

func _toggle(key: String) -> void:
	AppState.set_setting(key, not AppState.get(key))
	if key == "notifications_on": Notify.set_enabled(AppState.notifications_on)
	if AppState.sound_on: Audio.tap()
	_refresh()

func _set_lang(l: String) -> void:
	if AppState.language == l: return
	AppState.set_setting("language", l)
	Audio.tap(); locale_changed.emit(); relocalize()

func _goal(d: int) -> void:
	AppState.set_setting("daily_goal_min", clampi(AppState.daily_goal_min + d, 15, 480))
	Audio.tap(); _refresh()

func _plus() -> void:
	Audio.tap()
	if not AppState.plus: want_plus.emit()

func _reset() -> void:
	if not reset_armed:
		reset_armed = true
		reset_btn.text = Loc.t("reset_confirm")
		return
	AppState.reset_progress()
	reset_armed = false
	reset_btn.text = Loc.t("reset")
	Audio.tap(); _refresh()

func _refresh() -> void:
	for cfg in TOGGLES:
		var on: bool = AppState.get(cfg.key)
		var b: Button = toggle_btns[cfg.key]
		b.text = Loc.t("on") if on else Loc.t("off")
		UI.style(b, UI.GREEN_DK if on else UI.CARD_DK, Color8(255, 251, 242) if on else UI.MUTE, 19)
	var en := AppState.language == "en"
	UI.style(lang_en_btn, UI.GOLD if en else UI.CARD, UI.INK if en else UI.TEXT, 12)
	UI.style(lang_ar_btn, UI.GOLD if not en else UI.CARD, UI.INK if not en else UI.TEXT, 12)
	if AppState.plus:
		plus_btn.text = "✦"
		UI.style(plus_btn, UI.GREEN, Color8(255, 255, 255), 20)
	else:
		plus_btn.text = Loc.t("subscribe")
		UI.style(plus_btn, UI.GOLD_DK, Color8(255, 248, 230), 20)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, 884), UI.BG)
	UI.text(self, Loc.t("nav_settings"), M, 56, 28, UI.INK)

	for i in TOGGLES.size():
		var cfg = TOGGLES[i]
		UI.card(self, Rect2(M, _row_y(i), CW, ROW_H), UI.CARD, 16)
		UI.text(self, cfg.icon + " " + Loc.t(cfg.label), M + 16, _row_y(i) + 33, 17, UI.INK)
	UI.card(self, Rect2(M, _row_y(4), CW, ROW_H), UI.CARD, 16)
	UI.text(self, "🌐 " + Loc.t("language"), M + 16, _row_y(4) + 33, 17, UI.INK)
	UI.card(self, Rect2(M, _row_y(5), CW, ROW_H), UI.CARD, 16)
	UI.text(self, "🎯 " + Loc.t("day_goal"), M + 16, _row_y(5) + 33, 17, UI.INK)
	UI.text(self, str(AppState.daily_goal_min) + Loc.t("min_short"), M + CW - 210, _row_y(5) + 33, 16, UI.GREEN_DK, HORIZONTAL_ALIGNMENT_CENTER)

	UI.card(self, Rect2(M, 466, CW, 66), Color8(252, 246, 232), 16)
	var crown := Assets.tex("ic_crown")
	if crown:
		Assets.draw_anchored(self, crown, Vector2(M + 32, 510), 28, UI.GOLD_DK)
	UI.text(self, Loc.t("plus_title"), M + 56, 492, 18, UI.INK)
	UI.text(self, Loc.t("plus_active") if AppState.plus else Loc.t("plus_tag"), M + 56, 514, 12, UI.MUTE)

	UI.text(self, Loc.t("about"), W / 2.0, 668, 14, UI.MUTE, HORIZONTAL_ALIGNMENT_CENTER)
	UI.text(self, Loc.t("version") + " 1.0", W / 2.0, 692, 13, UI.MUTE, HORIZONTAL_ALIGNMENT_CENTER)
