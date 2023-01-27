extends Node
class_name SceneLoader

onready var loading_screen = preload("res://ui/menus/LoadingScreen.tscn")

func load_scene(current_scene, next_scene):
	
	var loading_screen_ins = loading_screen.instance()
	get_tree().get_root().call_deferred("add_child", loading_screen_ins)
	
	var loader = ResourceLoader.load_interactive(next_scene)
	
	if loader == null:
		print("Error occured while getting scene")
		return
	
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	while true:
		var error = loader.poll()
		
		if error == OK:
			#data was loaded correctly
			var progress_bar = loading_screen_ins.get_node("PanelContainer/VBoxContainer/ProgressBar")
			progress_bar.value = float(loader.get_stage()) / loader.get_stage_count() * 100
		
		elif error == ERR_FILE_EOF:
			#scene finished loading
			print("loading finished")
			var scene = loader.get_resource().instance()
			get_tree().get_root().call_deferred("add_child", scene)
			
			loading_screen_ins.queue_free()
			current_scene.queue_free()
			return
		
		else:
			print("Error occured while loading scene")
			return
			
