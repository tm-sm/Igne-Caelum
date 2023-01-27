extends RigidBody2D
class_name BaseMissile

signal destroyed

const pi = 3.14159
var explosion = preload("res://entities/particles/Explosion.tscn")

onready var world = self
onready var engine_sound = $RocketSound
onready var sprite = $Missile
onready var engine_particles = $Vapor
onready var anim = $AnimationPlayer
onready var detector = $HeatDetector
onready var arming_distance = $ArmingDistance
onready var timer = $Timer
onready var fuse_safety = $FuseSafety

export(float) var weight_tons : float = 10
export(int) var damage : int = 500
export(float) var engine_power : float = 1500
export(float) var torque_strength : float = 700
export(float) var wind_resistance_factor : float = 1
export(float) var lifespan : float = 10

var engine_thrust = Vector2(engine_power, 0.0)

var pitch = 0.0
var pitching = false
var stalling = false

var target

var sprite_angle_offset = 0

var forward_speed
var vertical_speed
var speed_vector
var relative_speed

func _ready():
	gravity_scale = 0
	arming_distance.get_child(0).disabled = true
	fuse_safety.start(0.5)
	add_to_group("sound_emitter")
	add_to_group("damageable")
	weight = weight_tons
	#between the stalling speed and ideal speed there's no agility loss
	relative_speed = linear_velocity.rotated(-get_rotation())
	forward_speed = abs(relative_speed.x)
	vertical_speed = relative_speed.y
	speed_vector  = sqrt(pow(forward_speed, 2) + pow(vertical_speed, 2))

func fire():
	apply_thrust()
	timer.start(lifespan)

func _physics_process(_delta):
	update_pitch()
	
	#now you get a warning even if you toss flares
	for t in detector.get_overlapping_bodies():
		if t.is_in_group("heat_emitter"):
			t.locked_on_by_missile = true
	
	engine_sound.pitch_scale = 7
	relative_speed = linear_velocity.rotated(-get_rotation())
	forward_speed = abs(relative_speed.x)
	vertical_speed = relative_speed.y #the sign is important for air resistance calculations

func _integrate_forces(state):
	apply_pitch(state)
	apply_wind_resistance(state)

func recieve_damage(_dmg):
	emit_signal("destroyed")
	anim.play("explode")

func apply_thrust():
	#I don't use state here because its only used once in this case
	var final_thrust = Vector2(0,0)
	engine_thrust = Vector2(engine_power, 0.0)
	
	var forward_thrust = engine_thrust.rotated(get_rotation())
	final_thrust = forward_thrust
	
	add_central_force(final_thrust)

func apply_pitch(state):
	state.add_torque(-applied_torque)
	if pitching:
		state.add_torque(pitch)

func apply_wind_resistance(state):
	#this adds an impulse on the y direction of the plane, this is done by
	var wind_resistance = Vector2(0, 0)
	wind_resistance.y = vertical_speed * wind_resistance_factor
	wind_resistance = wind_resistance.rotated(get_rotation())
	state.apply_central_impulse(-wind_resistance)

func update_pitch():
	pitch = 0
	if target:
		#this is the only place where it checks if there's a target available in runtime
		var angle_to_target = get_angle_to(target.global_position + Vector2(50, 0).rotated(target.get_rotation()))
		if angle_to_target > pi/180 * 5:
			#for some reason this works better than just using degrees
			pitch_down()
		elif angle_to_target < -pi/180 * 5:
			pitch_up()

func pitch_up():
	pitch = -torque_strength
	pitching = true

func pitch_down():
	pitch = torque_strength
	pitching = true

func explode():
	var expl = explosion.instance()
	world.add_child(expl)
	expl.global_position = global_position
	expl.explode(linear_velocity)

func get_sounds():
	return $RocketSound

func _on_HeatDetector_body_entered(body):
	if body.is_in_group("heat_emitter"):
		if not target or global_position.distance_to(target.global_position) > global_position.distance_to(body.global_position):
			if target and target.is_in_group("damageable"):
				target.disconnect("destroyed", self, "_on_target_destroyed")
			if body.is_in_group("damageable"):
				body.connect("destroyed", self, "_on_target_destroyed")
			target = body

func _on_target_destroyed():
	var possible_targets = detector.get_overlapping_bodies()
	possible_targets.erase(target)
	possible_targets.erase(self)
	
	var closest_target = null
	var closest_dist
	for t in possible_targets:
		#getting the closest target
		var dist = global_position.distance_to(t.global_position)
		if t.is_in_group("heat_emitter") and (not closest_target or dist < closest_dist):
			closest_target = t
			closest_dist = dist
	target = closest_target


func _on_HeatDetector_body_exited(body):
	if body == target:
		if target.is_in_group("damageable"):
			target.disconnect("destroyed", self, "_on_target_destroyed")
		_on_target_destroyed()


func _on_ArmingDistance_body_entered(body):
	if body.is_in_group("damageable") and body != self:
		body.recieve_damage(damage)
		recieve_damage(damage)


func _on_Timer_timeout():
	recieve_damage(damage)


func _on_FuseSafety_timeout():
	arming_distance.get_child(0).disabled = false
