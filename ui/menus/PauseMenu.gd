extends CanvasLayer
class_name PauseMenu


func _on_Resume_pressed():
	get_tree().paused = false
	queue_free()

func _on_Restart_pressed():
	var current_scene = get_parent()
	global.load_scene(current_scene, current_scene.filename)


func _on_Quit_pressed():
	get_tree().paused = false
	global.load_scene(self, "res://ui/menus/StartMenu.tscn")
