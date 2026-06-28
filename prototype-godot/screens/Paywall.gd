extends Control
# Tarkeez+ subscription paywall (mock purchase until real store IAP).

signal closed

var t := 0.0
var sub_btn: Button
var later_btn: Button
var restore_btn: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	sub_btn = UI.button(Loc.t("subscribe"), 320, 56, UI.GOLD_DK, Color8(255, 248, 230), 22)
	UI.style(sub_btn, UI.GOLD_DK, Color8(255, 248, 230), 28)
	sub_btn.position = Vector2((540 - 320) / 2.0, 600)
	sub_btn.pressed.connect(_subscribe)
	add_child(sub_btn)

	restore_btn = UI.button(Loc.t("restore"), 130, 34, UI.CARD, UI.TEAL, 14)
	restore_btn.position = Vector2((540 - 130) / 2.0 - 80, 668)
	restore_btn.pressed.connect(func(): AppState.restore_plus(); Audio.tap())
	add_child(restore_btn)

	later_btn = UI.button(Loc.t("maybe_later"), 130, 34, UI.CARD, UI.MUTE, 14)
	UI.style(later_btn, UI.CARD, UI.MUTE, 14)
	later_btn.position = Vector2((540 - 130) / 2.0 + 80, 668)
	later_btn.pressed.connect(_close)
	add_child(later_btn)

func _subscribe() -> void:
	AppState.subscribe_plus()
	Audio.chime()
	_close()

func _close() -> void:
	Audio.tap()
	closed.emit()
	queue_free()

func _process(dt: float) -> void:
	t += dt
	if t < 0.4:
		queue_redraw()

func _draw() -> void:
	var fade: float = clampf(t * 3.0, 0.0, 1.0)
	draw_rect(Rect2(0, 0, 540, 960), Color(0.12, 0.10, 0.18, 0.66 * fade))
	# centered sheet
	var sw := 472.0
	var sx := (540 - sw) / 2.0
	UI._round_rect(self, Rect2(sx, 230, sw, 480), UI.CARD, 26)
	var cx := 270.0
	var crown := Assets.tex("ic_crown")
	if crown:
		Assets.draw_anchored(self, crown, Vector2(cx, 312), 50, UI.GOLD_DK)
	UI.text(self, Loc.t("plus_title"), cx, 352, 32, UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	UI.text(self, Loc.t("plus_tag"), cx, 382, 15, UI.TEAL, HORIZONTAL_ALIGNMENT_CENTER)
	var y := 436.0
	for key in ["plus_b1", "plus_b2", "plus_b3"]:
		draw_circle(Vector2(sx + 40, y - 5), 4, UI.GOLD)
		UI.text(self, Loc.t(key), sx + 56, y, 15, UI.TEXT)
		y += 42
	UI.text(self, Loc.t("plus_price"), cx, 580, 19, UI.GREEN_DK, HORIZONTAL_ALIGNMENT_CENTER)
	if AppState.plus:
		UI.text(self, Loc.t("plus_active"), cx, 700, 16, UI.GREEN_DK, HORIZONTAL_ALIGNMENT_CENTER)
