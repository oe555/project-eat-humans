class_name Planet
extends Area2D

var data: PlanetData

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

func setup(d: PlanetData) -> void:
	data = d
	position = d.position

	if _collision and _collision.shape is CircleShape2D:
		var shape := (_collision.shape as CircleShape2D).duplicate() as CircleShape2D
		shape.radius = d.radius
		_collision.shape = shape

	if _sprite and _sprite.texture:
		var tex_size := _sprite.texture.get_size()
		if tex_size.x > 0.0:
			_sprite.scale = Vector2.ONE * (d.radius * 2.0 / tex_size.x)
