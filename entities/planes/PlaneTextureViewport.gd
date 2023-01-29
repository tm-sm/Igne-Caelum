extends Viewport

export(Resource) var res = load("res://textures/3D/Neski3D.tscn")

var plane_shape

func _ready():
	plane_shape = res.instance()
	add_child(plane_shape)

func initialize(airframe, belly, cockpit, insigna_tail, insigna_wing):
	plane_shape.initialize(airframe, belly, cockpit, insigna_tail, insigna_wing)

func straighten():
	plane_shape.flip_to_straight()

func invert():
	plane_shape.flip_to_inverted()
