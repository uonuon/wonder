extends RefCounted
class_name Wonders
# Build-a-Wonder: each wonder is an ORDERED list of stone placements so the
# structure rises deliberately, one stone per focus session. No random scatter.

const STONES_PER_SESSION := 1

static func list() -> Array:
	return [
		{"id": "great", "en": "Great Pyramid", "ar": "الهرم الأكبر", "bg": "bg_giza",
			"stone": "p_stone_white", "tint": Color8(255, 255, 255),
			"type": "pyramid", "rows": 6},
		{"id": "djoser", "en": "Step Pyramid", "ar": "الهرم المدرّج", "bg": "bg_giza",
			"stone": "p_stone", "tint": Color8(236, 214, 170),
			"type": "step", "tiers": [[9, 2], [7, 2], [5, 2], [3, 1], [1, 1]]},
		{"id": "red", "en": "Red Pyramid", "ar": "الهرم الأحمر", "bg": "bg_giza_sunset",
			"stone": "p_stone_red", "tint": Color8(255, 255, 255),
			"type": "pyramid", "rows": 7},
		{"id": "obelisk", "en": "Great Obelisk", "ar": "المسلّة الكبرى", "bg": "bg_temple",
			"stone": "p_stone_dark", "tint": Color8(255, 255, 255),
			"type": "tower", "width": 2, "courses": 12},
		{"id": "pylon", "en": "Temple Pylon", "ar": "صرح المعبد", "bg": "bg_temple",
			"stone": "p_stone", "tint": Color8(240, 218, 178),
			"type": "towers", "towers": [[-3.5, 3, 7], [3.5, 3, 7]]},
		{"id": "ziggurat", "en": "Grand Ziggurat", "ar": "الزقورة الكبرى", "bg": "bg_nile",
			"stone": "p_stone", "tint": Color8(214, 176, 132),
			"type": "step", "tiers": [[11, 2], [9, 2], [7, 2], [5, 2], [3, 2], [1, 1]]},
		{"id": "giza", "en": "Giza Complex", "ar": "أهرامات الجيزة", "bg": "bg_giza_sunset",
			"stone": "p_stone_white", "tint": Color8(255, 248, 232),
			"type": "trio", "rows": [6, 5, 4], "xoff": [-9.5, 0.0, 8.5]},
		{"id": "grand", "en": "Eternal Giza", "ar": "الجيزة الخالدة", "bg": "bg_giza_night",
			"stone": "p_stone", "tint": Color8(244, 222, 168),
			"type": "trio", "rows": [7, 6, 5], "xoff": [-11.0, 0.0, 10.0]},
	]

static func wonder(i: int) -> Dictionary:
	var l := list()
	return l[clampi(i, 0, l.size() - 1)]

# ordered stones: each = {x: float (stone-units from center), y: int (course, 0=ground), gold: bool}
static func layout(i: int) -> Array:
	var w := wonder(i)
	var out := []
	match w.type:
		"pyramid":
			_pyramid(out, int(w.rows), 0.0)
		"step":
			var y := 0
			for tier in w.tiers:
				var width: int = tier[0]
				for _course in range(tier[1]):
					for c in width:
						out.append({"x": c - (width - 1) / 2.0, "y": y, "gold": false})
					y += 1
			out.append({"x": 0.0, "y": y, "gold": true})
		"trio":
			var rows_arr: Array = w.rows
			var xoff: Array = w.xoff
			for pi in rows_arr.size():
				_pyramid(out, int(rows_arr[pi]), float(xoff[pi]))
		"tower":
			var width: int = w.width
			for c in int(w.courses):
				for k in width:
					out.append({"x": k - (width - 1) / 2.0, "y": c, "gold": false})
			out.append({"x": 0.0, "y": int(w.courses), "gold": false})      # taper
			out.append({"x": 0.0, "y": int(w.courses) + 1, "gold": true})   # pyramidion
		"towers":
			for tw in w.towers:
				var xo: float = tw[0]
				var width2: int = tw[1]
				for c in int(tw[2]):
					for k in width2:
						out.append({"x": xo + k - (width2 - 1) / 2.0, "y": c, "gold": false})
	return out

static func _pyramid(out: Array, rows: int, xoff: float) -> void:
	for r in rows:
		var n := rows - r
		for c in n:
			out.append({"x": xoff + c - (n - 1) / 2.0, "y": r, "gold": false})
	out.append({"x": xoff, "y": rows, "gold": true})   # gold capstone last

static func stone_count(i: int) -> int:
	return layout(i).size()

# widest course (in stone-units) — for sizing the scene
static func span(i: int) -> float:
	var maxx := 1.0
	for s in layout(i):
		maxx = max(maxx, abs(s.x) + 0.5)
	return maxx * 2.0

static func height_courses(i: int) -> int:
	var maxy := 1
	for s in layout(i):
		maxy = max(maxy, int(s.y) + 1)
	return maxy

# --- progression: stones accumulate across wonders ----------------------
static func total_to_finish(i: int) -> int:
	var t := 0
	for k in range(i + 1):
		t += stone_count(k)
	return t

static func wonder_for_stones(stones: int) -> int:
	var acc := 0
	for k in list().size():
		acc += stone_count(k)
		if stones < acc:
			return k
	return list().size() - 1

static func stones_before(i: int) -> int:
	var t := 0
	for k in i:
		t += stone_count(k)
	return t
