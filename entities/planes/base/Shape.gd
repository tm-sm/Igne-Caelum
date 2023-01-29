extends Node2D

onready var shape = $Shape
var attached_viewport

func initialize(viewport):
	attached_viewport = viewport

func _process(_delta):
	if attached_viewport:
		shape.texture = attached_viewport.get_texture()
