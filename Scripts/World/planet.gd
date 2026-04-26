class_name Planet
extends Area2D

var data: PlanetData

#@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

func setup(d: PlanetData) -> void:
	data = d
	position = d.position

	if _collision and _collision.shape is CircleShape2D:
		var shape := (_collision.shape as CircleShape2D).duplicate() as CircleShape2D
		if d.planet_type == 1:
			shape.radius = 40
		if d.planet_type == 2:
			shape.radius = 35
		if d.planet_type == 3:
			shape.radius = 50
		_collision.shape = shape

	# if _sprite and _sprite.texture:
	# 	var tex_size := _sprite.texture.get_size()
	# 	if tex_size.x > 0.0:
	# 		var radius: float = 0.0
	# 		if d.planet_type == 1:
	# 			radius = 40.0
	# 		if d.planet_type == 2:
	# 			radius = 35.0
	# 		if d.planet_type == 3:
	# 			radius = 50.0
	# 		#_sprite.scale = Vector2.ONE * (radius * 2.0 / tex_size.x)
