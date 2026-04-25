extends Node

# This is a Singleton (Autoload) script that acts as a central hub for all signals in the game.

@warning_ignore("unused_signal")
signal example_signal(value: int)

@warning_ignore("unused_signal")
signal world_generation_requested(rect: Rect2, count: int, parent: Node)
@warning_ignore("unused_signal")
signal planet_spawned(planet: Node2D, data: Resource)
@warning_ignore("unused_signal")
signal world_generated(planets: Array)
@warning_ignore("unused_signal")
signal planets_cleared
@warning_ignore("unused_signal")
signal days_passed_changed(value: int)
@warning_ignore("unused_signal")
signal gold_changed(value: int)
@warning_ignore("unused_signal")
signal home_planet_humans_changed(value: int)
