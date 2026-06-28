extends Control
# The focus session: the FULL landscape pyramid scene + a timer overlaid.

const World := preload("res://screens/World.gd")
signal finished(completed: bool, stage_up: int)

var world: Control
var minutes := 25
var pomodoro := false
var phase := "focus"
var session_len := 1500.0
var time_left := 0.0
var running := false
var giveup_btn: Button
var msg := ""
var msg_t := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	world = World.new()
	world.position = Vector2.ZERO
	world.size = size
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world)
	giveup_btn = UI.button(Loc.t("give_up"), 150, 40, Color(0.20, 0.15, 0.13, 0.5), Color(0.99, 0.97, 0.93), 16)
	UI.style(giveup_btn, Color(0.20, 0.15, 0.13, 0.5), Color(0.99, 0.97, 0.93), 20)
	giveup_btn.position = Vector2(size.x / 2.0 - 75, size.y - 60)
	giveup_btn.pressed.connect(_give_up)
	add_child(giveup_btn)

func begin(m: int, pomo: bool) -> void:
	minutes = m
	pomodoro = pomo
	phase = "focus"
	session_len = m * (1.0 if AppState.fast else 60.0)
	time_left = session_len
	running = true
	world.running = true
	world.live_growth = 0.0
	_flash(Loc.t("keep_focus"))
	Audio.start_ambient()

func _give_up() -> void:
	running = false
	world.running = false
	Audio.stop_ambient()
	finished.emit(false, -1)

func _complete() -> void:
	running = false
	world.running = false
	world.live_growth = 0.0
	var pre := AppState.world_stage()
	AppState.complete_session(minutes)
	if AppState.haptics_on:
		Input.vibrate_handheld(40)
	Audio.chime()
	world.celebrate()
	Audio.stop_ambient()
	var su := AppState.world_stage() if AppState.world_stage() > pre else -1
	await get_tree().create_timer(0.6).timeout
	finished.emit(true, su)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and running and phase == "focus":
		running = false
		world.running = false
		Audio.stop_ambient()
		finished.emit(false, -1)

func _flash(m: String) -> void:
	msg = m; msg_t = 3.5

func _clock(sec: int) -> String:
	return "%02d:%02d" % [int(sec / 60), sec % 60]

func _process(dt: float) -> void:
	if running:
		time_left -= dt
		world.live_growth = clamp(1.0 - time_left / session_len, 0.0, 1.0)
		if time_left <= 0.0:
			_complete()
	if msg_t > 0:
		msg_t -= dt
	var tt: float = time_left * 60.0 if AppState.fast else time_left
	world.big_timer = _clock(int(ceil(max(0.0, tt))))
	world.big_sub = msg if msg_t > 0 else Loc.t("focusing")
