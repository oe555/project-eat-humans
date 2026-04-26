extends Node

var days_passed: int = 0
var gold: int = 100
var humans_on_home_planet: int = 50
var human_burndown_rate: float = 0.0

var _burndown_accumulator: float = 0.0

func _process(delta: float) -> void:
	if humans_on_home_planet > 0:
		_burndown_accumulator += delta
		var tick_interval = 1.0 / maxf(1.0 + human_burndown_rate, 1.0)
		while _burndown_accumulator >= tick_interval and humans_on_home_planet > 0:
			_burndown_accumulator -= tick_interval
			humans_on_home_planet -= 1
			SignalBus.home_planet_humans_changed.emit(humans_on_home_planet)
