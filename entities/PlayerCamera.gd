extends Camera2D
class_name PlayerCamera

enum mode {PLAYER_AND_TARGET, PLAYER, STILL}

var status
var targets

var target
var player

func _ready():
	# Initialization here
	set_process(true)

func initialize(trgts, p):
	targets = trgts
	player = p
	player.connect("destroyed", self, "_on_player_destroyed")
	if targets.size() > 0:
		status = mode.PLAYER_AND_TARGET
		for t in targets:
			t.connect("destroyed", self, "_on_target_destroyed", [t])
	else:
		status = mode.PLAYER
	
func _process(delta):
	match status:
		mode.PLAYER_AND_TARGET:
			player_and_target_follow()
		mode.PLAYER:
			player_follow()
		mode.STILL:
			hold()

func player_and_target_follow():
	var p1_pos = player.global_position
	var closest = null
	var closest_dist
	for t in targets:
		var new_dist = p1_pos.distance_to(t.global_position)
		if not closest or new_dist < closest_dist:
			closest = t
			closest_dist = new_dist
	target = closest
	
	var p2_pos = target.global_position
	var newpos = (p1_pos+p2_pos) * 0.5
	global_position = newpos
	var distance = p1_pos.distance_to(p2_pos) * 2
	var zoom_factor = distance * 0.002 / 3

	if zoom_factor < 4:
		zoom_factor = 4
	set_zoom(Vector2(1,1) * zoom_factor)

func player_follow():
	global_position = player.global_position
	set_zoom(Vector2(5,5))

func hold():
	set_zoom(Vector2(10, 10))

func _on_target_destroyed(t):
	targets.erase(t)
	if targets.size()==0 and status != mode.STILL:
		status = mode.PLAYER

func _on_player_destroyed():
	player = null
	status = mode.STILL
