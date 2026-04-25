extends CanvasLayer

@onready var speed_bar: ProgressBar = $SpeedGauge/SpeedBar
@onready var speed_label: Label = $SpeedGauge/SpeedLabel

var player: CharacterBody2D

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _process(_delta: float) -> void:
	if player:
		var speed := player.velocity.length()
		var max_speed: float = player.thrust_max
		speed_bar.value = (speed / max_speed) * 100.0
		speed_label.text = "SPD %d" % int(speed)
