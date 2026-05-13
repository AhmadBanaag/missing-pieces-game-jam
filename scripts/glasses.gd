extends Area2D

var player_in_range: bool = false

@onready var pickup_label: Label = $PickupLabel

func _ready():
	# Start fully transparent
	pickup_label.modulate.a = 0.0

func _process(delta: float) -> void:
	if player_in_range:
		# Fade in
		pickup_label.modulate.a = lerp(pickup_label.modulate.a, 1.0, 5.0 * delta)
		if Input.is_action_just_pressed("interact"):
			_pick_up()
	else:
		# Fade out
		pickup_label.modulate.a = lerp(pickup_label.modulate.a, 0.0, 5.0 * delta)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false

func _pick_up():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.pick_up_glasses()
	queue_free()
