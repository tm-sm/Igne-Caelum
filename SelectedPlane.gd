extends Node

var plane


func set_plane(plane_type, color):
	plane = plane_type.instance()
	plane.color.modulate = color
