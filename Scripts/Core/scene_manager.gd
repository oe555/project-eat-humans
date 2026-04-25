extends Node

# Switches to the given scene immediately.
# scene_path: The resource path to the new scene (e.g. "res://Scenes/Level1.tscn")
func change_scene(scene_path: String) -> void:
    var result = get_tree().change_scene_to_file(scene_path)
    if result != OK:
        push_error("Failed to change scene to: " + scene_path + " (Error Code: " + str(result) + ")")