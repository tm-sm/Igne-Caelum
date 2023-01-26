extends CanvasLayer
class_name PauseMenu


func _on_Resume_pressed():
	get_tree().paused = false
	queue_free()

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()