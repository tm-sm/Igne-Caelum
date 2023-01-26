extends Camera2D
class_name PlayerCamera

enum mode {PLAYER_AND_TARGET, PLAYER, STILL}

var status
var targets
var targets_index = 0

var target
var player

var zoom_multiplier = 1

var markers


func _ready():
	# Initialization here
	set_process(true)

func initialize(trgts, p, mrk):
	targets = trgts
	player = p
	player.connect("destroyed", self, "_on_player_destroyed")
	if targets.size() > 0:
		for t in targets:
			t.connect("destroyed", self, "_on_target_destroyed", [t])
	status = mode.PLAYER
	markers = mrk
	
func _process(_delta):
	match status:
		mode.PLAYER_AND_TARGET:
			player_and_target_follow()
		mode.PLAYER:
			player_follow()
		mode.STILL:
			hold()

func player_and_target_follow():
	var p1_pos = player.global_position
	
	if target == null:
		next_target()
	if target:
		var p2_pos = target.global_position
		var newpos = (p1_pos + p2_pos) * 0.5
		global_position = newpos
		var distance = p1_pos.distance_to(p2_pos) * 2
		var zoom_factor = distance * 0.002 / 3 

		if zoom_factor < 4:
			zoom_factor = 4
		set_zoom(Vector2(1,1) * zoom_factor * zoom_multiplier)
		toggle_marker_visibility(zoom_multiplier * zoom_factor)

func player_follow():
	if player:
		global_position = player.global_position
		set_zoom(Vector2(5,5) * zoom_multiplier)
		toggle_marker_visibility(zoom_multiplier * 5)
	else:
		status = mode.STILL

func hold():
	set_zoom(Vector2(1, 1) * zoom_multiplier)
	toggle_marker_visibility(zoom_multiplier)

func next_target():
	zoom_multiplier = 1
	if targets.size() == 0:
		status = mode.PLAYER
	else:
		if targets_index >= targets.size():
			targets_index = 0
		target = targets[targets_index]
		targets_index += 1

func next_camera_mode():
	match status:
		mode.STILL:
			status = mode.PLAYER
		mode.PLAYER:
			status = mode.PLAYER_AND_TARGET
		mode.PLAYER_AND_TARGET:
			status = mode.STILL

func _on_target_destroyed(t):
	if t == target:
		next_target()
	targets.erase(t)
	if targets.size()==0 and status != mode.STILL:
		status = mode.PLAYER

func _on_player_destroyed():
	player = null
	status = mode.STILL

func _input(event):
	if event.is_action_pressed("zoom_in"):
		if zoom_multiplier > 0.2 :
			zoom_multiplier -= 0.1
	if event.is_action_pressed("zoom_out"):
		zoom_multiplier += 0.1
	if event.is_action_released("switch_target"):
		status = mode.PLAYER_AND_TARGET
		next_target()
	if event.is_action_released("change_camera_type"):
		next_camera_mode()

func toggle_marker_visibility(current_zoom):
	if current_zoom < 20:
		markers.set_marker_visibility(false)
	else:
		markers.set_marker_visibility(true)
