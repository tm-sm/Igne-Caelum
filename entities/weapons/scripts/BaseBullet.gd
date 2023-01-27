extends RigidBody2D
class_name BaseBullet

onready var anim = $AnimationPlayer
onready var timer = $Timer

export(int) var damage : int = 20
export(float) var bullet_weight : float = 0.1

func _ready():
	add_to_group("ammunition")

func fire(impulse):
	weight = bullet_weight
	apply_central_impulse(impulse)
	timer.start(5)

func _on_Bullet_body_entered(body):
	add_collision_exception_with(body)
	#this prevents the same bullet impacting multiple times
	if body.is_in_group("damageable"):
		body.recieve_damage(damage)
	anim.play("explode")

func recieve_damage(_dmg):
	anim.play("explode")

func _on_Timer_timeout():
	queue_free()
