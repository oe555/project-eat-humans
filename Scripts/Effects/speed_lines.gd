extends Node2D

class SpeedLine:
	var position: Vector2
	var age: float = 0.0
	var lifetime: float
	var length: float
	var curve: float
	var drift: float
	var alpha_scale: float

	func _init(
		line_position: Vector2,
		line_lifetime: float,
		line_length: float,
		line_curve: float,
		line_drift: float,
		line_alpha_scale: float
	) -> void:
		position = line_position
		lifetime = line_lifetime
		length = line_length
		curve = line_curve
		drift = line_drift
		alpha_scale = line_alpha_scale

@export_range(0.0, 1.0, 0.01) var min_speed_ratio: float = 0.2
@export var max_spawn_rate: float = 34.0
@export var line_lifetime: float = 1.0
@export var trail_radius: float = 20.0
@export var line_min_length: float = 5.0
@export var line_max_length: float = 15.0
@export var curve_strength: float = 60.0
@export var drift_speed: float = 34.0
@export var line_width: float = 1.0
@export var line_color: Color = Color(0.72, 0.96, 1.0, 0.82)

var _speed_ratio: float = 0.0
var _turn_direction: float = 0.0
var _is_accelerating: bool = false
var _is_braking: bool = false
var _spawn_accumulator: float = 0.0
var _lines: Array[SpeedLine] = []


func update_motion(
	ship_velocity: Vector2,
	max_speed: float,
	turn_direction: float,
	is_accelerating: bool,
	is_braking: bool
) -> void:
	_speed_ratio = 0.0 if max_speed <= 0.0 else _calc_speed_ratio(ship_velocity, max_speed)
	_turn_direction = turn_direction
	_is_accelerating = is_accelerating
	_is_braking = is_braking


func _process(delta: float) -> void:
	_spawn_lines(delta)
	_update_lines(delta)
	queue_redraw()


func _draw() -> void:
	for line in _lines:
		var progress: float = line.age / line.lifetime
		var alpha: float = line_color.a * (1.0 - progress) * line.alpha_scale
		var color := Color(line_color.r, line_color.g, line_color.b, alpha)
		var points := _get_line_points(line, progress)

		for i in range(points.size() - 1):
			draw_line(points[i], points[i + 1], color, line_width)


func _calc_speed_ratio(ship_velocity: Vector2, max_speed: float) -> float:
	return clampf(ship_velocity.length() / max_speed, 0.0, 1.0)


func _spawn_lines(delta: float) -> void:
	# Do not draw motion lines while the ship is barely moving.
	if _speed_ratio < min_speed_ratio:
		return

	# Spawn frequency follows speed, with extra emphasis while thrusting.
	var thrust_boost := 1.25 if _is_accelerating else 0.7
	var brake_drag := 0.45 if _is_braking else 1.0
	var spawn_rate := max_spawn_rate * _speed_ratio * thrust_boost * brake_drag
	_spawn_accumulator += spawn_rate * delta

	while _spawn_accumulator >= 1.0:
		_spawn_accumulator -= 1.0
		_lines.append(_make_line())


func _update_lines(delta: float) -> void:
	for i in range(_lines.size() - 1, -1, -1):
		var line := _lines[i]
		line.age += delta
		line.position += Vector2.UP * line.drift * delta
		line.position.x += line.curve * delta * 0.35

		if line.age >= line.lifetime:
			_lines.remove_at(i)


func _make_line() -> SpeedLine:
	var side_offset := randf_range(-trail_radius * 0.55, trail_radius * 0.55)
	var distance := randf_range(8.0, trail_radius)
	var speed_range: float = maxf(1.0 - min_speed_ratio, 0.001)
	var speed_scale := clampf((_speed_ratio - min_speed_ratio) / speed_range, 0.0, 1.0)

	return SpeedLine.new(
		Vector2(side_offset, -distance),
		line_lifetime * randf_range(0.75, 1.2),
		lerpf(line_min_length, line_max_length, speed_scale) * randf_range(0.75, 1.2),
		-_turn_direction * curve_strength * randf_range(0.5, 1.0),
		drift_speed * lerpf(0.7, 1.35, _speed_ratio),
		randf_range(0.55, 1.0)
	)


func _get_line_points(line: SpeedLine, progress: float) -> Array[Vector2]:
	var base: Vector2 = line.position
	var length: float = line.length
	var curve: float = line.curve * progress

	# Four short segments approximate a curved speed streak.
	return [
		base + Vector2(0.0, 0.0),
		base + Vector2(curve * 0.18, -length * 0.35),
		base + Vector2(curve * 0.55, -length * 0.7),
		base + Vector2(curve, -length),
	]
