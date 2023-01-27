extends RigidBody2D
class_name Flare

var locked_on_by_missile = true

func _ready():
	add_to_group("heat_emitter")

func _on_Timer_timeout():
	queue_free()
