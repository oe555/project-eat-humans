extends Node

var rnd: RandomNumberGenerator

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
# Sets the seed for the random number generator
# Note that this automatically resets the state, so you don't need to do anything else after this
func set_seed(seed_string: String):
	rnd.seed = seed_string.hash()

# Returns a random integer between 0 and 99 inclusive
func get_random_value():
	return rnd.randi_range(0, 99)
