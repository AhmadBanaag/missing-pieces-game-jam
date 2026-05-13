extends Node2D

@onready var black_screen: ColorRect = $CanvasLayer/ColorRect
@onready var ending_label: Label = $CanvasLayer/Label

func _ready():

	start_outro()


func start_outro():

	# INITIAL STATE
	black_screen.modulate.a = 0.0
	ending_label.modulate.a = 0.0

	ending_label.visible = true

	# STEP 1: FADE TO BLACK
	var fade_black = create_tween()
	fade_black.tween_property(
		black_screen,
		"modulate:a",
		1.0,
		2.0
	)

	await fade_black.finished

	# STEP 2: SHOW TEXT
	await get_tree().create_timer(1.0).timeout

	var text_fade = create_tween()
	text_fade.tween_property(
		ending_label,
		"modulate:a",
		1.0,
		3.0
	).set_trans(Tween.TRANS_SINE)

	await text_fade.finished

	# STEP 3: HOLD TEXT
	await get_tree().create_timer(4.0).timeout

	# STEP 4 (OPTIONAL): FADE OUT TEXT
	var fade_out_text = create_tween()
	fade_out_text.tween_property(
		ending_label,
		"modulate:a",
		0.0,
		2.0
	)

	await fade_out_text.finished

	# STEP 5: GO TO CREDITS
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
