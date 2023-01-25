extends Listener2D

var active_sounds = Dictionary()

func _ready():
	pass

func _process(_delta):
	var sound_sources = active_sounds.keys()
	for s in sound_sources:
		var sound_mod =  active_sounds[s] / global_position.distance_to(s.global_position) 
		if sound_mod < 1:
			#getting away
			sound_mod = 0.75
		else:
			sound_mod = 1.1
		s.get_sounds().pitch_scale = s.get_sounds().pitch_scale * sound_mod

func _on_ListeningArea_body_entered(body):
	if body.is_in_group("sound_emitter") and body != get_parent():
		active_sounds[body] = global_position.distance_to(body.global_position)
		body.connect("destroyed", self, "_on_emitter_destroyed", [body])

func _on_ListeningArea_body_exited(body):
	if body.is_in_group("sound_emitter") and active_sounds.has(body):
		active_sounds.erase(body)
		body.disconnect("destroyed", self, "_on_emitter_destroyed")

func _on_emitter_destroyed(body):
	active_sounds.erase(body)
