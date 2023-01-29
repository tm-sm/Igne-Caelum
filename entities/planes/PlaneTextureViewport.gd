extends Viewport

export(Resource) var res = preload("res://textures/3D/Neski3D.tscn")

var plane_shape

func _ready():
	plane_shape = res.instance()
	add_child(plane_shape)

func flip_to_straight():
	plane_shape.flip_to_straight()

func flip_to_inverted():
	plane_shape.flip_to_inverted()
