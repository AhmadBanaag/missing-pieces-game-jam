extends Area2D

var player_in_range := false
var reading_letter := false

@onready var pickup_label: Label = $Label
@onready var letter_ui: TextureRect = $CanvasLayer/LetterUI
@onready var next_hint: Label = $CanvasLayer/NextHint


func _ready():

	pickup_label.modulate.a = 0.0

	letter_ui.visible = false
	next_hint.visible = false

	# Start smaller for zoom effect
	letter_ui.scale = Vector2(0.2, 0.2)
	


func _process(delta: float) -> void:

	# LABEL FADE
	if player_in_range and !reading_letter:

		pickup_label.modulate.a = lerp(
			pickup_label.modulate.a,
			1.0,
			5.0 * delta
		)

		if Input.is_action_just_pressed("interact"):
			open_letter()

	else:

		pickup_label.modulate.a = lerp(
			pickup_label.modulate.a,
			0.0,
			5.0 * delta
		)
		
	if reading_letter:

		if Input.is_action_just_pressed("interactioon"):

			next_level()


	# SECOND INTERACTION
	if reading_letter:

		if Input.is_action_just_pressed("interact"):
			next_level()


func _on_body_entered(body: Node2D) -> void:

	if body.name == "player":
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:

	if body.name == "player":
		player_in_range = false


func open_letter():

	reading_letter = true

	pickup_label.visible = false

	letter_ui.visible = true

	get_tree().paused = true

	# RESET SCALE
	letter_ui.scale = Vector2(0.2, 0.2)

	# ZOOM TWEEN
	var tween = create_tween()

	tween.tween_property(
		letter_ui,
		"scale",
		Vector2(1.0, 1.0),
		0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	next_hint.visible = true


func next_level():

	get_tree().paused = false

	get_tree().change_scene_to_file("res://NextLevel.tscn")
