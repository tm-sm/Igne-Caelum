extends RigidBody2D
class_name Explosion

onready var explosion = $Explosion
onready var shader = $ExplosionShader
onready var timer = $Timer
onready var debris = $DebrisGroup.get_children()
onready var anim_player = $AnimationPlayer

func _ready():
	sleeping = true

func explode(impulse):
	anim_player.play("explode")
	timer.start(15)
	var modifier = -45
	apply_central_impulse(impulse)
	for d in debris:
		d.sleeping = false
		d.apply_central_impulse(impulse.rotated(modifier))
		modifier += 45

func _on_Timer_timeout():
	queue_free()
