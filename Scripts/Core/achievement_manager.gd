extends Node

# Dictionary of achievements and their unlock status.
var achievements: Dictionary = {
	"ACH_EXAMPLE": false
}

func _ready() -> void:
	pass

# Unlocks an achievement by ID and syncs with Steam if available.
# TODO: FIX THIS IF NEEDED; MUST TRY TO UNDERSTAND HOW TO USE STEAM PROPERLY
func unlock_achievement(ach_id: String) -> void:
	if not achievements.has(ach_id):
		push_warning("Achievement not found: " + ach_id)
		return
		
	if achievements[ach_id]:
		return # Already unlocked
		
	achievements[ach_id] = true
	print("Achievement Unlocked: ", ach_id)
	
	if Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		if steam.has_method("setAchievement"):
			steam.setAchievement(ach_id)
			steam.storeStats()

# Checks if an achievement is unlocked.
func has_achievement(ach_id: String) -> bool:
	return achievements.get(ach_id, false)
