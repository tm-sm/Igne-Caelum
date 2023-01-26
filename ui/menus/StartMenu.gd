extends CanvasLayer


onready var main_menu = $ColorRect/PanelContainer/Main
onready var levels = $ColorRect/PanelContainer/Levels

onready var panel = $ColorRect/PanelContainer

onready var ui_sound = $UISelect

var ambush_scene = "res://levels/Ambush.tscn"
var duel_scene = "res://levels/Duel.tscn"
var interception_scene = "res://levels/Interception.tscn"

func _ready():
	set_visible_menu(main_menu)

func _on_Start_pressed():
	on_button_press()
	set_visible_menu(levels)

func _on_Options_pressed():
	on_button_press()

func _on_Exit_pressed():
	on_button_press()
	get_tree().quit()

func _on_Intercept_pressed():
	on_button_press()
	global.load_scene(self, interception_scene)


func _on_Duel_pressed():
	on_button_press()
	global.load_scene(self, duel_scene)


func _on_Ambush_pressed():
	on_button_press()
	global.load_scene(self, ambush_scene)


func _on_Return_pressed():
	on_button_press()
	set_visible_menu(main_menu)

func on_button_press():
	ui_sound.play(0)

func set_visible_menu(menu):
	on_button_press()
	for p in panel.get_children():
		if p == menu:
			p.visible = true
		else:
			p.visible = false
