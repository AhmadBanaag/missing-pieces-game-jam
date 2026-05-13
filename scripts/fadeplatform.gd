extends StaticBody2D

@onready var time: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.4)
	collision_shape_2d.position = Vector2(-10000, 20000)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		time.start()
	
