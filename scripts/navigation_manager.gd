extends Node

const scene_level_0 = preload("res://scenes/level_0.tscn")
const scene_level_1 = preload("res://scenes/level_1.tscn")
const scene_level_2 = preload("res://scenes/level_2.tscn")

signal on_trigger_player_spawn

var spawn_door_tag = null

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"level_0":
			scene_to_load = scene_level_0
		"level_1":
			scene_to_load = scene_level_1
		"level_2":
			scene_to_load = scene_level_2
	
	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().call_deferred("change_scene_to_packed", scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
