extends CharacterBody2D


@export var rotation_speed: float = PI
@export var thrust_speed: float = 100.0


func _physics_process(delta: float) -> void:

	var rotation_direction = Input.get_axis("rotate_counterclockwise", "rotate_clockwise")
	rotation += delta * rotation_speed * rotation_direction

	var thrust = Input.get_axis("reverse", "accelerate")
	velocity = thrust * thrust_speed * Vector2.DOWN.rotated(rotation)

	move_and_slide()
