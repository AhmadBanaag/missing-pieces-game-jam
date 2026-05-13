extends Node

func _ready():
	print("Level ready, spawn_door_tag = ", NavigationManager.spawn_door_tag)
	if NavigationManager.spawn_door_tag != null:
		call_deferred("_on_level_spawn", NavigationManager.spawn_door_tag)

func _on_level_spawn(destination_tag: String):
	print("_on_level_spawn called with: ", destination_tag)
	var door_path = "Doors/Door1_" + destination_tag
	var door = get_node(door_path) as Door1
	if door == null:
		push_error("Door not found at path: " + door_path)
		return
	print("Door found, spawning player at: ", door.spawn.global_position)
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)
	NavigationManager.spawn_door_tag = null
