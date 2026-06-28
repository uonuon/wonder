extends Control
# Style (portrait): toggle Characters / Scenes — big live preview + a scrollable grid.

const M := 24.0
const W := 540.0
const PREVIEW_FOOT_Y := 286.0
const TOGGLE_Y := 300.0
const GRID_Y := 350.0
const GRID_BOTTOM := 862.0
const CARD_W := 240.0
const CARD_H := 112.0
const COL_GAP := 12.0
const ROW_STEP := 118.0

signal want_plus

var mode := "chars"          # chars | scenes
var item_btns := []
var char_btn: Button
var scene_btn: Button
var scroll_y := 0.0
var msg := ""
var msg_t := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	AppState.changed.connect(queue_redraw)

func _items() -> Array:
	return Wardrobe.characters() if mode == "chars" else Wardrobe.scenes()

func _base_rect(i: int) -> Rect2:
	return Rect2(M + (i % 2) * (CARD_W + COL_GAP), GRID_Y + int(i / 2) * ROW_STEP, CARD_W, CARD_H)

func _max_scroll() -> float:
	var rows := int(ceil(_items().size() / 2.0))
	return max(0.0, GRID_Y + rows * ROW_STEP - GRID_BOTTOM)

func _build() -> void:
	char_btn = UI.button("", (W - 2 * M - 8) / 2.0, 36, UI.CARD, UI.INK, 16)
	char_btn.position = Vector2(M, TOGGLE_Y)
	char_btn.pressed.connect(_set_mode.bind("chars"))
	add_child(char_btn)
	scene_btn = UI.button("", (W - 2 * M - 8) / 2.0, 36, UI.CARD, UI.INK, 16)
	scene_btn.position = Vector2(M + (W - 2 * M - 8) / 2.0 + 8, TOGGLE_Y)
	scene_btn.pressed.connect(_set_mode.bind("scenes"))
	add_child(scene_btn)
	# enough click areas for the larger list (characters)
	for i in Wardrobe.characters().size():
		var b := Button.new()
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		var clear := StyleBoxEmpty.new()
		for st in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(st, clear)
		b.size = Vector2(CARD_W, CARD_H)
		b.pressed.connect(_act.bind(i))
		add_child(b)
		item_btns.append(b)
	_refresh()

func relocalize() -> void:
	_refresh()

func _set_mode(m: String) -> void:
	mode = m
	scroll_y = 0.0
	Audio.tap()
	_refresh()

func _refresh() -> void:
	UI.style(char_btn, UI.GOLD if mode == "chars" else UI.CARD, UI.INK if mode == "chars" else UI.TEXT, 18, UI.GOLD_DK if mode == "chars" else UI.LINE)
	UI.style(scene_btn, UI.GOLD if mode == "scenes" else UI.CARD, UI.INK if mode == "scenes" else UI.TEXT, 18, UI.GOLD_DK if mode == "scenes" else UI.LINE)
	char_btn.text = Loc.t("characters")
	scene_btn.text = Loc.t("scenes")
	queue_redraw()

func _input(e: InputEvent) -> void:
	if not visible:
		return
	if e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_WHEEL_DOWN: _scroll(54)
		elif e.button_index == MOUSE_BUTTON_WHEEL_UP: _scroll(-54)
	elif e is InputEventScreenDrag:
		_scroll(-e.relative.y)

func _scroll(d: float) -> void:
	scroll_y = clampf(scroll_y + d, 0.0, _max_scroll())
	queue_redraw()

func _act(i: int) -> void:
	var its := _items()
	if i >= its.size():
		return
	var id: String = its[i].id
	if mode == "chars":
		if AppState.owns_character(id): AppState.equip_character(id); Audio.tap()
		else: _buy(AppState.buy_character(id), func(): AppState.equip_character(id))
	else:
		if AppState.owns_scene(id): AppState.equip_scene(id); Audio.tap()
		else: _buy(AppState.buy_scene(id), func(): AppState.equip_scene(id))
	queue_redraw()

func _buy(reason: String, on_ok: Callable) -> void:
	if reason == "":
		Audio.chime(); on_ok.call()
	elif reason == "plus":
		Audio.tap(); want_plus.emit()
	else:
		msg = Loc.t("need_more"); msg_t = 2.5; Audio.tap()

func _process(dt: float) -> void:
	var its := _items()
	for i in item_btns.size():
		if i >= its.size():
			item_btns[i].visible = false
			continue
		var r := _base_rect(i)
		var sy := r.position.y - scroll_y
		item_btns[i].position = Vector2(r.position.x, sy)
		item_btns[i].visible = sy + CARD_H > GRID_Y and sy < GRID_BOTTOM
	if msg_t > 0:
		msg_t -= dt
		if msg_t <= 0: queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, 884), UI.BG)
	# scrolled grid (clipped to the band)
	var its := _items()
	for i in its.size():
		var r := _base_rect(i)
		var sy := r.position.y - scroll_y
		if sy + CARD_H <= GRID_Y or sy >= GRID_BOTTOM:
			continue
		_card(its[i], Rect2(r.position.x, sy, CARD_W, CARD_H))

	# fixed header + preview on top
	draw_rect(Rect2(0, 0, W, GRID_Y - 6), UI.BG)
	UI.text(self, Loc.t("nav_shop"), M, 50, 26, UI.INK)
	UI.text(self, "💧 " + Loc.num(AppState.coins), W - M, 50, 22, UI.TEAL, HORIZONTAL_ALIGNMENT_RIGHT, W - 2 * M)
	UI._round_rect(self, Rect2(M, 70, W - 2 * M, 218), UI.CARD, 18)
	if mode == "chars":
		Wardrobe.draw_character(self, Vector2(W / 2.0, PREVIEW_FOOT_Y), 196, 0.0)
	else:
		var sc := AppState.equipped_scene
		var bgname: String = Wonders.wonder(AppState.world_stage()).get("bg", "bg_giza") if sc == "auto" else Wardrobe.scene(sc).bg
		_bg_thumb(bgname, Rect2(M + 8, 78, W - 2 * M - 16, 202), 14)
	if _max_scroll() > 0:
		var frac := scroll_y / _max_scroll()
		UI.pill(self, Rect2(W - 8, GRID_Y + 8 + frac * (GRID_BOTTOM - GRID_Y - 60), 4, 52), UI.LINE)
	if msg_t > 0:
		UI.text(self, msg, W / 2.0, 872, 15, UI.TERRA, HORIZONTAL_ALIGNMENT_CENTER)

func _bg_thumb(bgname: String, r: Rect2, radius: float) -> void:
	var tex := Assets.tex(bgname)
	if tex == null:
		UI._round_rect(self, r, UI.CARD_DK, radius)
		return
	# cover-fit crop
	var tw := float(tex.get_width()); var th := float(tex.get_height())
	var s: float = max(r.size.x / tw, r.size.y / th)
	var sw := r.size.x / s; var shh := r.size.y / s
	var src := Rect2((tw - sw) / 2.0, (th - shh) / 2.0, sw, shh)
	draw_texture_rect_region(tex, r, src)

func _card(it: Dictionary, r: Rect2) -> void:
	var equipped: bool = (AppState.equipped_character == it.id) if mode == "chars" else (AppState.equipped_scene == it.id)
	var owned: bool = AppState.owns_character(it.id) if mode == "chars" else AppState.owns_scene(it.id)
	UI.card(self, r, UI.CARD, 16)
	if equipped:
		UI._round_rect(self, Rect2(r.position.x, r.position.y, r.size.x, 4), UI.GREEN, 2)
	if mode == "chars":
		var tex := Assets.tex(it.tex)
		if tex: Assets.draw_anchored(self, tex, r.position + Vector2(46, CARD_H - 8), CARD_H - 14)
	else:
		_bg_thumb(it.bg, Rect2(r.position.x + 10, r.position.y + 12, 78, CARD_H - 24), 10)
	var nm = it.ar if Loc.is_rtl() else it.en
	UI.text(self, nm, r.position.x + 100, r.position.y + 42, 15, UI.INK)
	if owned:
		UI.text(self, Loc.t("equipped") if equipped else Loc.t("owned"), r.position.x + 100, r.position.y + 68, 13, UI.GREEN_DK)
	elif it.premium and not AppState.plus:
		UI.text(self, "✦ " + Loc.t("plus_only"), r.position.x + 100, r.position.y + 68, 13, UI.GOLD_DK)
	else:
		UI.text(self, "💧 " + Loc.num(it.price), r.position.x + 100, r.position.y + 68, 15, UI.TEAL)
	if it.premium:
		var bw := UI.text_w(Loc.t("plus_only"), 10) + 12
		UI.pill(self, Rect2(r.position.x + r.size.x - bw - 8, r.position.y + 8, bw, 17), UI.GOLD_DK)
		UI.text(self, Loc.t("plus_only"), r.position.x + r.size.x - bw - 2, r.position.y + 20, 10, Color8(255, 248, 230))
