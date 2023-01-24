extends RigidBody2D
class_name BaseBullet

onready var anim = $AnimationPlayer
onready var timer = $Timer

export(int) var damage : int = 20
export(float) var bullet_weight : float = 0.1

func fire(impulse):
	weight = bullet_weight
	apply_central_impulse(impulse)
	timer.start(5)

func _on_Bullet_body_entered(body):
	add_collision_exception_with(body)
	body.damage(damage)
	anim.play("explode")

func damage(_dmg):
	anim.play("explode")

func _on_Timer_timeout():
	queue_free()
