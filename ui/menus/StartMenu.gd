extends CanvasLayer

var ambush_scene = "res://levels/Ambush.tscn"

func _on_Start_pressed():
	global.load_scene(self, ambush_scene)

func _on_Options_pressed():
	pass # Replace with function body.

func _on_Exit_pressed():
	get_tree().quit()
