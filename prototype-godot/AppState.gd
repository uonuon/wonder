extends Node
# Persistent state for Tarkeez: focus totals, streak, growth, economy,
# unlocks, settings and per-day history. Autoloaded as `AppState`.

# --- focus / progress -------------------------------------------------
var total_focus_sec := 0
var today_focus_sec := 0
var sessions_total := 0
var sessions_today := 0
var streak := 0
var best_streak := 0
var coins := 0                      # "water drops" – the soft currency
var last_day := ""

# --- profile / onboarding --------------------------------------------
var onboarded := false
var camel_name := ""
var daily_goal_min := 60

# --- unlocks ----------------------------------------------------------
var equipped_skin := "classic"
var owned_skins := ["classic"]
var equipped_theme := "sahara"
var owned_themes := ["sahara"]

# --- settings ---------------------------------------------------------
var sound_on := true
var language := "en"                # "en" | "ar"
var notifications_on := true
var haptics_on := true
var ramadan_mode := false

# --- Tarkeez+ subscription (mock flag until real store IAP) -----------
var plus := false

# --- character: pick a full look (no fragile layering) ----------------
var equipped_character := "pharaoh"
var owned_characters := ["pharaoh", "builder"]

# --- scene/environment ------------------------------------------------
var equipped_scene := "auto"
var owned_scenes := ["auto", "giza"]

func owns_scene(id: String) -> bool:
	return id in owned_scenes

func buy_scene(id: String) -> String:
	var sc := Wardrobe.scene(id)
	if owns_scene(id):
		return "owned"
	if sc.premium and not plus:
		return "plus"
	if coins < int(sc.price):
		return "coins"
	coins -= int(sc.price)
	owned_scenes.append(id)
	save_data()
	changed.emit()
	return ""

func equip_scene(id: String) -> void:
	if owns_scene(id):
		equipped_scene = id
		save_data()
		changed.emit()

func owns_character(id: String) -> bool:
	return id in owned_characters

func buy_character(id: String) -> String:
	var c := Wardrobe.character(id)
	if owns_character(id):
		return "owned"
	if c.premium and not plus:
		return "plus"
	if coins < int(c.price):
		return "coins"
	coins -= int(c.price)
	owned_characters.append(id)
	save_data()
	changed.emit()
	return ""

func equip_character(id: String) -> void:
	if owns_character(id):
		equipped_character = id
		save_data()
		changed.emit()

# (legacy layered-cosmetics state, unused now — kept only for save compat)
var cos_equipped := {}
var cos_owned := {}

# --- history: { "YYYY-MM-DD": focus_seconds } -------------------------
var history := {}

const SAVE := "user://tarkeez_save.json"

signal changed                      # emitted whenever persistent state mutates

var fast := false                   # dev/test: sessions run in seconds, +session button

func _ready() -> void:
	var args := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	if "--fast" in args:
		fast = true
	load_data()
	if last_day != "" and last_day != today():
		today_focus_sec = 0
		sessions_today = 0
		# streak break check: if the gap is more than a day, reset on next session
		if last_day != yesterday():
			streak = 0

# --- date helpers -----------------------------------------------------
func today() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]

func yesterday() -> String:
	var u := int(Time.get_unix_time_from_system()) - 86400
	var d := Time.get_date_dict_from_unix_time(u)
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]

func date_offset(days_back: int) -> String:
	var u := int(Time.get_unix_time_from_system()) - days_back * 86400
	var d := Time.get_date_dict_from_unix_time(u)
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]

# --- derived growth: Build-a-Wonder (stone per session) ---------------
func stones_total() -> int:
	return sessions_total * Wonders.STONES_PER_SESSION

# "stage" == which wonder is being built (0-based)
func world_stage() -> int:
	return Wonders.wonder_for_stones(stones_total())

func stones_in_wonder() -> int:
	return stones_total() - Wonders.stones_before(world_stage())

func stones_needed() -> int:
	return Wonders.stone_count(world_stage())

func sessions_to_next_stage() -> int:
	return max(0, stones_needed() - stones_in_wonder())

func stage_name(i: int) -> String:
	var w := Wonders.wonder(i)
	return w.ar if language == "ar" else w.en

func stage_progress() -> float:
	return clampf(float(stones_in_wonder()) / float(max(1, stones_needed())), 0.0, 1.0)

# legacy companion size hook (kept so old draws don't break)
func camel_stage() -> int:
	return Catalog.camel_stage_for(sessions_total)

func goal_progress() -> float:
	if daily_goal_min <= 0:
		return 1.0
	return clamp(float(today_focus_sec) / float(daily_goal_min * 60), 0.0, 1.0)

# --- the core loop ----------------------------------------------------
func complete_session(minutes: int) -> void:
	var t := today()
	if last_day != t:
		streak = (streak + 1) if last_day == yesterday() else 1
		best_streak = max(best_streak, streak)
		today_focus_sec = 0
		sessions_today = 0
	sessions_today += 1
	sessions_total += 1
	var secs := minutes * 60
	today_focus_sec += secs
	total_focus_sec += secs
	coins += _reward_for(minutes)
	history[t] = int(history.get(t, 0)) + secs
	last_day = t
	best_streak = max(best_streak, streak)
	save_data()
	changed.emit()

func achievements() -> Array:
	return [
		{"id": "first", "en": "First Focus", "ar": "أول تركيز", "icon": "ic_flame", "unlocked": sessions_total >= 1},
		{"id": "streak7", "en": "7-Day Streak", "ar": "سلسلة ٧", "icon": "ic_flame", "unlocked": best_streak >= 7},
		{"id": "hours10", "en": "10 Hours", "ar": "١٠ ساعات", "icon": "ic_trophy", "unlocked": total_focus_sec >= 36000},
		{"id": "wonder1", "en": "First Wonder", "ar": "أول أثر", "icon": "ic_moon", "unlocked": world_stage() >= 1},
		{"id": "allwonders", "en": "All Wonders", "ar": "كل الآثار", "icon": "ic_trophy", "unlocked": world_stage() >= Wonders.list().size() - 1},
		{"id": "collector", "en": "Collector", "ar": "جامع", "icon": "ic_crown", "unlocked": owned_skins.size() >= 3},
	]

func _reward_for(minutes: int) -> int:
	# 1 drop per minute, with a small completion bonus that scales with length.
	return minutes + int(minutes / 10)

# --- economy / unlocks ------------------------------------------------
func owns_skin(id: String) -> bool:
	return id in owned_skins

func owns_theme(id: String) -> bool:
	return id in owned_themes

# premium items need Tarkeez+ (not just coins). returns "" on success, else a
# reason key: "owned" | "plus" | "coins".
func buy_skin(id: String) -> String:
	var s := Catalog.skin(id)
	if owns_skin(id):
		return "owned"
	if s.premium and not plus:
		return "plus"
	if coins < int(s.price):
		return "coins"
	coins -= int(s.price)
	owned_skins.append(id)
	save_data()
	changed.emit()
	return ""

func buy_theme(id: String) -> String:
	var th := Catalog.theme(id)
	if owns_theme(id):
		return "owned"
	if th.premium and not plus:
		return "plus"
	if coins < int(th.price):
		return "coins"
	coins -= int(th.price)
	owned_themes.append(id)
	save_data()
	changed.emit()
	return ""

func subscribe_plus() -> void:
	plus = true
	save_data()
	changed.emit()

func restore_plus() -> void:
	# mock: in a real build this checks the store receipt
	pass

func equip_skin(id: String) -> void:
	if owns_skin(id):
		equipped_skin = id
		save_data()
		changed.emit()

func equip_theme(id: String) -> void:
	if owns_theme(id):
		equipped_theme = id
		save_data()
		changed.emit()

func set_setting(key: String, value) -> void:
	match key:
		"sound_on": sound_on = bool(value)
		"language": language = str(value)
		"daily_goal_min": daily_goal_min = int(value)
		"camel_name": camel_name = str(value)
		"onboarded": onboarded = bool(value)
		"notifications_on": notifications_on = bool(value)
		"haptics_on": haptics_on = bool(value)
		"ramadan_mode": ramadan_mode = bool(value)
	save_data()
	changed.emit()

func reset_progress() -> void:
	total_focus_sec = 0; today_focus_sec = 0
	sessions_total = 0; sessions_today = 0
	streak = 0; best_streak = 0; coins = 0
	garden_items = 0
	last_day = ""; history = {}
	owned_skins = ["classic"]; equipped_skin = "classic"
	owned_themes = ["sahara"]; equipped_theme = "sahara"
	save_data()
	changed.emit()

# legacy field kept so old saves & tests stay valid
var garden_items := 0

# --- persistence ------------------------------------------------------
func save_data() -> void:
	var data := {
		"total_focus_sec": total_focus_sec, "today_focus_sec": today_focus_sec,
		"sessions_total": sessions_total, "sessions_today": sessions_today,
		"streak": streak, "best_streak": best_streak, "coins": coins,
		"garden_items": garden_items, "last_day": last_day,
		"onboarded": onboarded, "camel_name": camel_name, "daily_goal_min": daily_goal_min,
		"equipped_skin": equipped_skin, "owned_skins": owned_skins,
		"equipped_theme": equipped_theme, "owned_themes": owned_themes,
		"sound_on": sound_on, "language": language, "history": history,
		"notifications_on": notifications_on, "haptics_on": haptics_on,
		"ramadan_mode": ramadan_mode, "plus": plus,
		"cos_equipped": cos_equipped, "cos_owned": cos_owned,
		"equipped_character": equipped_character, "owned_characters": owned_characters,
		"equipped_scene": equipped_scene, "owned_scenes": owned_scenes,
	}
	var f := FileAccess.open(SAVE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE):
		return
	var f := FileAccess.open(SAVE, FileAccess.READ)
	if not f:
		return
	var raw = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(raw) != TYPE_DICTIONARY:
		return
	total_focus_sec = int(raw.get("total_focus_sec", 0))
	today_focus_sec = int(raw.get("today_focus_sec", 0))
	sessions_total = int(raw.get("sessions_total", 0))
	sessions_today = int(raw.get("sessions_today", 0))
	streak = int(raw.get("streak", 0))
	best_streak = int(raw.get("best_streak", 0))
	coins = int(raw.get("coins", 0))
	garden_items = int(raw.get("garden_items", 0))
	last_day = str(raw.get("last_day", ""))
	onboarded = bool(raw.get("onboarded", false))
	camel_name = str(raw.get("camel_name", ""))
	daily_goal_min = int(raw.get("daily_goal_min", 60))
	equipped_skin = str(raw.get("equipped_skin", "classic"))
	equipped_theme = str(raw.get("equipped_theme", "sahara"))
	sound_on = bool(raw.get("sound_on", true))
	language = str(raw.get("language", "en"))
	notifications_on = bool(raw.get("notifications_on", true))
	haptics_on = bool(raw.get("haptics_on", true))
	ramadan_mode = bool(raw.get("ramadan_mode", false))
	plus = bool(raw.get("plus", false))
	equipped_character = str(raw.get("equipped_character", "pharaoh"))
	var oc = raw.get("owned_characters", null)
	if typeof(oc) == TYPE_ARRAY:
		owned_characters = []
		for x in oc:
			if not (str(x) in owned_characters): owned_characters.append(str(x))
	if not ("pharaoh" in owned_characters): owned_characters.append("pharaoh")
	equipped_scene = str(raw.get("equipped_scene", "auto"))
	var os2 = raw.get("owned_scenes", null)
	if typeof(os2) == TYPE_ARRAY:
		owned_scenes = []
		for x in os2:
			if not (str(x) in owned_scenes): owned_scenes.append(str(x))
	for must in ["auto", "giza"]:
		if not (must in owned_scenes): owned_scenes.append(must)
	var ce = raw.get("cos_equipped", null)
	if typeof(ce) == TYPE_DICTIONARY:
		for s in ["head", "cloth", "hand", "feet"]:
			if ce.has(s): cos_equipped[s] = str(ce[s])
	var co = raw.get("cos_owned", null)
	if typeof(co) == TYPE_DICTIONARY:
		for s in ["head", "cloth", "hand", "feet"]:
			if co.has(s) and typeof(co[s]) == TYPE_ARRAY:
				var arr := ["none"]
				for x in co[s]:
					if not (str(x) in arr): arr.append(str(x))
				cos_owned[s] = arr
	var os = raw.get("owned_skins", ["classic"])
	if typeof(os) == TYPE_ARRAY:
		owned_skins = []
		for x in os: owned_skins.append(str(x))
	if not ("classic" in owned_skins): owned_skins.append("classic")
	var ot = raw.get("owned_themes", ["sahara"])
	if typeof(ot) == TYPE_ARRAY:
		owned_themes = []
		for x in ot: owned_themes.append(str(x))
	if not ("sahara" in owned_themes): owned_themes.append("sahara")
	var h = raw.get("history", {})
	if typeof(h) == TYPE_DICTIONARY:
		history = {}
		for k in h.keys():
			history[str(k)] = int(h[k])
