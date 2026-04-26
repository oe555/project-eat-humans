class_name Planet
extends RigidBody2D

var data: PlanetData

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

func setup(d: PlanetData) -> void:
	data = d
	position = d.position

	var radius: float = 0.0
	if d.planet_type == 1:
		radius = 20.0
	if d.planet_type == 2:
		radius = 17.5
	if d.planet_type == 3:
		radius = 25.0

	# Heavier planets are harder to push
	mass = radius * 0.5
	gravity_scale = 0.0
	linear_damp = 1.5

	if _collision and _collision.shape is CircleShape2D:
		var shape := (_collision.shape as CircleShape2D).duplicate() as CircleShape2D
		shape.radius = radius
		_collision.shape = shape
