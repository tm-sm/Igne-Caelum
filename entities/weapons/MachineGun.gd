extends Position2D
class_name machine_gun

export(float) var power : float = 10000
export(String) var ammo_path : String = "res://entities/weapons/BaseBullet.tscn"
export(float) var fire_rate_seconds : float = 0.1

onready var timer = $Timer
onready var ammo = load(ammo_path)
onready var sound = $Gunshot

var can_fire = true

var attached_body

func _ready():
	timer.start(fire_rate_seconds)

func initialize(body):
	attached_body = body

func fire():
	if can_fire:
		sound.play(0)
		var impulse = Vector2(attached_body.forward_speed + power, 0).rotated(attached_body.get_rotation())
		var ammo_ins = ammo.instance()
		add_child(ammo_ins)
		ammo_ins.fire(impulse)
		ammo_ins.add_collision_exception_with(attached_body)
		can_fire = false


func _on_Timer_timeout():
	can_fire = true
