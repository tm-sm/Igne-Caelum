extends Sprite
class_name CircleMarker

export(float) var marker_scale : float = 1
var attached_body 

func _ready():
	scale = Vector2(marker_scale, marker_scale)

func attach_to_body(body):
	attached_body = body

func _process(_delta):
	if attached_body:
		global_position = attached_body.global_position
		rotation = -attached_body.get_rotation()
