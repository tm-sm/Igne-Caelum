extends Position2D
class_name MissileLauncher

export(String) var ammo_path : String = "res://entities/weapons/Missile.tscn"
export(float) var cooldown : float = 5

onready var ammo = load(ammo_path)
onready var timer = $Timer

var can_fire = true

var attached_body

func initialize(body):
	attached_body = body

func fire():
	if can_fire:
		var missile_ins = ammo.instance()
		add_child(missile_ins)
		missile_ins.set_target_rotation(attached_body.get_rotation())
		missile_ins.apply_central_impulse(attached_body.linear_velocity)
		missile_ins.add_collision_exception_with(attached_body)
		missile_ins.fire()
		missile_ins.world = attached_body.world
		can_fire = false
		timer.start(cooldown)


func _on_Timer_timeout():
	can_fire = true
