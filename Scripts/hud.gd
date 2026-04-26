extends CanvasLayer

@onready var speed_bar: ProgressBar = $Gauges/SpeedGauge/SpeedBar
@onready var speed_label: Label = $Gauges/SpeedGauge/SpeedLabel
@onready var fuel_bar: ProgressBar = $Gauges/FuelGauge/FuelBar
@onready var fuel_label: Label = $Gauges/FuelGauge/FuelLabel
@onready var humans_label: Label = $Gauges/HumansLabel
@onready var gold_label: Label = $Gauges/GoldLabel

var player: CharacterBody2D

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _process(_delta: float) -> void:
	if player:
		var speed := player.velocity.length()
		speed_bar.value = (speed / player.thrust_max) * 100.0
		speed_label.text = "SPD %d" % int(speed)

		fuel_bar.value = (player.fuel / player.fuel_max) * 100.0
		fuel_label.text = "FUEL %.1f" % player.fuel

		humans_label.text = "HUMANS %d/%d" % [player.humans, player.human_capacity]
		gold_label.text = "GOLD %d" % GameState.gold
