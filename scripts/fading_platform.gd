extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var activated = false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if activated:
		return

	if body.name == "player":
		activated = true
		start_fade()
		
func start_fade():

	# small delay before fading
	await get_tree().create_timer(0.3).timeout

	var tween = get_tree().create_tween()

	# fade sprite
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)

	# wait until fade finishes
	await tween.finished

	# disable collision so player falls
	collision.disabled = true
