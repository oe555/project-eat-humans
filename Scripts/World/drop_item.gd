class_name DropItem
extends Area2D

enum Type {GOLD, HUMAN}

var item_type: Type
var drift_velocity: Vector2

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += drift_velocity * delta
	drift_velocity = drift_velocity.move_toward(Vector2.ZERO, 20.0 * delta)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if item_type == Type.GOLD:
		GameState.gold += 10
		SignalBus.gold_changed.emit(GameState.gold)
	elif item_type == Type.HUMAN:
		if body.humans >= body.human_capacity:
			return
		body.humans += 1
	queue_free()
