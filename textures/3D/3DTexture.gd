extends Spatial

onready var animation_player = $AnimationPlayer
var rng = RandomNumberGenerator.new()

func _ready():
	animation_player.play("flying_straight")

func flip_to_straight():
	rng.randomize()
	if rng.randf_range(0, 1.0) > 0.5:
		animation_player.play("turning_inverted_front")
	else:
		animation_player.play("turning_inverted_belly")

func flip_to_inverted():
	rng.randomize()
	if rng.randf_range(0, 1.0) > 0.5:
		animation_player.play("turning_straight_front")
	else:
		animation_player.play("turning_straight_belly")
