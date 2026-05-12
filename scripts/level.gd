extends Node

func _ready():
	if NavigationManager.spawn_door_tag != null:
		call_deferred("_on_level_spawn", NavigationManager.spawn_door_tag)

func _on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door1_" + destination_tag
	var door = get_node(door_path) as Door1
	if door == null:
		push_error("Door not found at path: " + door_path)
		return
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)
