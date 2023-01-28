extends BasePlane
class_name PlaneAI

onready var shot_range = $ShotRange
onready var missile_safe_zone = $MissileSafeZone
#used to avoid the plane shooting its own missile

export(int) var machinegun_range : int = 20000
export(float) var tight_turn_thrust : float = 0.2
export(float) var wide_turn_thrust : float = 0.8

enum combat_action { idle, heading_to_target, target_in_range, dodge_up, dodge_down}
enum flight_action { stalling, straight_ahead, wide_turn, sharp_turn}
enum objective_type { fight, retreat}

var objective
var combat_state
var flight_state

var throttle_target = 1
var target
#target info
var distance_to_target
var angle_to_target

var missile_in_safe_zone = true
var dodging = false
#this will eventually also be used to avoid collisions

const pi = 3.14159

func _ready():
	objective = objective_type.retreat
	flight_state = flight_action.straight_ahead
	combat_state = combat_action.idle

func set_target(t):
	if t:
#		print(self, " set target to: ", t)
		if target and target.is_in_group("damageable"):
			target.disconnect("destroyed", self, "_on_target_destroyed")
		
		target = t
		if t.is_in_group("damageable"):
			target.connect("destroyed", self, "_on_target_destroyed")
		flight_state = flight_action.straight_ahead
		combat_state = combat_action.heading_to_target
		objective = objective_type.fight


func _physics_process(delta):
	var target_position
	if not locked_on_by_missile:
		dodging = false
		if objective != objective_type.retreat:
			target_position = target.global_position
		else:
	#		print(self, " retreating")
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
	else:
		if not dodging:
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			if rng.randf_range(0, 1) > 0.5:
				combat_state = combat_action.dodge_up
			else:
				combat_state = combat_action.dodge_down
		dodging = true
		print("dodging")
		flight_state = flight_action.wide_turn
	
#	print(self, " | ", flight_state, " | ", combat_state, " : ", target, " | ", distance_to_target, " | ", angle_to_target)
	._physics_process(delta)

func update_pitch():
	pitch = 0
	if combat_state == combat_action.dodge_down or (not dodging and angle_to_target > pi/180 * 2):
#		print(self, " pitching down")
		#for some reason this works better than just using degrees
		pitch_down()
	elif combat_state == combat_action.dodge_up or (not dodging and angle_to_target < -pi/180 * 2):
#		print(self, " pitching up")
		pitch_up()

func update_thrust():
	match flight_state:
		flight_action.wide_turn:
			throttle_target = wide_turn_thrust
		flight_action.sharp_turn:
			throttle_target = tight_turn_thrust
		_:
			throttle_target = 1

	if distance_to_target < 2000:
		#target is very close, there's a risk of overshooting/getting shot, slowing down makes it harder to hit
		throttle_target = throttle_target * 0.5
	
	if engine_thrust_percentage > throttle_target:
		throttle_down()
	elif engine_thrust_percentage < throttle_target:
		throttle_up()

func update_weapons():
	if locked_on_by_missile:
		fire_flares()
	match combat_state:
		combat_action.target_in_range:
			if flight_state == flight_action.straight_ahead:
				#looking at the target
				if not missile_in_the_air and missile_launcher.targeting and missile_launcher.get_most_likely_target() == target:
					fire_missile()
					missile_in_safe_zone = false
					missile_safe_zone.start(3)
					#now it won't shoot its own missile off the sky the moment it fires it
				elif has_clear_shot() and missile_in_safe_zone:
					#there's little risk of hitting a friendly
					fire_machinegun()

func _on_target_destroyed():
#	print(self, "'s target destroyed")
	objective = objective_type.retreat
	combat_state = combat_action.idle

func has_clear_shot()->bool:
	var obstacles = shot_range.get_overlapping_bodies()
	for o in obstacles:
		if (o.is_in_group("bogey") and o.team == team):
			#shooting risks damaging a friendly
			return false
	return true

func _on_MissileSafeZone_timeout():
	missile_in_safe_zone = true
