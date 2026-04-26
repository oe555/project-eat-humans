extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.days_passed += 1
		SignalBus.home_planet_reached.emit()
		var delivered = body.humans
		if delivered > 0:
			body.humans = 0
			GameState.humans_on_home_planet += delivered
			#GameState.human_burndown_rate += delivered * 0.1
