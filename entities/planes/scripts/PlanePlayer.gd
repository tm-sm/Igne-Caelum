extends BasePlane
class_name PlanePlayer

func _ready():
	._ready()
	engine_sound.volume_db = -15

func update_thrust():
	if Input.is_action_pressed("thrust_increase"):
		throttle_up()
	elif Input.is_action_pressed("thrust_decrease"):
		throttle_down()
	if Input.is_action_pressed("brake"):
		target_speed = 0

func update_pitch():
	pitching = false
	pitch = 0
	if Input.is_action_pressed("pitch_up"):
		pitch_up()
	elif Input.is_action_pressed("pitch_down"):
		pitch_down()

func update_weapons():
	if Input.is_action_pressed("fire_machineguns"):
		fire_machinegun()

func _input(event):
	if event.is_action_pressed("debug_destroy_self"):
		explode()
