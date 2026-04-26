extends CharacterBody2D


@export var rotation_speed: float = PI
@export var thrust_acceleration: float = 100.0
@export var thrust_max: float = 200.0
@export var thrust_decay: float = 10.0
@export var fuel_max: float = 100.0

var fuel_consumption_rate: float = 0.01 * thrust_acceleration
var fuel: float

@export var human_capacity: int = 10
var humans: int = 0


func _ready() -> void:
	fuel = fuel_max
	SignalBus.upgrade_purchased.connect(_on_upgrade_purchased)


func _on_upgrade_purchased(category: int, tier: int) -> void:
	var value := ShopManager.get_upgrade_value(category, tier)
	match category:
		Enums.UpgradeCategory.SHIP_SPEED:
			thrust_max += value
		Enums.UpgradeCategory.FUEL_CAPACITY:
			fuel_max += value
		Enums.UpgradeCategory.CARGO_CAPACITY:
			human_capacity += value

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
		fuel -= fuel_consumption_rate * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, thrust_decay * delta)

	_update_thruster(main_thruster, is_accelerating)
	_update_thruster(brake_thruster, is_braking)
	_update_thruster(left_thruster, is_rotating_clockwise)
	_update_thruster(right_thruster, is_rotating_counterclockwise)
	fuel = maxf(fuel, 0.0)

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
	_handle_planet_collisions()


func _handle_planet_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is Planet:
			var planet := collider as Planet
			var impact_velocity := collision.get_travel() + collision.get_remainder()
			# Apply impulse to planet proportional to ship speed
			var impulse := velocity * (1.0 / planet.mass) * 50.0
			planet.apply_central_impulse(impulse)
			# Decelerate ship — lose speed proportional to planet mass ratio
			var speed_loss := clampf(planet.mass / (planet.mass + 10.0), 0.3, 0.8)
			velocity *= (1.0 - speed_loss)


func _update_thruster(thruster: AnimatedSprite2D, is_active: bool) -> void:
	thruster.visible = is_active

	if is_active:
		if not thruster.is_playing():
			thruster.play()
	else:
		thruster.stop()
