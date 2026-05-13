extends CharacterBody2D

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -550.0
const GRAVITY = 1200.0

const JUMP_CUT = 0.5
const FOOTSTEP_INTERVAL := 0.34
const FOOTSTEP_AFTER_JUMP := 0.45

var _footstep_cooldown := 0.0
var _footstep_block := 0.0


func _physics_process(delta: float) -> void:
	_footstep_block = maxf(0.0, _footstep_block - delta)

	# GRAVITY
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		_sprite.animation = "jump"


	# JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		GameSfx.play_jump()
		_footstep_block = FOOTSTEP_AFTER_JUMP


	# VARIABLE JUMP
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT


	# MOVEMENT
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor() and absf(velocity.x) > 12.0 and _footstep_block <= 0.0:
		_footstep_cooldown -= delta
		if _footstep_cooldown <= 0.0:
			GameSfx.play_footstep()
			_footstep_cooldown = FOOTSTEP_INTERVAL
	else:
		_footstep_cooldown = 0.0

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
