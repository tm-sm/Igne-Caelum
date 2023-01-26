extends BasePlane
class_name PlaneAI

export(int) var machinegun_range : int = 10000
export(float) var tight_turn_thrust : float = 0.2
export(float) var wide_turn_thrust : float = 0.8

enum combat_action { idle, heading_to_target, target_in_range}
enum flight_action { stalling, straight_ahead, wide_turn, sharp_turn}
enum objective_type { fight, retreat}

var objective
var combat_state
var flight_state

var missile_in_the_air = false

var passed_time_delta = 0.0

var throttle_target = 1
var target
#target info
var distance_to_target
var angle_to_target

const pi = 3.14159

func _ready():
	objective = objective_type.retreat
	flight_state = flight_action.straight_ahead
	combat_state = combat_action.idle

func set_target(t):
	if t:
		print(self, " set target to: ", t)
		target = t
		target.connect("destroyed", self, "_on_target_destroyed")
		flight_state = flight_action.straight_ahead
		combat_state = combat_action.heading_to_target
		objective = objective_type.fight

func _process(delta):
	passed_time_delta += delta
	if passed_time_delta >= 2.0:
		passed_time_delta = 0
		locked_on_by_missile = false

func _physics_process(delta):
	var target_position
	if objective != objective_type.retreat:
		target_position = target.global_position
	else:
		print(self, " retreating")
		target_position = Vector2(100000, -10000)
	angle_to_target = get_angle_to(target_position)
	distance_to_target = global_position.distance_to(target_position)
	
	if stalling:
		flight_state = flight_action.stalling
	elif abs(angle_to_target) < pi/180 * 5:
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
	
	print(self, " | ", flight_state, " | ", combat_state, " : ", target, " | ", distance_to_target, " | ", angle_to_target)
	._physics_process(delta)

func update_pitch():
	pitch = 0
	if angle_to_target > pi/180 * 2:
		print(self, " pitching down")
		#for some reason this works better than just using degrees
		pitch_down()
	elif angle_to_target < -pi/180 * 2:
		print(self, " pitching up")
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
	if locked_on_by_missile:
		fire_flares()
	match combat_state:
		combat_action.target_in_range:
			if flight_state == flight_action.straight_ahead and not missile_in_the_air:
				if missile_launcher.targeting and missile_launcher.get_most_likely_target() == target:
					fire_missile()
					missile_in_the_air = true
				else:
					fire_machinegun()

func _on_target_destroyed():
	print(self, "'s target destroyed")
	objective = objective_type.retreat
	combat_state = combat_action.idle

func _on_missile_destroyed():
	missile_in_the_air = false
