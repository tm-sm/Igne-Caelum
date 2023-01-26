extends Position2D
class_name FlareDispenser

onready var flare = preload("res://entities/weapons/Flare.tscn")
onready var timer = $Timer
onready var sound = $Sound

export(int) var salvoAmount : int = 2
export(float) var launch_rate : float = 0.5

var attached_body
var can_launch = true

func _ready():
	timer.start(launch_rate)

func initialize(body):
	attached_body = body

func fire():
	if can_launch:
		var impulse = Vector2(0, 1000)
		sound.play(0)
		for n in salvoAmount:
			var flare_ins = flare.instance()
			attached_body.world.add_child(flare_ins)
			flare_ins.apply_central_impulse(attached_body.linear_velocity + impulse.rotated(attached_body.get_rotation()))
			flare_ins.add_collision_exception_with(attached_body)
			flare_ins.global_position = global_position
			impulse += Vector2(-5, 0)
			impulse *= Vector2(1, -1)
		can_launch = false

func _on_Timer_timeout():
	can_launch = true
