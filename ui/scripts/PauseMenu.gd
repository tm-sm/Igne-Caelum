extends CanvasLayer
class_name PauseMenu

onready var current_scene = get_parent()

func _on_Resume_pressed():
	get_tree().paused = false
	queue_free()

func _on_Restart_pressed():
	get_tree().paused = false
	global.load_scene(current_scene, current_scene.filename)
	queue_free()


func _on_Quit_pressed():
	get_tree().paused = false
	global.load_scene(current_scene, "res://ui/menus/StartMenu.tscn")
	queue_free()


func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = false
		queue_free()
