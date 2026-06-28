extends Control
# The living desert→oasis scene. Renders decor by AppState.world_stage(),
# tints the whole thing by real-clock day/night, and animates the camel,
# palms, water and lanterns. HomeScreen drives `running` / `live_growth`.

var running := false
var live_growth := 0.0          # 0..1 progress of the active session
var force_night := -1.0         # -1 = use clock; else 0..1 override (settings/preview)
var big_timer := ""             # FocusView sets this to draw the timer over the scene
var big_sub := ""

var t := 0.0
var blink := 0.0
var blink_timer := 2.0
var particles := []
var _stars := []
var _rng_done := false
var pop_t := 0.0                # growth "pop" animation timer

func _ready() -> void:
	_seed_stars()

func _seed_stars() -> void:
	# deterministic star field so it doesn't twinkle-jump each frame
	var r := RandomNumberGenerator.new()
	r.seed = 1337
	_stars.clear()
	for i in 46:
		_stars.append({"x": r.randf(), "y": r.randf() * 0.55, "s": r.randf_range(0.8, 1.8), "ph": r.randf() * TAU})
	_rng_done = true

func celebrate() -> void:
	pop_t = 1.0
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	for i in 30:
		var a := randf() * TAU
		var sp := randf_range(70, 230)
		particles.append({"pos": Vector2(cx, cy), "vel": Vector2(cos(a), sin(a)) * sp,
			"life": 1.0, "max": 1.0, "col": [Color8(230,179,74), Color8(111,174,90), Color8(232,154,130), Color8(58,154,150)].pick_random()})

func _process(dt: float) -> void:
	t += dt
	blink_timer -= dt
	if blink_timer <= 0.0:
		blink = 0.16
		blink_timer = randf_range(2.5, 5.0)
	if blink > 0.0:
		blink -= dt
	if pop_t > 0.0:
		pop_t -= dt
	var keep := []
	for p in particles:
		p.life -= dt
		p.pos += p.vel * dt
		p.vel.y += 130 * dt
		if p.life > 0:
			keep.append(p)
	particles = keep
	queue_redraw()

func _daylight() -> float:
	if force_night >= 0.0:
		return 1.0 - force_night
	var td := Time.get_time_dict_from_system()
	var h: float = td.hour + td.minute / 60.0
	return clamp(cos((h - 13.0) / 24.0 * TAU) * 0.5 + 0.5, 0.0, 1.0)

func _draw() -> void:
	var th := Catalog.theme(AppState.equipped_theme)
	var stage := AppState.world_stage()
	var dl := _daylight()                       # 1 = bright day, 0 = deep night
	var night := 1.0 - dl
	var W := size.x
	var Hh := size.y
	var ground_y := Hh * 0.72

	# Build-a-Wonder: the pyramid rises stone by stone (the game).
	if Assets.has("p_stone"):
		_draw_pyramid(W, Hh, ground_y, night)
		return
	# (legacy oasis paths kept below as fallback only)
	var bg := Assets.tex("bg_desert")
	if bg:
		_draw_layered(bg, W, Hh, ground_y, stage, night)
		return

	# ---- sky (day → dusk → night) ----
	var sky_day: Color = th.sky_day
	var sky_dusk: Color = th.sky_dusk
	var sky_night := Color8(34, 38, 70)
	var sky: Color
	if dl > 0.5:
		sky = sky_dusk.lerp(sky_day, (dl - 0.5) * 2.0)
	else:
		sky = sky_night.lerp(sky_dusk, dl * 2.0)
	draw_rect(Rect2(0, 0, W, ground_y + 2), sky)
	# upper sky a touch darker for depth
	draw_rect(Rect2(0, 0, W, Hh * 0.32), Color(0, 0, 0, 0.05 + night * 0.12))

	# ---- celestial ----
	if night > 0.5:
		for s in _stars:
			Art.star(self, Vector2(s.x * W, s.y * ground_y), s.s, t * 2.0 + s.ph)
		# crescent moon for the night oasis
		Art.crescent(self, Vector2(W * 0.78, Hh * 0.16), 15, sky)
	else:
		var sun_y: float = lerpf(Hh * 0.30, Hh * 0.10, dl)
		Art.sun(self, Vector2(W * 0.76, sun_y), 18, Color8(248, 214, 120).lerp(Color8(245, 150, 90), night))

	# ---- dunes (parallax silhouettes) ----
	var sand: Color = th.sand
	var sand_dk: Color = th.sand_dk
	var far := sand_dk.lerp(Color8(40, 44, 78), night * 0.7)
	_dune(ground_y - 36, 0.0, far, 0.5)
	_dune(ground_y - 18, 1.6, sand_dk.lerp(Color8(48,52,84), night*0.6), 0.7)

	# ---- ground ----
	var grd := sand.lerp(Color8(46, 50, 82), night * 0.6)
	draw_rect(Rect2(0, ground_y, W, Hh - ground_y), grd)
	draw_rect(Rect2(0, ground_y, W, 5), sand_dk.lerp(Color8(40,44,76), night*0.6))

	# greener ground once the oasis truly wakes (stage >= 3)
	if stage >= 3:
		var green: Color = th.palm
		var amt: float = clampf((stage - 2) / 5.0, 0.0, 1.0)
		draw_colored_polygon(Art.ellipse(Vector2(W * 0.5, ground_y + 30), W * 0.62 * amt, 40), Color(green.r, green.g, green.b, 0.22 * amt))

	# ---- decor by stage (drawn back-to-front) ----
	var gx := func(f): return W * f
	# pond behind the camel
	if stage >= 3:
		Art.pond(self, Vector2(W * 0.5, ground_y + 30), 70 + stage * 4, 18 + stage, t, th.water.lerp(Color8(40,60,120), night*0.5))
	# palms
	if stage >= 2:
		Art.palm(self, Vector2(gx.call(0.16), ground_y + 6), _ps(), t, th.palm.lerp(Color8(40,70,60), night*0.5))
	if stage >= 4:
		Art.palm(self, Vector2(gx.call(0.86), ground_y + 12), _ps() * 0.9, t * 1.1, th.palm.lerp(Color8(40,70,60), night*0.5))
	if stage >= 7:
		Art.palm(self, Vector2(gx.call(0.30), ground_y - 2), _ps() * 1.15, t * 0.9, th.palm.lerp(Color8(40,70,60), night*0.5))
	# cactus / sprout early life
	if stage >= 1:
		Art.cactus(self, Vector2(gx.call(0.80), ground_y + 8), _ps() * 0.9)
		Art.sprout(self, Vector2(gx.call(0.62), ground_y + 6), _ps(), t)
	# tent + fire camp
	if stage >= 5:
		Art.tent(self, Vector2(gx.call(0.20), ground_y + 14), _ps() * 0.9, th.sky_day)
		Art.campfire(self, Vector2(gx.call(0.36), ground_y + 18), _ps() * 0.8, t)
	# caravan companion
	if stage >= 6:
		Art.mini_camel(self, Vector2(gx.call(0.86), ground_y + 14), _ps() * 0.8, Catalog.skin(AppState.equipped_skin).coat_dk)
	# flowers & grass once blooming
	if stage >= 4:
		var cols := [Color8(232,120,150), Color8(230,179,74), Color8(232,154,130), Color8(58,154,150)]
		var n: int = min(3 + stage, 12)
		for i in n:
			var f: float = (i * 0.137) - floor(i * 0.137)
			var fx: float = lerpf(W * 0.08, W * 0.92, f)
			var fy: float = ground_y + 16 + (i % 3) * 9
			if i % 4 == 3:
				Art.grass_tuft(self, Vector2(fx, fy), _ps() * 0.8, th.palm)
			else:
				Art.flower(self, Vector2(fx, fy), _ps() * 0.85, cols[i % cols.size()])
	# lanterns (lit at night) along the bottom
	if stage >= 6:
		var ln: int = min(stage - 4, 6)
		for i in ln:
			var lx: float = lerpf(W * 0.12, W * 0.88, float(i) / max(1, ln - 1))
			Art.lantern(self, Vector2(lx, ground_y + 50), _ps() * 0.8, t, night > 0.45)

	# ---- the camel (hero, center) ----
	_draw_camel(W, ground_y, stage, night)
	if running:
		_focus_ring(W, ground_y, stage)

	# ---- night overlay tint for cohesion ----
	if night > 0.05:
		draw_rect(Rect2(0, 0, W, Hh), Color(0.10, 0.12, 0.30, night * 0.22))

	_draw_particles()
	_draw_hud(W)

# --- layered oasis: barren base + decor that appears with each stage ---
func _draw_layered(bg: Texture2D, W: float, Hh: float, ground_y: float, stage: int, night: float) -> void:
	var th := Catalog.theme(AppState.equipped_theme)
	night = clampf(night + float(th.get("night_bias", 0.0)), 0.0, 1.0)
	var grade: Color = th.get("grade", Color.WHITE)
	_draw_bg(bg, W, Hh, night, grade)
	var G := ground_y
	# each item: name, x-fraction, base-y, height (fraction of Hh), min stage.
	# Spread wide with clear back/mid/front depth so nothing piles up.
	var items := [
		# --- back layer (smaller, higher up, drawn first) ---
		{"n": "d_palm", "x": 0.11, "y": G - 6, "h": 0.44, "s": 4},
		{"n": "d_house", "x": 0.94, "y": G - 46, "h": 0.15, "s": 5},
		{"n": "d_arch", "x": 0.65, "y": G - 30, "h": 0.14, "s": 6},
		{"n": "d_palm", "x": 0.80, "y": G - 2, "h": 0.38, "s": 6},
		# --- mid layer ---
		{"n": "d_tent", "x": 0.20, "y": G + 14, "h": 0.19, "s": 5},
		{"n": "d_palm_small", "x": 0.36, "y": G + 6, "h": 0.17, "s": 2},
		{"n": "d_cactus", "x": 0.90, "y": G + 18, "h": 0.12, "s": 1},
		{"n": "d_pond", "x": 0.52, "y": G + 40, "h": 0.14, "s": 3},
		# --- front layer (larger, lower, drawn last) ---
		{"n": "d_rock", "x": 0.06, "y": G + 20, "h": 0.10, "s": 1},
		{"n": "d_fire", "x": 0.29, "y": G + 22, "h": 0.09, "s": 5},
		{"n": "d_bush", "x": 0.66, "y": G + 18, "h": 0.09, "s": 3},
		{"n": "d_sprout", "x": 0.42, "y": G + 24, "h": 0.07, "s": 1},
		{"n": "d_flowers", "x": 0.38, "y": G + 30, "h": 0.08, "s": 4},
		{"n": "d_grass", "x": 0.73, "y": G + 30, "h": 0.07, "s": 4},
		{"n": "d_flowers", "x": 0.78, "y": G + 34, "h": 0.07, "s": 7},
	]
	# include the camel as a depth-sorted item so overlaps look right
	items.append({"camel": true, "y": G + 12})
	items.sort_custom(func(a, b): return a.y < b.y)
	for it in items:
		if it.get("camel", false):
			_draw_camel(W, ground_y, stage, night)
			if running:
				_focus_ring(W, ground_y, stage)
		elif stage >= int(it.s):
			var tex := Assets.tex(it.n)
			if tex:
				var mod := Color.WHITE.lerp(Color8(120, 130, 190), night * 0.5) * grade
				Assets.draw_anchored(self, tex, Vector2(W * it.x, it.y), float(it.h) * Hh, mod)
	# hanging lanterns (string across the top), glowing at night
	if stage >= 6 or AppState.ramadan_mode:
		var ln: int = max(3 if AppState.ramadan_mode else 0, min(stage - 4, 5))
		var lt := Assets.tex("d_lantern")
		for i in ln:
			var lx: float = lerpf(W * 0.16, W * 0.84, float(i) / max(1, ln - 1))
			var ly := Hh * (0.16 + 0.05 * sin(i * 1.7))
			if lt:
				if night > 0.4:
					draw_circle(Vector2(lx, ly + Hh * 0.05), Hh * 0.10, Color(1.0, 0.82, 0.4, 0.16))
				draw_line(Vector2(lx, 0), Vector2(lx, ly), Color(0, 0, 0, 0.18), 1.5)
				Assets.draw_anchored(self, lt, Vector2(lx, ly + Hh * 0.10), Hh * 0.11, Color.WHITE.lerp(Color8(150,150,200), night*0.3) * grade)
	if night > 0.05:
		draw_rect(Rect2(0, 0, W, Hh), Color(0.10, 0.12, 0.30, night * 0.20))
	_draw_particles()
	_draw_hud(W)

# --- the pyramid build: stones placed in exact order, capstone last ---
func _draw_pyramid(W: float, Hh: float, ground_y: float, night: float) -> void:
	var wi := AppState.world_stage()
	var bgname: String = Wonders.wonder(wi).get("bg", "bg_giza")
	if AppState.equipped_scene != "auto" and AppState.equipped_scene != "":
		bgname = Wardrobe.scene(AppState.equipped_scene).bg
	var bg := Assets.tex(bgname)
	if bg == null:
		bg = Assets.tex("bg_giza")
	# night/sunset backgrounds are already dark — don't double-tint them
	var bgnight := night
	if bgname.ends_with("night"):
		bgnight = night * 0.3
	if bg:
		_draw_bg(bg, W, Hh, bgnight, Color.WHITE)
	else:
		draw_rect(Rect2(0, 0, W, Hh), Color8(232, 200, 150).lerp(Color8(40, 44, 70), night))
	var placed := AppState.stones_in_wonder()
	var total := AppState.stones_needed()
	var wd := Wonders.wonder(wi)
	var cxp := W * 0.56
	# real 3D structure that rises from the ground up as stones are placed
	var struct := Assets.tex("s_" + str(wd.id))
	if struct:
		_draw_struct_reveal(struct, W, Hh, ground_y, cxp, night, float(placed) / float(max(1, total)))
	else:
		_draw_stones(wi, W, Hh, ground_y, cxp, night, placed)
	# a worker hauling a stone toward the build (life), while unfinished
	var worker := Assets.tex("p_worker")
	if worker and placed < total:
		var wx: float = lerpf(W * 0.30, cxp - W * 0.13, 0.5 + 0.5 * sin(t * 0.6))
		Assets.draw_anchored(self, worker, Vector2(wx, ground_y + Hh * 0.15), Hh * 0.16, Color.WHITE.lerp(Color8(120, 130, 190), night * 0.5))
	# the character, watching the build
	_character(Vector2(W * 0.16, ground_y + Hh * 0.14), Hh * 0.34, night)
	if night > 0.05:
		draw_rect(Rect2(0, 0, W, Hh), Color(0.10, 0.12, 0.30, night * 0.20))
	_draw_particles()
	_draw_hud(W)

# a real 3D structure revealed from the ground up as `f` (0..1) of stones land
func _draw_struct_reveal(tex: Texture2D, W: float, Hh: float, ground_y: float, cxp: float, night: float, f: float) -> void:
	var target_h := ground_y * 0.82
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	var s := target_h / th
	var dw := tw * s
	var dh := target_h
	var sx := cxp - dw / 2.0
	var sbottom := ground_y + Hh * 0.17
	var mod := Color.WHITE.lerp(Color8(120, 130, 190), night * 0.5)
	# ground shadow
	draw_colored_polygon(Art.ellipse(Vector2(cxp, sbottom), dw * 0.42, dh * 0.03), Color(0, 0, 0, 0.14))
	# faint ghost of the finished wonder
	draw_texture_rect(tex, Rect2(sx, sbottom - dh, dw, dh), false, Color(mod.r, mod.g, mod.b, 0.12))
	# revealed bottom portion (rises course by course)
	f = clampf(f, 0.0, 1.0)
	if f > 0.002:
		var rev_h := f * dh
		var src := Rect2(0, th * (1.0 - f), tw, th * f)
		var dest := Rect2(sx, sbottom - rev_h, dw, rev_h)
		draw_texture_rect_region(tex, dest, src, mod)
		# a soft "build line" glow at the current top
		draw_rect(Rect2(sx, sbottom - rev_h - 1, dw, 2), Color(1.0, 0.92, 0.6, 0.35))

# fallback: stacked stone blocks (used only if a wonder has no 3D image)
func _draw_stones(wi: int, W: float, Hh: float, ground_y: float, cxp: float, night: float, placed: int) -> void:
	var lay := Wonders.layout(wi)
	var span := Wonders.span(wi)
	var courses := Wonders.height_courses(wi)
	var sw_w := (W * 0.66) / span
	var sw_h := (ground_y * 0.92) / (courses * 0.5 + 1.3)
	var sw: float = min(sw_w, sw_h)
	var sh := sw
	var ch := sh * 0.50
	var base_y := ground_y + Hh * 0.10
	var wd := Wonders.wonder(wi)
	var stone := Assets.tex(wd.get("stone", "p_stone"))
	if stone == null:
		stone = Assets.tex("p_stone")
	var cap := Assets.tex("p_capstone")
	var tint: Color = wd.get("tint", Color.WHITE)
	var mod := Color.WHITE.lerp(Color8(120, 130, 190), night * 0.5) * tint
	for i in lay.size():
		if i < placed: continue
		var s = lay[i]
		var tx: Texture2D = cap if s.gold else stone
		if tx:
			Assets.draw_anchored(self, tx, Vector2(cxp + float(s.x) * sw, base_y - float(s.y) * ch), sh * (0.86 if s.gold else 1.0), Color(0.42, 0.36, 0.30, 0.11))
	for i in min(placed, lay.size()):
		var s = lay[i]
		var px := cxp + float(s.x) * sw
		var py := base_y - float(s.y) * ch
		if s.gold and cap:
			Assets.draw_anchored(self, cap, Vector2(px, py), sh * 0.86, Color.WHITE.lerp(Color8(150, 150, 200), night * 0.4))
		elif stone:
			Assets.draw_anchored(self, stone, Vector2(px, py), sh, mod)

func _character(foot: Vector2, height: float, night: float) -> void:
	Wardrobe.draw_character(self, foot, height, night)

func _draw_bg(bg: Texture2D, W: float, Hh: float, night: float, grade := Color.WHITE) -> void:
	# cover-fit the painted scene, then grade toward dusk/night + theme
	var tw := float(bg.get_width())
	var th := float(bg.get_height())
	var s: float = max(W / tw, Hh / th)
	var dw := tw * s
	var dh := th * s
	var rect := Rect2((W - dw) / 2.0, (Hh - dh) / 2.0, dw, dh)
	var mod := Color.WHITE.lerp(Color8(70, 80, 150), night * 0.55) * grade
	draw_texture_rect(bg, rect, false, mod)

func _camel_tex() -> Texture2D:
	var cstage := AppState.camel_stage()
	var skin_id := AppState.equipped_skin
	var t1 := ("camel_s%d" % cstage) if skin_id == "classic" else ("skin_%s" % skin_id)
	var ctex := Assets.tex(t1)
	if ctex == null and skin_id != "classic":
		ctex = Assets.tex("camel_s%d" % cstage)
	if ctex == null:
		ctex = Assets.tex("camel_adult")
	return ctex

func _draw_camel(W: float, ground_y: float, stage: int, night: float) -> void:
	var cstage := AppState.camel_stage()
	var bob := sin(t * 2.0) * (2.2 if running else 1.4)
	var ctex := _camel_tex()
	if ctex:
		var hfac: float = [0.34, 0.44, 0.52, 0.58][cstage]
		var target_h: float = ground_y * hfac
		if pop_t > 0.0:
			target_h *= 1.0 + sin((1.0 - pop_t) * PI) * 0.10
		if running:
			target_h *= 1.0 + 0.03 * sin(t * 4.0)
		# soft contact shadow
		draw_colored_polygon(Art.ellipse(Vector2(W * 0.5, ground_y + 8), target_h * 0.28, target_h * 0.05), Color(0, 0, 0, 0.16))
		var grade: Color = Catalog.theme(AppState.equipped_theme).get("grade", Color.WHITE)
		var mod := Color.WHITE.lerp(Color8(120, 130, 190), night * 0.5) * grade
		Assets.draw_anchored(self, ctex, Vector2(W * 0.5, ground_y + 10 + bob), target_h, mod)
	else:
		var skin := Catalog.skin(AppState.equipped_skin)
		var cs := _ps() * (1.0 + (0.06 if running else 0.0) * sin(t * 4.0))
		if pop_t > 0.0:
			cs *= 1.0 + sin((1.0 - pop_t) * PI) * 0.12
		Art.camel(self, Vector2(W * 0.5, ground_y + 6), cs, cstage, skin, t, blink)

func _focus_ring(W: float, ground_y: float, stage: int) -> void:
	var cstage := AppState.camel_stage()
	var hfac: float = [0.34, 0.44, 0.52, 0.58][cstage]
	var rc := Vector2(W * 0.5, ground_y + 6 - ground_y * hfac * 0.5)
	var rr: float = ground_y * hfac * 0.62 + 14
	draw_arc(rc, rr, -PI / 2, -PI / 2 + TAU, 64, Color(0, 0, 0, 0.10), 5.0)
	draw_arc(rc, rr, -PI / 2, -PI / 2 + live_growth * TAU, 64, Color8(230, 179, 74), 5.0, true)

# floating HUD over the scene: streak, drops, and the stage/name banner.
# Frosted warm-dark pills with light text read cleanly over the bright scene.
const HUD_BG := Color(0.20, 0.15, 0.13, 0.46)
const HUD_FG := Color(0.99, 0.97, 0.93)

func _draw_hud(W: float) -> void:
	_pill_stat(16, 14, "🔥", Loc.num(AppState.streak))
	_pill_stat(16, 44, "💧", Loc.num(AppState.coins))
	if big_timer != "":
		# focus session: big timer over the scene instead of the stage banner
		var tw := UI.text_w(big_timer, 52)
		UI.pill(self, Rect2(W / 2.0 - tw / 2.0 - 24, 12, tw + 48, 60), HUD_BG)
		UI.text(self, big_timer, W / 2.0, 56, 52, HUD_FG, HORIZONTAL_ALIGNMENT_CENTER)
		if big_sub != "":
			UI.text(self, big_sub, W / 2.0, 86, 14, Color(0.92, 0.88, 0.80), HORIZONTAL_ALIGNMENT_CENTER)
		return
	var st := AppState.world_stage()
	var lbl := AppState.stage_name(st) + " · " + Loc.num(AppState.stones_in_wonder()) + "/" + Loc.num(AppState.stones_needed())
	var lw := UI.text_w(lbl, 14) + 24
	UI.pill(self, Rect2((W - lw) / 2.0, 14, lw, 26), HUD_BG)
	UI.text(self, lbl, W / 2.0, 31, 14, HUD_FG, HORIZONTAL_ALIGNMENT_CENTER)
	if AppState.ramadan_mode:
		var greet := Loc.t("ramadan_greet")
		var gw := UI.text_w(greet, 12) + 20
		UI.pill(self, Rect2((W - gw) / 2.0, 44, gw, 22), Color(0.16, 0.16, 0.30, 0.55))
		UI.text(self, greet, W / 2.0, 60, 12, Color8(255, 240, 200), HORIZONTAL_ALIGNMENT_CENTER)

func _pill_stat(x: float, y: float, icon: String, val: String) -> void:
	var label := icon + " " + val
	var pw := UI.text_w(label, 14) + 18
	UI.pill(self, Rect2(x, y, pw, 26), HUD_BG)
	UI.text(self, label, x + 10, y + 18, 14, HUD_FG)

func _ps() -> float:
	# responsive art scale from the scene height
	return clampf(size.y / 300.0, 0.9, 1.7)

func _dune(y: float, phase: float, col: Color, h: float) -> void:
	var W := size.x
	var pts := PackedVector2Array()
	pts.append(Vector2(0, size.y))
	var steps := 18
	for i in steps + 1:
		var x := W * i / steps
		var yy := y - sin(i / float(steps) * PI * h + phase) * 16.0
		pts.append(Vector2(x, yy))
	pts.append(Vector2(W, size.y))
	draw_colored_polygon(pts, col)

func _draw_particles() -> void:
	for p in particles:
		var a: float = clamp(p.life / p.max, 0.0, 1.0)
		var c: Color = p.col
		draw_circle(p.pos, 3.0 * a + 1.0, Color(c.r, c.g, c.b, a))
