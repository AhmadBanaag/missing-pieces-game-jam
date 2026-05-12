extends Node

var in_reflection_world = false
var can_switch = true
var switch_cooldown = 5.0


@onready var normal_world = $"../NormalWorld"
@onready var reflection_world = $"../MirrorWorld"


func _ready():

	# START IN NORMAL WORLD
	normal_world.visible = true
	reflection_world.visible = false

	set_world_collision(normal_world, true)
	set_world_collision(reflection_world, false)


func _input(event):

	if event.is_action_pressed("change_dimension") and can_switch:
		switch_dimension()


func switch_dimension():
	#For Timer
	can_switch = false
	#Shaking of Camera
	$"../CameraLv_4".apply_shake()
	#For playing transition
	$"../CanvasLayer/DimensionTransition".play("dimension_transition")

	in_reflection_world = !in_reflection_world

	normal_world.visible = !in_reflection_world
	reflection_world.visible = in_reflection_world

	set_world_collision(normal_world, !in_reflection_world)
	set_world_collision(reflection_world, in_reflection_world)
	
	#Cooldown	
	await get_tree().create_timer(switch_cooldown).timeout

	can_switch = true


func set_world_collision(world_node, enable):

	for body in world_node.get_children():

		if body is StaticBody2D:

			for child in body.get_children():

				if child is CollisionShape2D:
					child.set_deferred("disabled", !enable)
