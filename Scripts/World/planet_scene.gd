extends Node2D

const PLANET_COUNT: int = 10

func _ready() -> void:
	var view_rect := Rect2(Vector2.ZERO, get_viewport_rect().size)
	SignalBus.world_generation_requested.emit(view_rect, PLANET_COUNT, self )
