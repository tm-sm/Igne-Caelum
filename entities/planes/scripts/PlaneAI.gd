extends BasePlane
class_name PlaneAI

export(int) var machinegun_range : int = 10000
export(float) var tight_turn_thrust : float = 0.2
export(float) var wide_turn_thrust : float = 0.8

enum combat_action { idle, heading_to_target, target_in_range}
enum flight_action { stalling, straight_ahead, wide_turn, sharp_turn, returning_to_base}

var combat_state
var flight_state

var throttle_target = 1
var target
#target info
var distance_to_target
var angle_to_target

const pi = 3.14159

func _ready():
	pass

func set_target(t):
	target = t
	target.connect("destroyed", self, "_on_target_destroyed")

func _process(delta):
	var target_position
	if flight_state != flight_action.returning_to_base:
		target_position = target.global_position
	else:
		target_position = Vector2(100000, -10000)
	angle_to_target = get_angle_to(target_position)
	distance_to_target = global_position.distance_to(target_position)
	
	if stalling:
		flight_state = flight_action.stalling
	elif abs(angle_to_target) < pi/180 * 2:
		flight_state = flight_action.straight_ahead
	elif abs(angle_to_target) > pi/180 * 90:
		flight_state = flight_action.sharp_turn
	else:
		flight_state = flight_action.wide_turn
	
	if combat_state != combat_action.idle:
		if distance_to_target < machinegun_range:
			combat_state = combat_action.target_in_range
		else:
			combat_state = combat_action.heading_to_target
	
	._process(delta)

func update_pitch():
	pitch = 0
	if angle_to_target > pi/180 * 2:
		#for some reason this works better than just using degrees
		pitch_down()
	elif angle_to_target < -pi/180 * 2:
		pitch_up()

func update_thrust():
	match flight_state:
		flight_action.wide_turn:
			throttle_target = wide_turn_thrust
		flight_action.sharp_turn:
			throttle_target = tight_turn_thrust
		_:
			throttle_target = 1
	
	if engine_thrust_percentage > throttle_target:
		throttle_down()
	elif engine_thrust_percentage < throttle_target:
		throttle_up()

func update_weapons():
	match combat_state:
		combat_action.target_in_range:
			if flight_state == flight_action.straight_ahead:
				fire_machinegun()

func _on_target_destroyed():
	target = self #to avoid accessing null values
	flight_state = flight_action.returning_to_base
	combat_state = combat_action.idle
