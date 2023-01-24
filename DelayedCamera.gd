extends Camera2D

export var speed = 50
var target

func _ready():
	target = get_parent()

func _physics_process(delta):
	position = lerp(position, target.position, speed * delta)
