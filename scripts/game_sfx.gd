extends Node

## Jump SFX is fixed to this file only — do not add alternate streams for [method play_jump].
const PATH_JUMP := "res://sounds/400 Sounds Pack/Retro/jump_short.wav"
const PATH_DIMENSION := "res://sounds/Fantasy UI SFX/Fantasy UI SFX/Fantasy/Fantasy_UI (59).wav"
const PATH_FOOTSTEP := "res://sounds/400 Sounds Pack/Footsteps/foley_footstep_concrete_2.wav"
const PATH_DEATH := "res://sounds/400 Sounds Pack/Combat and Gore/kick.wav"

var _audio_jump: AudioStreamPlayer
var _audio_dimension: AudioStreamPlayer
var _audio_platform: AudioStreamPlayer
var _audio_footstep: AudioStreamPlayer
var _audio_death: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_audio_jump = _make_player("SFXJump", PATH_JUMP, 1)
	_audio_dimension = _make_player("SFXDimension", PATH_DIMENSION, 2)
	_audio_footstep = _make_player("SFXFootstep", PATH_FOOTSTEP, 4)
	_audio_death = _make_player("SFXDeath", PATH_DEATH, 1)


func _make_player(node_name: String, path: String, max_poly: int) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = node_name
	p.max_polyphony = max_poly
	if ResourceLoader.exists(path):
		p.stream = load(path) as AudioStream
	else:
		push_warning("GameSfx: missing audio %s" % path)
	add_child(p)
	return p


func play_jump() -> void:
	if _audio_jump == null or _audio_jump.stream == null:
		return
	_audio_jump.stop()
	_audio_jump.play()


func play_dimension_change() -> void:
	_play(_audio_dimension)


func play_footstep() -> void:
	_play(_audio_footstep)


func play_death() -> void:
	_play(_audio_death)


func _play(p: AudioStreamPlayer) -> void:
	if p == null or p.stream == null:
		return
	p.play()
