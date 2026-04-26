extends Node

const PLANET_SCENE: PackedScene = preload("res://Scenes/planet.tscn")

const MIN_RADIUS: float = 12.0
const MAX_RADIUS: float = 32.0
const PLACEMENT_BUFFER: float = 12.0
const MAX_PLACEMENT_ATTEMPTS: int = 30

var planets: Array[PlanetData] = []
var _spawned: Array[Node] = []

func _ready() -> void:
	SignalBus.world_generation_requested.connect(_on_world_generation_requested)

func _on_world_generation_requested(rect: Rect2, count: int, parent: Node) -> void:
	generate_planets(rect, count, parent)

func generate_planets(rect: Rect2, count: int, parent: Node) -> void:
	clear_planets()
	var actual_parent: Node = parent if parent != null else get_tree().current_scene
	if actual_parent == null:
		push_error("PlanetManager: no parent provided and no current scene")
		return

	for i in count:
		var data := _try_place_one(rect)
		if data == null:
			push_warning("PlanetManager: could not place planet %d after %d attempts" % [i, MAX_PLACEMENT_ATTEMPTS])
			continue
		planets.append(data)
		var node := PLANET_SCENE.instantiate() as Planet
		if data.planet_type == 1:
			node.get_child(0).texture = preload("res://Assets/Art/Planets/planet_1.png")
		if data.planet_type == 2:
			node.get_child(0).texture = preload("res://Assets/Art/Planets/planet_2.png")
		if data.planet_type == 3:
			node.get_child(0).texture = preload("res://Assets/Art/Planets/planet_3.png")
		actual_parent.add_child(node)
		node.setup(data)
		_spawned.append(node)
		SignalBus.planet_spawned.emit(node, data)

	SignalBus.world_generated.emit(planets)

func clear_planets() -> void:
	for n in _spawned:
		if is_instance_valid(n):
			n.queue_free()
	_spawned.clear()
	planets.clear()
	SignalBus.planets_cleared.emit()

func _try_place_one(rect: Rect2) -> PlanetData:
	for attempt in MAX_PLACEMENT_ATTEMPTS:
		var planet_type := Randomizer.rnd.randi_range(1, 3)
		var radius := 0.0
		if planet_type == 1:
			radius = 40.0
		if planet_type == 2:
			radius = 35.0
		if planet_type == 3:
			radius = 50.0
		var pos := Vector2(
			Randomizer.rnd.randf_range(rect.position.x + radius, rect.end.x - radius),
			Randomizer.rnd.randf_range(rect.position.y + radius, rect.end.y - radius)
		)
		if not _overlaps(pos, planet_type):
			var data := PlanetData.new()
			data.position = pos
			data.planet_type = planet_type
			return data
	return null

func _overlaps(pos: Vector2, planet_type: int) -> bool:
	var radius := 0.0
	if planet_type == 1:
		radius = 40.0
	if planet_type == 2:
		radius = 35.0
	if planet_type == 3:
		radius = 50.0
	for existing in planets:
		var existing_radius := 0.0
		if existing.planet_type == 1:
			existing_radius = 40.0
		if existing.planet_type == 2:
			existing_radius = 35.0
		if existing.planet_type == 3:
			existing_radius = 50.0
		var min_dist := existing_radius + radius + PLACEMENT_BUFFER
		if existing.position.distance_to(pos) < min_dist:
			return true
	return false
