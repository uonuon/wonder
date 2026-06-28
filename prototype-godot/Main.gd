extends Control
# App shell: a PORTRAIT app (Home/Stats/Shop/Settings + bottom nav) that flips to
# a fullscreen LANDSCAPE FocusView while a session runs.

const HomeScreen := preload("res://screens/HomeScreen.gd")
const StatsScreen := preload("res://screens/StatsScreen.gd")
const ShopScreen := preload("res://screens/ShopScreen.gd")
const SettingsScreen := preload("res://screens/SettingsScreen.gd")
const OnboardingScreen := preload("res://screens/OnboardingScreen.gd")
const Celebration := preload("res://screens/Celebration.gd")
const Paywall := preload("res://screens/Paywall.gd")
const FocusView := preload("res://screens/FocusView.gd")

const W := 540.0
const H := 960.0
const NAV_H := 78.0
const NAV_Y := H - NAV_H
const PORTRAIT := Vector2i(540, 960)
const LANDSCAPE := Vector2i(960, 540)

const NAV_ICON := {"home": "ic_home", "stats": "ic_stats", "shop": "ic_shop", "settings": "ic_settings"}
const NAV_EMOJI := {"home": "🏠", "stats": "📊", "shop": "🛍", "settings": "⚙"}

var screens := {}
var order := ["home", "stats", "shop", "settings"]
var current := "home"
var nav_btns := {}
var onboarding: Control
var focus_view: Control
var in_focus := false

# screenshot harness
var shot_queue := []
var shot_frames := 0
var shot_dir := "res://_shots/"
var _shot_overlay_made := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var args := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	_parse_demo(args)
	_set_landscape(false)

	screens["home"] = HomeScreen.new()
	screens["stats"] = StatsScreen.new()
	screens["shop"] = ShopScreen.new()
	screens["settings"] = SettingsScreen.new()
	for k in screens:
		var s: Control = screens[k]
		s.position = Vector2.ZERO
		s.size = Vector2(W, NAV_Y)
		add_child(s)
	screens["settings"].locale_changed.connect(_relocalize)
	screens["home"].start_focus.connect(enter_focus)
	screens["home"].dev_grew.connect(_celebrate)
	screens["shop"].want_plus.connect(_open_paywall)
	screens["settings"].want_plus.connect(_open_paywall)
	_build_nav()
	_show("home")
	if "--scenes" in args:
		screens["shop"]._set_mode("scenes")

	if not AppState.onboarded and not _has(args, "--logictest") and not _has(args, "--noob"):
		_open_onboarding()
	if _has(args, "--logictest"):
		_logictest()
	_setup_shots(args)

# ---- orientation / mode ----
func _set_landscape(landscape: bool) -> void:
	var win := get_window()
	var sz := LANDSCAPE if landscape else PORTRAIT
	win.content_scale_size = sz
	if OS.has_feature("mobile"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE if landscape else DisplayServer.SCREEN_PORTRAIT)
	else:
		win.size = sz

func enter_focus(minutes: int, pomodoro: bool) -> void:
	# focus = fullscreen LANDSCAPE pyramid scene
	in_focus = true
	_set_landscape(true)
	for k in screens: screens[k].visible = false
	for k in nav_btns: nav_btns[k].visible = false
	focus_view = FocusView.new()
	focus_view.position = Vector2.ZERO
	focus_view.size = Vector2(LANDSCAPE)
	add_child(focus_view)
	focus_view.finished.connect(_on_focus_done)
	focus_view.begin(minutes, pomodoro)
	queue_redraw()

func _on_focus_done(_completed: bool, stage_up: int) -> void:
	if focus_view:
		focus_view.queue_free()
		focus_view = null
	in_focus = false
	_set_landscape(false)
	for k in nav_btns: nav_btns[k].visible = true
	_show("home")
	if stage_up >= 0:
		_celebrate(stage_up)

# ---- demo seeding ----
func _parse_demo(args: Array) -> void:
	for a in args:
		if a.begins_with("--stage="):
			var n := clampi(int(a.split("=")[1]), 0, Wonders.list().size() - 1)
			AppState.sessions_total = Wonders.stones_before(n) + int(Wonders.stone_count(n) * 0.6)
		if a.begins_with("--coins="):
			AppState.coins = int(a.split("=")[1])
		if a == "--demo":
			AppState.onboarded = true
			AppState.camel_name = "Zumurrud"
			AppState.coins = max(AppState.coins, 500)
			AppState.streak = max(AppState.streak, 4)
			AppState.best_streak = max(AppState.best_streak, 7)
			AppState.daily_goal_min = 60
			AppState.today_focus_sec = 35 * 60
			AppState.total_focus_sec = max(AppState.total_focus_sec, 1240 * 60)
			for d in 35:
				if (d * 7) % 11 < 6:
					AppState.history[AppState.date_offset(d)] = ((d * 13) % 5 + 1) * 600
		if a.begins_with("--lang="):
			AppState.language = a.split("=")[1]
		if a.begins_with("--theme="):
			var tid: String = a.split("=")[1]
			AppState.equipped_theme = tid
			if not (tid in AppState.owned_themes): AppState.owned_themes.append(tid)
		if a.begins_with("--skin="):
			var sid: String = a.split("=")[1]
			AppState.equipped_skin = sid
			if not (sid in AppState.owned_skins): AppState.owned_skins.append(sid)
		if a.begins_with("--char="):
			var cid: String = a.split("=")[1]
			AppState.equipped_character = cid
			if not (cid in AppState.owned_characters): AppState.owned_characters.append(cid)
		if a.begins_with("--cos="):
			var spec: String = a.split("=")[1]
			for pair in spec.split(","):
				var kv: PackedStringArray = pair.split(":")
				if kv.size() == 2:
					AppState.cos_equipped[kv[0]] = kv[1]
					if not (kv[1] in AppState.cos_owned.get(kv[0], [])):
						AppState.cos_owned[kv[0]].append(kv[1])

func _has(args: Array, flag: String) -> bool:
	return flag in args

# ---- navigation (bottom, portrait) ----
func _build_nav() -> void:
	var bw := W / order.size()
	for i in order.size():
		var k: String = order[i]
		var b := Button.new()
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2(i * bw, NAV_Y)
		b.custom_minimum_size = Vector2(bw, NAV_H)
		b.size = Vector2(bw, NAV_H)
		var clear := StyleBoxEmpty.new()
		for st in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(st, clear)
		b.pressed.connect(_show.bind(k))
		add_child(b)
		nav_btns[k] = b

func _show(k: String) -> void:
	current = k
	for key in screens:
		screens[key].visible = key == k and not in_focus
	var s: Control = screens[k]
	if shot_queue.is_empty():
		s.modulate.a = 0.25
		create_tween().tween_property(s, "modulate:a", 1.0, 0.16)
	else:
		s.modulate.a = 1.0
	Audio.tap()
	queue_redraw()

func _draw() -> void:
	if in_focus:
		return
	# bottom nav bar
	draw_rect(Rect2(0, NAV_Y - 6, W, 6), Color(0, 0, 0, 0.04))
	draw_rect(Rect2(0, NAV_Y, W, NAV_H), Color8(252, 247, 234))
	draw_rect(Rect2(0, NAV_Y, W, 1.5), UI.LINE)
	var bw := W / order.size()
	for i in order.size():
		var k: String = order[i]
		var active := k == current
		var cx := i * bw + bw / 2.0
		if active:
			UI._round_rect(self, Rect2(i * bw + 16, NAV_Y + 8, bw - 32, NAV_H - 16), Color8(236, 226, 203), 16)
		var col := UI.GREEN_DK if active else Color8(159, 142, 120)
		var icon := Assets.tex(NAV_ICON[k])
		if icon:
			Assets.draw_anchored(self, icon, Vector2(cx, NAV_Y + 40), 26 if active else 23, col)
		else:
			UI.text(self, NAV_EMOJI[k], cx, NAV_Y + 34, 22, col, HORIZONTAL_ALIGNMENT_CENTER)
		UI.text(self, Loc.t("nav_" + k), cx, NAV_Y + 66, 12, col, HORIZONTAL_ALIGNMENT_CENTER)

func _relocalize() -> void:
	for k in screens:
		if screens[k].has_method("relocalize"):
			screens[k].relocalize()
	queue_redraw()

# ---- onboarding / overlays ----
func _open_onboarding() -> void:
	onboarding = OnboardingScreen.new()
	onboarding.size = Vector2(W, H)
	onboarding.finished.connect(_close_onboarding)
	add_child(onboarding)

func _close_onboarding() -> void:
	if onboarding:
		onboarding.queue_free()
		onboarding = null
	_relocalize()
	screens["home"].relocalize()
	_show("home")

func _celebrate(stage: int) -> void:
	var c := Celebration.new()
	c.stage = stage
	c.add_to_group("overlay")
	add_child(c)

func _open_paywall() -> void:
	var p := Paywall.new()
	p.add_to_group("overlay")
	add_child(p)

func _clear_overlays() -> void:
	for n in get_tree().get_nodes_in_group("overlay"):
		n.queue_free()

# ---- screenshot harness ----
func _setup_shots(args: Array) -> void:
	for a in args:
		if a.begins_with("--shot="):
			shot_queue = Array(a.split("=")[1].split(","))
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(shot_dir))
			shot_frames = 18
			if onboarding == null and "onboarding" in shot_queue:
				_open_onboarding()

func _process(_dt: float) -> void:
	if shot_queue.is_empty():
		return
	shot_frames -= 1
	if shot_frames > 0:
		return
	var name: String = shot_queue[0]
	if name == "focus" and not in_focus:
		enter_focus(25, false)
		shot_frames = 24
		return
	if (name == "paywall" or name == "celebration") and not _shot_overlay_made:
		_clear_overlays()
		if name == "paywall": _open_paywall()
		else: _celebrate(6)
		_shot_overlay_made = true
		shot_frames = 30
		return
	if name in screens.keys():
		_clear_overlays()
		if onboarding: onboarding.visible = false
		_show(name)
		screens[name].modulate.a = 1.0
	elif name == "onboarding" and onboarding:
		_clear_overlays()
		onboarding.visible = true
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(shot_dir + name + ".png"))
	print("SHOT %s saved" % name)
	shot_queue.remove_at(0)
	_shot_overlay_made = false
	if in_focus and not (shot_queue.size() > 0 and shot_queue[0] == "focus"):
		_on_focus_done(false, -1)
	shot_frames = 14
	if shot_queue.is_empty():
		await get_tree().create_timer(0.1).timeout
		get_tree().quit()

# ---- logic tests ----
func _logictest() -> void:
	var r := []
	AppState.sessions_total = 0
	r.append(["wonder 0 at start", AppState.world_stage() == 0])
	r.append(["0 stones placed", AppState.stones_in_wonder() == 0])
	AppState.sessions_total = 5
	r.append(["5 stones placed", AppState.stones_in_wonder() == 5])
	AppState.sessions_total = Wonders.stone_count(0)
	r.append(["wonder advances when built", AppState.world_stage() == 1])
	AppState.sessions_total = 0

	var s0 := AppState.sessions_total
	var c0 := AppState.coins
	AppState.complete_session(25)
	r.append(["session banks", AppState.sessions_total == s0 + 1])
	r.append(["coins rewarded", AppState.coins == c0 + 27])
	r.append(["history recorded", int(AppState.history.get(AppState.today(), 0)) >= 1500])
	r.append(["streak >= 1", AppState.streak >= 1])
	r.append(["one stone per session", AppState.stones_in_wonder() == 1])

	# shop economy + plus gating
	AppState.coins = 1000
	AppState.owned_skins = ["classic"]
	AppState.plus = false
	r.append(["buy skin", AppState.buy_skin("rose") == "" and AppState.owns_skin("rose")])
	AppState.equip_skin("rose")
	r.append(["equip skin", AppState.equipped_skin == "rose"])
	AppState.coins = 0
	r.append(["cant afford", AppState.buy_skin("snow") == "coins"])
	AppState.coins = 1000
	r.append(["premium needs plus", AppState.buy_skin("royal") == "plus"])
	AppState.subscribe_plus()
	r.append(["plus unlocks premium", AppState.buy_skin("royal") == "" and AppState.owns_skin("royal")])
	AppState.plus = false
	AppState.coins = 1000
	AppState.owned_themes = ["sahara"]
	r.append(["buy theme", AppState.buy_theme("sunset") == "" and AppState.owns_theme("sunset")])

	# focus session via FocusView
	var fv := FocusView.new()
	fv.size = Vector2(LANDSCAPE)
	add_child(fv)
	fv.begin(15, false)
	r.append(["focus runs", fv.running and fv.time_left > 0])
	var st := AppState.sessions_total
	fv.minutes = 1
	fv.time_left = 0.001
	fv._process(0.02)
	r.append(["focus completes & banks", not fv.running and AppState.sessions_total == st + 1])
	fv.queue_free()

	AppState.language = "ar"
	r.append(["arabic lookup", Loc.t("start") == "ابدأ التركيز"])
	AppState.language = "en"
	r.append(["font loaded", Loc.font != null])
	AppState.reset_progress()
	r.append(["reset clears", AppState.sessions_total == 0 and AppState.coins == 0])

	var ok := true
	for x in r:
		print("LOGICTEST %s: %s" % [x[0], "PASS" if x[1] else "FAIL"])
		if not x[1]: ok = false
	print("LOGICTEST RESULT: %s" % ("ALL PASS" if ok else "FAILURES"))
