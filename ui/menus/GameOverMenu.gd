extends CanvasLayer
class_name GameOverMenu


func _on_Restart_pressed():
	var current_scene = get_parent()
	global.load_scene(current_scene, current_scene.filename)
