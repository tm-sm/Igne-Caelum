extends BasePlane
class_name PlanePlayer

enum weapons {machinegun, missile}

var selected_weapon

onready var lock_on_sound = $TargetLockSound

func _ready():
	._ready()
	engine_sound.volume_db = -15
	selected_weapon = weapons.machinegun

func _process(_delta):
	if missile_launcher.targeting:
		if not lock_on_sound.playing:
			lock_on_sound.play(0)
	else:
		lock_on_sound.stop()

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

func fire_selected_weapon():
	match selected_weapon:
		weapons.machinegun:
			fire_machinegun()
		weapons.missile:
			fire_missile()

func update_weapons():
	if Input.is_action_pressed("fire_weapon"):
		fire_selected_weapon()
	if Input.is_action_pressed("weapon_selection_1"):
		selected_weapon = 0
	if Input.is_action_pressed("weapon_selection_2"):
		selected_weapon = 1

func _input(event):
	if event.is_action_pressed("debug_destroy_self"):
		explode()
