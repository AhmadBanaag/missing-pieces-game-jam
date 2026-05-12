extends Node

var in_reflection_world = false

@onready var normal_world = $"../NormalWorld"
@onready var reflection_world = $"../MirrorWorld"


func _ready():

	# START IN NORMAL WORLD
	normal_world.visible = true
	reflection_world.visible = false

	set_world_collision(normal_world, true)
	set_world_collision(reflection_world, false)


func _input(event):

	if event.is_action_pressed("change_dimension"):
		switch_dimension()


func switch_dimension():

	in_reflection_world = !in_reflection_world

	normal_world.visible = !in_reflection_world
	reflection_world.visible = in_reflection_world

	set_world_collision(normal_world, !in_reflection_world)
	set_world_collision(reflection_world, in_reflection_world)


func set_world_collision(world_node, enable):

	for body in world_node.get_children():

		if body is StaticBody2D:

			for child in body.get_children():

				if child is CollisionShape2D:
					child.set_deferred("disabled", !enable)
