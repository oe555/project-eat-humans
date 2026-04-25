extends CharacterBody2D


@export var rotation_speed: float = PI
@export var thrust_acceleration: float = 100.0
@export var thrust_max: float = 150.0
@export var thrust_decay: float = 10.0

@onready var speed_lines: Node = $SpeedLines


func _physics_process(delta: float) -> void:

	## Calculate spin of the ship
	var rotation_direction = Input.get_axis("rotate_counterclockwise", "rotate_clockwise")
	rotation += delta * rotation_speed * rotation_direction

	if Input.is_action_pressed("break"):
		velocity = velocity.move_toward(Vector2.ZERO, thrust_acceleration * delta)
	elif Input.is_action_pressed("accelerate"):
		velocity += thrust_acceleration * delta * Vector2.DOWN.rotated(rotation)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, thrust_decay * delta)

	## Make sure ship doesn't exceed its maximum speed
	velocity = velocity.limit_length(thrust_max)

	if speed_lines and speed_lines.has_method("update_motion"):
		speed_lines.update_motion(
			velocity,
			thrust_max,
			rotation_direction,
			Input.is_action_pressed("accelerate"),
			Input.is_action_pressed("break")
		)

	move_and_slide()
