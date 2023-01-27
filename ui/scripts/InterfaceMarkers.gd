extends Node2D
class_name InterfaceMarkers

onready var marker_type = preload("res://ui/ArrowMarker.tscn")

var markers = []

func add_marker(body, color, mrk_scale):
	var marker = marker_type.instance()
	marker.marker_scale = mrk_scale
	marker.attach_to_body(body)
	marker.modulate = color
	body.add_child(marker)
	markers.append(marker)

func set_marker_scale(value):
	for m in markers:
		if is_instance_valid(m):
			m.scale = Vector2(value, value)
		else:
			markers.erase(m)

func set_marker_visibility(value):
	for m in markers:
		if is_instance_valid(m):
			m.visible = value
		else:
			markers.erase(m)
