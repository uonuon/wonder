extends RefCounted
class_name Catalog
# Shared static data: growth stages, camel skins, oasis themes (biomes).
# Pure data so AppState, World, Art and the Shop all agree.

# --- World growth -----------------------------------------------------
# A stage unlocks at a cumulative completed-session count. Each higher
# stage layers new decor on top of the previous ones (see World.gd).
const STAGE_THRESHOLDS := [0, 1, 3, 6, 10, 15, 22, 30, 40]   # 9 stages, 0..8
const STAGE_NAMES_EN := [
	"Barren Dune", "First Sprout", "Young Palm", "The Oasis Wakes",
	"Blooming Sands", "Bedouin Camp", "The Caravan", "Lantern Village", "Grand Oasis"]
const STAGE_NAMES_AR := [
	"كثيب قاحل", "أول برعم", "نخلة فتية", "الواحة تستيقظ",
	"رمال مزهرة", "مخيم بدوي", "القافلة", "قرية الفوانيس", "الواحة الكبرى"]

static func stage_for(sessions: int) -> int:
	var s := 0
	for i in STAGE_THRESHOLDS.size():
		if sessions >= STAGE_THRESHOLDS[i]:
			s = i
	return s

static func next_threshold(sessions: int) -> int:
	for t in STAGE_THRESHOLDS:
		if sessions < t:
			return t
	return STAGE_THRESHOLDS[STAGE_THRESHOLDS.size() - 1]

# Camel grows in 4 steps keyed to total sessions.
const CAMEL_THRESHOLDS := [0, 3, 10, 22]
static func camel_stage_for(sessions: int) -> int:
	var s := 0
	for i in CAMEL_THRESHOLDS.size():
		if sessions >= CAMEL_THRESHOLDS[i]:
			s = i
	return s

# --- Camel skins ------------------------------------------------------
# coat = body color, sad = saddle/blanket color, accent = trim.
static func skins() -> Array:
	return [
		{"id": "classic", "en": "Sahari", "ar": "صحاري", "price": 0, "premium": false,
			"coat": Color8(214, 170, 110), "coat_dk": Color8(184, 140, 86),
			"sad": Color8(200, 98, 60), "accent": Color8(230, 179, 74)},
		{"id": "rose", "en": "Desert Rose", "ar": "وردة الصحراء", "price": 120, "premium": false,
			"coat": Color8(224, 188, 140), "coat_dk": Color8(196, 158, 112),
			"sad": Color8(214, 110, 130), "accent": Color8(245, 222, 200)},
		{"id": "bedouin", "en": "Bedouin Weave", "ar": "نسيج بدوي", "price": 250, "premium": false,
			"coat": Color8(206, 162, 104), "coat_dk": Color8(176, 132, 80),
			"sad": Color8(120, 70, 60), "accent": Color8(214, 188, 132)},
		{"id": "snow", "en": "Snow Camel", "ar": "جمل الثلج", "price": 300, "premium": false,
			"coat": Color8(238, 234, 226), "coat_dk": Color8(206, 200, 190),
			"sad": Color8(90, 140, 170), "accent": Color8(225, 240, 248)},
		{"id": "royal", "en": "Royal Gulf", "ar": "الخليج الملكي", "price": 400, "premium": true,
			"coat": Color8(222, 196, 150), "coat_dk": Color8(196, 166, 116),
			"sad": Color8(140, 30, 50), "accent": Color8(236, 198, 96)},
		{"id": "midnight", "en": "Midnight", "ar": "منتصف الليل", "price": 350, "premium": true,
			"coat": Color8(120, 120, 158), "coat_dk": Color8(92, 92, 128),
			"sad": Color8(60, 56, 110), "accent": Color8(150, 200, 240)},
		{"id": "emerald", "en": "Emerald", "ar": "زمرّد", "price": 280, "premium": false,
			"coat": Color8(216, 174, 112), "coat_dk": Color8(186, 144, 88),
			"sad": Color8(36, 130, 84), "accent": Color8(236, 198, 96)},
		{"id": "pharaoh", "en": "Pharaoh", "ar": "فرعون", "price": 420, "premium": true,
			"coat": Color8(220, 190, 140), "coat_dk": Color8(190, 160, 112),
			"sad": Color8(54, 160, 168), "accent": Color8(236, 198, 96)},
	]

static func skin(id: String) -> Dictionary:
	for s in skins():
		if s.id == id:
			return s
	return skins()[0]

# --- Oasis themes (biomes) -------------------------------------------
# Palette overrides for the whole scene. World.gd reads these.
static func themes() -> Array:
	return [
		{"id": "sahara", "en": "Classic Sahara", "ar": "الصحراء الكلاسيكية", "price": 0, "premium": false,
			"sky_day": Color8(249, 232, 198), "sky_dusk": Color8(232, 175, 130),
			"sand": Color8(220, 194, 142), "sand_dk": Color8(198, 170, 116),
			"water": Color8(58, 154, 150), "palm": Color8(79, 138, 62),
			"grade": Color8(255, 255, 255), "night_bias": 0.0},
		{"id": "sunset", "en": "Sunset Dunes", "ar": "كثبان الغروب", "price": 200, "premium": false,
			"sky_day": Color8(250, 206, 160), "sky_dusk": Color8(226, 122, 96),
			"sand": Color8(214, 168, 120), "sand_dk": Color8(190, 140, 96),
			"water": Color8(120, 120, 170), "palm": Color8(120, 120, 64),
			"grade": Color8(255, 196, 150), "night_bias": 0.15},
		{"id": "verdant", "en": "Verdant Oasis", "ar": "الواحة الخضراء", "price": 300, "premium": false,
			"sky_day": Color8(226, 238, 206), "sky_dusk": Color8(214, 196, 150),
			"sand": Color8(206, 198, 150), "sand_dk": Color8(176, 172, 122),
			"water": Color8(54, 168, 154), "palm": Color8(64, 150, 58),
			"grade": Color8(214, 240, 206), "night_bias": 0.0},
		{"id": "starlight", "en": "Starlight Oasis", "ar": "واحة النجوم", "price": 450, "premium": true,
			"sky_day": Color8(118, 134, 188), "sky_dusk": Color8(70, 78, 138),
			"sand": Color8(150, 150, 184), "sand_dk": Color8(122, 122, 158),
			"water": Color8(96, 140, 200), "palm": Color8(86, 120, 110),
			"grade": Color8(150, 165, 225), "night_bias": 0.6},
	]

static func theme(id: String) -> Dictionary:
	for t in themes():
		if t.id == id:
			return t
	return themes()[0]
