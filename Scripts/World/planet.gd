class_name Planet
extends RigidBody2D

const DROP_SCENE: PackedScene = preload("res://Scenes/drop_item.tscn")

const GOLD_TEXTURE: Texture2D = preload("res://Assets/Art/Resources/resource_gold.png")
const HUMAN_TEXTURES: Array[Texture2D] = [
	preload("res://Assets/Art/Resources/resource_human_1.png"),
	preload("res://Assets/Art/Resources/resource_human_2.png"),
	preload("res://Assets/Art/Resources/resource_human_3.png"),
	preload("res://Assets/Art/Resources/resource_human_4.png"),
]

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

	(_collision.shape as CircleShape2D).radius = radius

	# if _collision and _collision.shape is CircleShape2D:
	# 	var shape := (_collision.shape as CircleShape2D).duplicate() as CircleShape2D
	# 	shape.radius = radius
	# 	_collision.shape = shape

func drop_items(impact_speed: float) -> void:
	if data.harvested:
		return

	var drop_count := int(impact_speed / 25.0)
	if drop_count <= 0:
		return

	data.harvested = true
	_sprite.modulate = Color(0.55, 0.55, 0.55, 1.0)

	var gold_chance: float = 0.0
	match data.planet_type:
		1:
			gold_chance = 0.25
		2:
			gold_chance = 0.0
		3:
			gold_chance = 0.10

	for i in drop_count:
		var is_gold := randf() < gold_chance
		var item := DROP_SCENE.instantiate() as DropItem

		if is_gold:
			item.item_type = DropItem.Type.GOLD
			item.get_node("Sprite2D").texture = GOLD_TEXTURE
		else:
			item.item_type = DropItem.Type.HUMAN
			item.get_node("Sprite2D").texture = HUMAN_TEXTURES[randi() % HUMAN_TEXTURES.size()]

		item.global_position = global_position
		# Scatter items outward in random directions
		var angle := randf() * TAU
		var scatter_dist := randf_range(10.0, 30.0)
		item.global_position += Vector2.from_angle(angle) * scatter_dist
		item.drift_velocity = Vector2.from_angle(angle) * randf_range(30.0, 80.0)

		get_tree().current_scene.add_child(item)

func reset_harvest_state() -> void:
	data.harvested = false
	_sprite.modulate = Color.WHITE
