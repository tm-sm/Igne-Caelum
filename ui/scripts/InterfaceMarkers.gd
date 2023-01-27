extends Node2D
class_name InterfaceMarkers

onready var marker_arrow = preload("res://ui/ArrowMarker.tscn")
onready var marker_circle = preload("res://ui/CircleMarker.tscn")

var markers = []

func _ready():
	spawn_signal.connect("entity_spawned", self, "_on_entity_spawned")

func add_marker(body, color, mrk_scale, mrk_type):
	var marker = mrk_type.instance()
	marker.marker_scale = mrk_scale
	marker.attach_to_body(body)
	marker.modulate = color
	body.add_child(marker)
	markers.append(marker)

func add_arrow_marker(body, color, mrk_scale):
	add_marker(body, color, mrk_scale, marker_arrow)

func add_circle_marker(body, color, mrk_scale):
	add_marker(body, color, mrk_scale, marker_circle)

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

func _on_entity_spawned(entity):
	if entity is BaseMissile:
		add_circle_marker(entity, Color.darkred, 1.0)
