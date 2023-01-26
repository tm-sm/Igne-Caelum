extends Position2D
class_name MissileLauncher

export(String) var ammo_path : String = "res://entities/weapons/Missile.tscn"
export(float) var cooldown : float = 5
export(int) var max_ammo : int = 10

onready var ammo_type = load(ammo_path)
onready var timer = $Timer
onready var reciever = $TargetReciever

var ammo = max_ammo
var can_fire = true

var targeting = false
var attached_body

func initialize(body):
	attached_body = body

func fire():
	if can_fire:
		if ammo <= 0:
			timer.stop()
			can_fire = false
		else:
			var missile_ins = ammo_type.instance()
			missile_ins.rotation = attached_body.get_rotation()
			attached_body.world.add_child(missile_ins)
			missile_ins.global_position = global_position
			missile_ins.apply_central_impulse(attached_body.linear_velocity)
			missile_ins.add_collision_exception_with(attached_body)
			missile_ins.fire()
			missile_ins.world = attached_body.world
			missile_ins.connect("destroyed", attached_body, "_on_missile_destroyed")
			ammo -= 1
			can_fire = false
			timer.start(cooldown)

func _process(_delta):
	targeting = false
	if can_fire:
		var targets = reciever.get_overlapping_bodies()
		for t in targets:
			if t.is_in_group("heat_emitter"):
				targeting = true
				break

func _on_Timer_timeout():
	can_fire = true

func get_most_likely_target()->Object:
	if targeting and can_fire:
		var targets = reciever.get_overlapping_bodies()
		var closest_target = null
		var closest_dist
		for t in targets:
			#getting the closest target
			var dist = global_position.distance_to(t.global_position)
			if t.is_in_group("heat_emitter") and (not closest_target or dist < closest_dist):
				closest_target = t
				closest_dist = dist
		return closest_target
	return null

