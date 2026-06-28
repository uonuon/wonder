extends Node
# Procedural audio for Tarkeez — no sound files needed. Generates a soft
# ambient desert pad plus completion/tap cues as PCM. Autoloaded as `Audio`.

const RATE := 22050

var amb_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var _amb: AudioStreamWAV

func _ready() -> void:
	amb_player = AudioStreamPlayer.new()
	amb_player.volume_db = -16.0
	add_child(amb_player)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -6.0
	add_child(sfx_player)
	_amb = _ambient_loop()
	amb_player.stream = _amb

func _enabled() -> bool:
	return AppState.sound_on

func start_ambient() -> void:
	if _enabled() and not amb_player.playing:
		amb_player.play()

func stop_ambient() -> void:
	if amb_player.playing:
		amb_player.stop()

func chime() -> void:
	if not _enabled(): return
	sfx_player.stream = _tone([523.25, 659.25, 783.99, 1046.5], 0.7, 0.16, true)
	sfx_player.play()

func tap() -> void:
	if not _enabled(): return
	sfx_player.stream = _tone([440.0], 0.06, 0.0, false)
	sfx_player.play()

# ---- synthesis -------------------------------------------------------
func _wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		var v := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, v)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = bytes
	return w

# A short arpeggio/tone cluster. stagger>0 spreads notes in time (arpeggio).
func _tone(freqs: Array, dur: float, stagger: float, soft: bool) -> AudioStreamWAV:
	var n := int(dur * RATE)
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var time := float(i) / RATE
		var v := 0.0
		for k in freqs.size():
			var start := k * stagger
			if time < start: continue
			var lt := time - start
			var env: float = exp(-lt * (3.0 if soft else 14.0))
			var wave := sin(TAU * freqs[k] * lt)
			if soft:
				wave += 0.3 * sin(TAU * freqs[k] * 2.0 * lt)
			v += wave * env
		s[i] = v / max(1, freqs.size()) * 0.8
	return _wav(s)

# Seamless looping ambient: low drone + slow shimmer + airy noise.
func _ambient_loop() -> AudioStreamWAV:
	var dur := 6.0
	var n := int(dur * RATE)
	var s := PackedFloat32Array()
	s.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var noise := 0.0
	for i in n:
		var time := float(i) / RATE
		# use period-locked frequencies so the loop is seamless
		var drone := sin(TAU * 2.0 * time / dur * 55.0 / (2.0)) # low pad
		var pad := 0.5 * sin(TAU * (110.0) * time + 0.5 * sin(TAU * time / dur))
		var shimmer := 0.18 * sin(TAU * 220.0 * time) * (0.5 + 0.5 * sin(TAU * time / dur))
		noise = noise * 0.98 + rng.randf_range(-1.0, 1.0) * 0.02
		var amp := 0.5 + 0.5 * sin(TAU * time / dur - PI / 2)
		s[i] = (0.4 * pad + 0.25 * drone + shimmer + 0.15 * noise) * (0.4 + 0.3 * amp)
	var w := _wav(s)
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = n
	return w
