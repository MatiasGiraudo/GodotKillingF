extends Button

@export var scene_to_load: PackedScene

func _on_button_up():
	if scene_to_load:
		get_tree().change_scene_to_packed(scene_to_load)
	else:
		get_tree().quit()
