extends Position2D
class_name MachineGun

export(float) var power : float = 10000
export(String) var ammo_path : String = "res://entities/weapons/BaseBullet.tscn"
export(float) var fire_rate_seconds : float = 0.1
export(int) var max_ammo : float = 350

onready var timer = $Timer
onready var ammo_type = load(ammo_path)
onready var sound = $Gunshot

var can_fire = true
var ammo = max_ammo


var attached_body

func _ready():
	timer.start(fire_rate_seconds)

func initialize(body):
	attached_body = body

func fire():
	if can_fire:
		if ammo <= 0:
			timer.stop()
			can_fire = false
		else:
			sound.play(0)
			var impulse = Vector2(attached_body.forward_speed + power, 0).rotated(attached_body.get_rotation())
			var ammo_ins = ammo_type.instance()
			add_child(ammo_ins)
			ammo_ins.fire(impulse)
			ammo_ins.add_collision_exception_with(attached_body)
			can_fire = false
			ammo -= 1


func _on_Timer_timeout():
	can_fire = true
