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
	engine_start.finished.connect(_on_engine_start_finished)
	var firing_stream := engine_firing.stream as AudioStreamWAV
	firing_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	firing_stream.loop_end = firing_stream.data.size()

	aux_start.finished.connect(_on_aux_start_finished)
	var aux_firing_stream := aux_firing.stream as AudioStreamWAV
	aux_firing_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	aux_firing_stream.loop_end = aux_firing_stream.data.size()


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

@onready var engine_start: AudioStreamPlayer = $EngineSFX/EngineStart
@onready var engine_firing: AudioStreamPlayer = $EngineSFX/EngineFiring
@onready var engine_stop: AudioStreamPlayer = $EngineSFX/EngineStop
@onready var aux_start: AudioStreamPlayer = $EngineSFX/AuxStart
@onready var aux_firing: AudioStreamPlayer = $EngineSFX/AuxFiring
@onready var aux_stop: AudioStreamPlayer = $EngineSFX/AuxStop

var _engine_active: bool = false
var _aux_active: bool = false


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
	_update_engine_sfx(is_accelerating)
	var is_aux_active := is_braking or is_rotating_clockwise or is_rotating_counterclockwise
	_update_aux_sfx(is_aux_active)
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
			var impact_speed := velocity.length()
			# Apply impulse to planet proportional to ship speed
			var impulse := velocity * (1.0 / planet.mass) * 50.0
			planet.apply_central_impulse(impulse)
			# Drop items based on impact speed
			planet.drop_items(impact_speed)
			# Decelerate ship — lose speed proportional to planet mass ratio
			var speed_loss := clampf(planet.mass / (planet.mass + 10.0), 0.3, 0.8)
			velocity *= (1.0 - speed_loss)


func _update_engine_sfx(is_accelerating: bool) -> void:
	if is_accelerating and not _engine_active:
		_engine_active = true
		engine_stop.stop()
		engine_firing.stop()
		engine_start.play()
	elif not is_accelerating and _engine_active:
		_engine_active = false
		engine_start.stop()
		engine_firing.stop()
		engine_stop.play()



func _update_aux_sfx(is_active: bool) -> void:
	if is_active and not _aux_active:
		_aux_active = true
		aux_stop.stop()
		aux_firing.stop()
		aux_start.play()
	elif not is_active and _aux_active:
		_aux_active = false
		aux_start.stop()
		aux_firing.stop()
		aux_stop.play()


func _on_engine_start_finished() -> void:
	if _engine_active:
		engine_firing.play()


func _on_aux_start_finished() -> void:
	if _aux_active:
		aux_firing.play()


func _update_thruster(thruster: AnimatedSprite2D, is_active: bool) -> void:
	thruster.visible = is_active

	if is_active:
		if not thruster.is_playing():
			thruster.play()
	else:
		thruster.stop()
