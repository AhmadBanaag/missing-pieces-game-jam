extends Node

var in_reflection_world = false

var stability = 100.0
var max_stability = 100.0

var drain_rate = 20.0      # per second in reflection world
var recover_rate = 10.0    # per second in normal world

var can_switch = true
var switch_cooldown = 5.0

var drain_enabled = true
var is_dead = false


@onready var normal_world = $"../NormalWorld"
@onready var reflection_world = $"../MirrorWorld"


func _ready():

	# START IN NORMAL WORLD
	normal_world.visible = true
	reflection_world.visible = false

	set_world_collision(normal_world, true)
	set_world_collision(reflection_world, false)

func trigger_break():

	get_tree().reload_current_scene()
	
func check_stability():

	if stability <= 0:
		trigger_break()
		
func _process(delta):

	if in_reflection_world and drain_enabled:
		stability -= drain_rate * delta
	else:
		stability += recover_rate * delta

	stability = clamp(stability, 0, max_stability)

	check_stability()


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
	
	var anim = $"../CanvasLayer/AnimationPlayer"
	var death_anim = $"../CanvasLayer/AnimationPlayer2"
	
	drain_enabled = false
	anim.play("cooldown_start")
	
	#Cooldown	
	await get_tree().create_timer(switch_cooldown).timeout
	anim.play("cooldown_end")
	drain_enabled = true
	
	if in_reflection_world:
		death_anim.play("red_vignette_in")
	else:
		death_anim.play("red_vignette_out")
	
	can_switch = true
	
	

func set_world_collision(world_node, enable):

	for child in world_node.get_children():

		# STATIC BODIES (platforms)
		if child is StaticBody2D:

			for sub in child.get_children():

				if sub is CollisionShape2D:
					sub.set_deferred("disabled", !enable)

		# AREA2D (spikes)
		elif child is Area2D:

			for sub in child.get_children():

				if sub is CollisionShape2D:
					sub.set_deferred("disabled", !enable)
