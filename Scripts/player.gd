extends CharacterBody2D


@export var rotation_speed: float = PI
@export var thrust_acceleration: float = 100.0
@export var thrust_max: float = 150.0
@export var thrust_decay: float = 10.0
@export var fuel_max: float = 100.0

var fuel_consumption_rate: float = 0.01 * thrust_acceleration
var fuel: float


func _ready() -> void:
	fuel = fuel_max


func _physics_process(delta: float) -> void:

	## Calculate spin of the ship
	var rotation_direction = Input.get_axis("rotate_counterclockwise", "rotate_clockwise")
	rotation += delta * rotation_speed * rotation_direction

	if Input.is_action_pressed("break"):
		velocity = velocity.move_toward(Vector2.ZERO, thrust_acceleration * delta)
		fuel -= fuel_consumption_rate * delta
	elif Input.is_action_pressed("accelerate"):
		velocity += thrust_acceleration * delta * Vector2.DOWN.rotated(rotation)
		fuel -= fuel_consumption_rate * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, thrust_decay * delta)

	fuel = maxf(fuel, 0.0)

	## Make sure ship doesn't exceed its maximum speed
	velocity = velocity.limit_length(thrust_max)

	print(velocity.length())

	move_and_slide()
