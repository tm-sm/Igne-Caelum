extends CanvasLayer
class_name GameOverMenu


func _on_Restart_pressed():
	get_tree().reload_current_scene()
