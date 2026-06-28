extends RefCounted
class_name Assets
# Loads generated raster art from assets/gen/ when present, with a cache.
# Everything that uses this falls back to procedural Art if a texture is
# missing, so the app looks complete with or without the AI art set.

static var _cache := {}

static func tex(name: String) -> Texture2D:
	if _cache.has(name):
		return _cache[name]
	var p := "res://assets/gen/%s.png" % name
	var t: Texture2D = null
	if ResourceLoader.exists(p):
		var r = load(p)
		if r is Texture2D:
			t = r
	_cache[name] = t
	return t

static func has(name: String) -> bool:
	return tex(name) != null

# draw a texture into a box, preserving aspect, anchored at the BOTTOM-center
static func draw_anchored(ci: CanvasItem, t: Texture2D, foot: Vector2, target_h: float, modulate := Color.WHITE) -> void:
	var tw := float(t.get_width())
	var th := float(t.get_height())
	var s := target_h / th
	var w := tw * s
	var rect := Rect2(foot.x - w / 2.0, foot.y - target_h, w, target_h)
	ci.draw_texture_rect(t, rect, false, modulate)

# draw a texture CENTERED on a point, preserving aspect (for layered cosmetics)
static func draw_centered(ci: CanvasItem, t: Texture2D, center: Vector2, target_h: float, modulate := Color.WHITE) -> void:
	var tw := float(t.get_width())
	var th := float(t.get_height())
	var s := target_h / th
	var w := tw * s
	ci.draw_texture_rect(t, Rect2(center.x - w / 2.0, center.y - target_h / 2.0, w, target_h), false, modulate)
