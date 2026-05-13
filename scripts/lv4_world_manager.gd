extends Node

var in_reflection_world := false

var stability := 100.0
var max_stability := 100.0

var drain_rate := 20.0
var recover_rate := 10.0

var can_switch := true
var switch_cooldown := 5.0

var drain_enabled := true
var is_dead := false

var normal_world: Node2D
var reflection_world: Node2D
var camera: Node
var _worlds_ready := false


func _ready() -> void:
	normal_world = get_node_or_null("../NormalWorld") as Node2D
	reflection_world = get_node_or_null("../MirrorWorld") as Node2D
	camera = get_tree().get_first_node_in_group("camera")

	if normal_world == null or reflection_world == null:
		push_warning(
			"lv4_world_manager: ../NormalWorld or ../MirrorWorld not found (relative to %s); dimension switching disabled."
			% str(get_path())
		)
		return

	_worlds_ready = true

	normal_world.visible = true
	reflection_world.visible = false

	set_world_collision(normal_world, true)
	set_world_collision(reflection_world, false)


func trigger_break() -> void:
	get_tree().reload_current_scene()


func check_stability() -> void:
	if stability <= 0.0:
		trigger_break()


func _process(delta: float) -> void:
	if not _worlds_ready:
		return

	if in_reflection_world and drain_enabled:
		stability -= drain_rate * delta
	else:
		stability += recover_rate * delta

	stability = clampf(stability, 0.0, max_stability)

	check_stability()


func _input(event: InputEvent) -> void:
	if not _worlds_ready:
		return
	if event.is_action_pressed("change_dimension") and can_switch:
		switch_dimension()


func switch_dimension() -> void:
	if not _worlds_ready:
		return

	can_switch = false
	if camera and camera.has_method("apply_shake"):
		camera.apply_shake()

	var dim_transition := get_node_or_null("../CanvasLayer/DimensionTransition") as AnimationPlayer
	if dim_transition:
		dim_transition.play("dimension_transition")

	in_reflection_world = not in_reflection_world

	normal_world.visible = not in_reflection_world
	reflection_world.visible = in_reflection_world

	set_world_collision(normal_world, not in_reflection_world)
	set_world_collision(reflection_world, in_reflection_world)

	var anim := get_node_or_null("../CanvasLayer/AnimationPlayer") as AnimationPlayer
	var death_anim := get_node_or_null("../CanvasLayer/AnimationPlayer2") as AnimationPlayer

	drain_enabled = false
	if anim:
		anim.play("cooldown_start")

	await get_tree().create_timer(switch_cooldown).timeout

	if not is_instance_valid(self) or not _worlds_ready:
		return

	if anim:
		anim.play("cooldown_end")
	drain_enabled = true

	if death_anim:
		if in_reflection_world:
			death_anim.play("red_vignette_in")
		else:
			death_anim.play("red_vignette_out")

	can_switch = true


func set_world_collision(world_node: Node, enable: bool) -> void:
	if world_node == null:
		return

	for child in world_node.get_children():
		if child is StaticBody2D:
			for sub in child.get_children():
				if sub is CollisionShape2D:
					sub.set_deferred("disabled", not enable)
		elif child is Area2D:
			for sub in child.get_children():
				if sub is CollisionShape2D:
					sub.set_deferred("disabled", not enable)
