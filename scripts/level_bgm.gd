extends Node

## Plays looping background music for this level. Set [code]music_path[/code] on the node in the scene.

@export var music_path: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var p := music_path.strip_edges()
	if p.is_empty():
		return
	if not ResourceLoader.exists(p):
		push_warning("LevelBGM: file not found: %s" % p)
		return
	var stream := load(p) as AudioStream
	if stream == null:
		push_warning("LevelBGM: could not load: %s" % p)
		return
	_set_loop(stream)
	var player := AudioStreamPlayer.new()
	player.name = "LevelBGMPlayer"
	player.stream = stream
	player.bus = "Master"
	add_child(player)
	player.play()


func _set_loop(stream: AudioStream) -> void:
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
