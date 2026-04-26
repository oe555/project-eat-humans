extends Node

var days_passed: int = 0
var gold: int = 100
var humans_on_home_planet: int = 0
var human_burndown_rate: float = 0.0

func _process(delta: float) -> void:
	if humans_on_home_planet > 0 and human_burndown_rate > 0.0:
		humans_on_home_planet = max(0, humans_on_home_planet - int(human_burndown_rate * delta))
		SignalBus.home_planet_humans_changed.emit(humans_on_home_planet)
