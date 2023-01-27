extends Node
class_name EntitySpawnerSignalBus

signal entity_spawned(entity)

func _on_entity_spawned(entity):
	print("entity spawned")
	emit_signal("entity_spawned", entity)
