extends Node
class_name SceneLoader

onready var loading_screen = preload("res://ui/menus/LoadingScreen.tscn")
var time_max = 10000

func load_scene(current_scene, next_scene):
	
	var loading_screen_ins = loading_screen.instance()
	get_tree().get_root().call_deferred("add_child", loading_screen_ins)
	
	print("loading ", next_scene)
	var loader = ResourceLoader.load_interactive(next_scene)
	
	if loader == null:
		print("Error occured while getting scene")
		return
	
	#this way the loading scene has time to appear
	yield(get_tree().create_timer(0.5), "timeout")
	
	print("here")
	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		var error = loader.poll()
		if error == OK:
			#data was loaded correctly
			var progress_bar = loading_screen_ins.get_node("PanelContainer/VBoxContainer/ProgressBar")
			progress_bar.value = float(loader.get_stage()) / loader.get_stage_count() * 100
			print(progress_bar.value)
			yield(get_tree().create_timer(0.01), "timeout")
		
		elif error == ERR_FILE_EOF:
			#scene finished loading
			print("loading finished")
			var scene = loader.get_resource().instance()
			get_tree().get_root().call_deferred("add_child", scene)
			loading_screen_ins.queue_free()
			current_scene.queue_free()
			loader = null
			break
		
		else:
			print("Error occured while loading scene")
			current_scene.queue_free()
			loading_screen_ins.queue_free()
			loader = null
			break
			
