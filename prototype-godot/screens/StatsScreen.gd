extends Control
# Stats (portrait): totals, growth, goal, heatmap, achievements stacked.

const M := 24.0
const W := 540.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AppState.changed.connect(queue_redraw)

func relocalize() -> void:
	queue_redraw()

func _fmt(sec: int) -> String:
	var m := int(sec / 60.0)
	if m >= 60:
		return "%d%s %d%s" % [int(m / 60), Loc.t("hr_short"), m % 60, Loc.t("min_short")]
	return "%d%s" % [m, Loc.t("min_short")]

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, 884), UI.BG)
	UI.text(self, Loc.t("nav_stats"), M, 56, 28, UI.INK)

	var cards := [
		[Loc.t("total_focus"), _fmt(AppState.total_focus_sec), UI.GREEN_DK],
		[Loc.t("streak"), Loc.num(AppState.streak) + "🔥", UI.TERRA],
		[Loc.t("best_streak"), Loc.num(AppState.best_streak), UI.GOLD],
	]
	var cw := (W - 2 * M - 2 * 10) / 3.0
	for i in cards.size():
		var x := M + i * (cw + 10)
		UI.card(self, Rect2(x, 76, cw, 76), UI.CARD, 16)
		UI.text(self, cards[i][1], x + cw / 2.0, 118, 22, cards[i][2], HORIZONTAL_ALIGNMENT_CENTER)
		UI.text(self, cards[i][0], x + cw / 2.0, 140, 12, UI.MUTE, HORIZONTAL_ALIGNMENT_CENTER)

	# growth
	UI.card(self, Rect2(M, 168, W - 2 * M, 88), UI.CARD, 16)
	var stage := AppState.world_stage()
	UI.text(self, Loc.t("wonder") + " " + Loc.num(stage + 1) + " · " + AppState.stage_name(stage), M + 16, 198, 17, UI.INK)
	UI.bar(self, Rect2(M + 16, 216, W - 2 * M - 32, 14), AppState.stage_progress(), UI.CARD_DK, UI.GREEN)
	UI.text(self, Loc.num(AppState.stones_in_wonder()) + " / " + Loc.num(AppState.stones_needed()) + " " + Loc.t("stones"), M + 16, 246, 13, UI.MUTE)

	# goal
	UI.card(self, Rect2(M, 270, W - 2 * M, 68), UI.CARD, 16)
	UI.text(self, Loc.t("day_goal"), M + 16, 298, 15, UI.TEXT)
	UI.text(self, _fmt(AppState.today_focus_sec) + " / " + str(AppState.daily_goal_min) + Loc.t("min_short"), M + 16, 298, 14, UI.GREEN_DK, HORIZONTAL_ALIGNMENT_RIGHT, W - 2 * M - 32)
	UI.bar(self, Rect2(M + 16, 312, W - 2 * M - 32, 14), AppState.goal_progress(), UI.CARD_DK, UI.GOLD)

	# heatmap
	UI.text(self, Loc.t("this_week"), M, 380, 16, UI.INK)
	var cols := 7
	var rows := 5
	var cell := 58.0
	var gap := 8.0
	var ox := (W - (cols * cell + (cols - 1) * gap)) / 2.0
	var oy := 398.0
	var max_sec := 1
	for v in AppState.history.values():
		max_sec = max(max_sec, int(v))
	var total_days := rows * cols
	for idx in total_days:
		var days_back := total_days - 1 - idx
		var date := AppState.date_offset(days_back)
		var sec := int(AppState.history.get(date, 0))
		var cxp := ox + (idx % cols) * (cell + gap)
		var cyp := oy + int(idx / cols) * (cell + gap)
		var c := UI.CARD_DK
		if sec > 0:
			c = Color8(214, 226, 200).lerp(UI.GREEN_DK, clampf(float(sec) / float(max_sec), 0.15, 1.0))
		if date == AppState.today():
			UI._round_rect(self, Rect2(cxp - 2, cyp - 2, cell + 4, cell + 4), UI.GOLD, 12)
		UI._round_rect(self, Rect2(cxp, cyp, cell, cell), c, 11)

	# achievements
	UI.text(self, Loc.t("achievements"), M, oy + rows * (cell + gap) + 20, 16, UI.INK)
	var ach := AppState.achievements()
	var abw := (W - 2 * M) / ach.size()
	var ay := oy + rows * (cell + gap) + 60
	for i in ach.size():
		var a = ach[i]
		var bx := M + i * abw + abw / 2.0
		var unlocked: bool = a.unlocked
		draw_circle(Vector2(bx, ay), 23, UI.GOLD if unlocked else UI.CARD_DK)
		var icon := Assets.tex(a.icon)
		if icon:
			Assets.draw_anchored(self, icon, Vector2(bx, ay + 14), 26, Color8(255, 251, 242) if unlocked else UI.MUTE)
		var albl = a.ar if Loc.is_rtl() else a.en
		UI.text(self, albl, bx, ay + 40, 10, UI.TEXT if unlocked else UI.MUTE, HORIZONTAL_ALIGNMENT_CENTER)
