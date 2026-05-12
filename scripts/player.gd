extends CharacterBody2D

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -550.0
const GRAVITY = 1200.0

const JUMP_CUT = 0.5


func _physics_process(delta: float) -> void:

	# GRAVITY
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		_sprite.animation = "jump"


	# JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# VARIABLE JUMP
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT


	# MOVEMENT
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor():
		# ANIMATION
		if direction != 0:
			_sprite.animation = "run"
		else:
			_sprite.animation = "idle"
			
	else:
		_sprite.animation = "jump"
		
	


	# FLIP
	if direction > 0:
		_sprite.flip_h = false
	elif direction < 0:
		_sprite.flip_h = true


	move_and_slide()
