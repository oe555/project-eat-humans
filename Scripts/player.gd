extends CharacterBody2D


@export var rotation_speed: float = PI
@export var thrust_acceleration: float = 100.0
@export var thrust_max: float = 200.0
@export var thrust_decay: float = 10.0

@onready var speed_lines: Node = $SpeedLines
@onready var main_thruster: AnimatedSprite2D = $Thrusters/MainThruster
@onready var brake_thruster: AnimatedSprite2D = $Thrusters/BrakeThruster
@onready var left_thruster: AnimatedSprite2D = $Thrusters/LeftThruster
@onready var right_thruster: AnimatedSprite2D = $Thrusters/RightThruster


func _physics_process(delta: float) -> void:

	## Calculate spin of the ship
	var rotation_direction = Input.get_axis("rotate_counterclockwise", "rotate_clockwise")
	var is_accelerating = Input.is_action_pressed("accelerate")
	var is_braking = Input.is_action_pressed("break")
	var is_rotating_counterclockwise = Input.is_action_pressed("rotate_counterclockwise")
	var is_rotating_clockwise = Input.is_action_pressed("rotate_clockwise")

	rotation += delta * rotation_speed * rotation_direction

	if is_braking:
		velocity = velocity.move_toward(Vector2.ZERO, thrust_acceleration * delta)
	elif is_accelerating:
		velocity += thrust_acceleration * delta * Vector2.DOWN.rotated(rotation)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, thrust_decay * delta)

	_update_thruster(main_thruster, is_accelerating)
	_update_thruster(brake_thruster, is_braking)
	_update_thruster(left_thruster, is_rotating_clockwise)
	_update_thruster(right_thruster, is_rotating_counterclockwise)

	## Make sure ship doesn't exceed its maximum speed
	velocity = velocity.limit_length(thrust_max)

	if speed_lines and speed_lines.has_method("update_motion"):
		speed_lines.update_motion(
			velocity,
			thrust_max,
			rotation_direction,
			is_accelerating,
			is_braking
		)

	move_and_slide()


func _update_thruster(thruster: AnimatedSprite2D, is_active: bool) -> void:
	thruster.visible = is_active

	if is_active:
		if not thruster.is_playing():
			thruster.play()
	else:
		thruster.stop()
