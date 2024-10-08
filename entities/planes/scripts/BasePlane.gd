extends RigidBody2D
class_name BasePlane

signal destroyed

const half_circle= 3.14159
var explosion = preload("res://entities/particles/Explosion.tscn")

onready var world = self
onready var engine = $Plane/EnginePosition
onready var engine_sound = $JetSound
onready var hit_sound = $Hit
onready var plane_body = $Plane
onready var machinegun = $Plane/MachineGun
onready var missile_launcher = $Plane/MissileLauncher
onready var flare_dispenser = $Plane/FlareDispenser
onready var shape = $Plane/Shape
onready var vapor = $Plane/Vapor
onready var stall_vapor = $Plane/StallVapor
onready var smoke = $Plane/FireSmoke
onready var fire = $Plane/Fire
onready var engine_particles = $Plane/Engine
onready var anim = $AnimationPlayer
onready var plane_model = $PlaneModel


export(Teams.group) var team

export(float) var weight_tons : float = 20
export(int) var max_health : int = 100
export(float) var max_speed = 2000.0
export(float) var stall_speed = 600.0  #at which speed the aircraft starts to feel the effects of gravity
export(float) var agility : float = 70
export(float) var brakes_power : float = 100
export(float) var engine_power : float = 800
export(float) var torque_strength : float = 5000
export(float) var wind_resistance_factor : float = 0.06 #value between 0.01 and 0.1

export(Color) var airframe_color : Color = Color.white
export(Color) var belly_color : Color = Color.white
export(Color) var cockpit_color : Color = Color.white

export(Texture) var insigna_tail
export(Texture) var insigna_wing

var health

var engine_thrust_percentage = 1
var engine_thrust = Vector2(engine_thrust_percentage * engine_power, 0.0)

var pitch = 0.0
var braking = false
var pitching = false
var stalling = false
var flipped = false
var locked_on_by_missile = false
export var controls_enabled = true
var missile_in_the_air = false
var dead = false

var previous_linear_velocity
var ideal_speed
var climb_angle
var forward_speed
var vertical_speed
var speed_vector
var relative_speed
var target_speed = 0 #the maximum speed reachable by the current engine configuration

var passed_time_delta = 0.0

func _ready():
	#the doppler effect gets applied
	add_to_group("sound_emitter")
	#has the function recieve_damage
	add_to_group("damageable")
	#can be targeted by missiles
	add_to_group("heat_emitter")
	#is a valid target and has a team
	add_to_group("bogey")
	health = max_health
	controls_enabled = true
	#which particles should be emitting and which don't
	stall_vapor.emitting = false
	fire.emitting = false
	smoke.emitting = false
	vapor.emitting = true
	
	weight = weight_tons
	
	#between the stalling speed and ideal speed there's no agility loss
	ideal_speed = stall_speed + (stall_speed + max_speed) / 2
	relative_speed = linear_velocity.rotated(-get_rotation())
	forward_speed = abs(relative_speed.x)
	vertical_speed = relative_speed.y
	speed_vector  = sqrt(pow(forward_speed, 2) + pow(vertical_speed, 2))
	
	#weapon initializations
	machinegun.initialize(self)
	missile_launcher.initialize(self)
	flare_dispenser.initialize(self)
	
	#this way the plane starts with momentum
	set_throttle(1)
	apply_impulse(engine.position, engine_thrust.rotated(get_rotation()))

func initialize(wrld, tm):
	world = wrld
	team = tm
	plane_model.initialize(self, airframe_color, belly_color, cockpit_color, insigna_tail, insigna_wing)

func _process(delta):
	#this lets the lock_on_alarm stay on the screen for a while longer
	passed_time_delta += delta
	if passed_time_delta >= 1.29:
		passed_time_delta = 0
		locked_on_by_missile = false

func _physics_process(_delta):
	if controls_enabled:
		update_pitch()
		update_thrust()
		update_weapons()
		update_engine_visuals()
	
	previous_linear_velocity = linear_velocity
	relative_speed = linear_velocity.rotated(-get_rotation())
	forward_speed = abs(relative_speed.x)
	vertical_speed = relative_speed.y #the sign is important for air resistance calculations
	speed_vector  = sqrt(pow(forward_speed, 2) + pow(vertical_speed, 2))
	
	#this checks whether the aircraft is stalling or not
	if forward_speed < stall_speed:
		stalling = true
	else:
		stalling = false
	
	#this checks if stall_vapor should be emitting
	if forward_speed > stall_speed / 2 and vertical_speed != 0:
		if forward_speed / abs(vertical_speed) < 0.5:
			#var sign_needed = 1
			#apply_central_impulse(Vector2(0, 10).rotated(get_rotation()) * sign_needed)
			stall_vapor.emitting = true
		else:
			stall_vapor.emitting = false

func _integrate_forces(state):
	apply_thrust(state)
	apply_pitch(state)
	apply_gravity_effects()
	apply_wind_resistance(state)

func recieve_damage(dmg):
	health = health - dmg
	hit_sound.play(0)
	if health <= 0 and not dead:
		smoke.emitting = true
		engine_particles.emitting = false
		plane_model.lose_control()
		emit_signal("destroyed")
		dead = true
		#50/50 chance it explodes immediately
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		if rng.randf_range(0.0, 1.0) > 0.5:
			explode(1)
			queue_free()
		else:
			anim.play("die")

func apply_thrust(state):
	#calculating the force needed to mantain the desired speed
	var final_thrust = Vector2(0,0)
	engine_thrust = Vector2(engine_thrust_percentage * engine_power, 0.0)
	
	if forward_speed < target_speed:
		var forward_thrust = engine_thrust.rotated(get_rotation())
		final_thrust = forward_thrust - applied_force #if it was at 40 and I wanted it at 20, it adds -20
	else:
		final_thrust = -applied_force*0.1 #the aircraft will start slowing down gradually
		
	state.add_force(engine.position, final_thrust)

func apply_pitch(state):
	#calculating the torque needed to mantain the desired pitch and reduce mobility at high/low speeds
	var final_pitch
	state.add_torque(-applied_torque)
	if pitching:
		var pitch_lost_percentage = 0
		if stalling:
			pitch_lost_percentage = (speed_vector / stall_speed) * (1 - agility / 100)
		elif speed_vector > ideal_speed:
			pitch_lost_percentage = (speed_vector / max_speed) * (1 - agility / 100)
		
		final_pitch = pitch * (1 - pitch_lost_percentage)
		state.add_torque(final_pitch)

func apply_gravity_effects():
	gravity_scale = 0
	climb_angle = -get_rotation_degrees()
	if stalling:
		gravity_scale += 1.0 - forward_speed / stall_speed + 0.1
		if climb_angle > 20 and climb_angle < 90:
			apply_torque_impulse(10 * weight_tons * climb_angle / 90)
		elif climb_angle > 90 and climb_angle < 160:
			apply_torque_impulse(-10 * weight_tons * ((180 - climb_angle) / 90))
	else:
		gravity_scale += 0.1

func apply_wind_resistance(state):
	#this adds an impulse on the y direction of the plane, this is done by
	if not stalling:
		var wind_resistance = Vector2(0, 0)
		wind_resistance.y = vertical_speed * wind_resistance_factor * abs(forward_speed/max_speed)
		wind_resistance = wind_resistance.rotated(get_rotation())
		state.apply_central_impulse(-wind_resistance)

func update_thrust():
	pass

func update_pitch():
	pass

func update_weapons():
	pass

func pitch_up():
	pitch = -torque_strength
	pitching = true
	if flipped:
		#this way the aircraft completely flips, not just the sprites
		for c in plane_body.get_children():
			if not c is Sprite:
				c.position.y = -c.position.y
	plane_model.straighten()
	flipped = false

func pitch_down():
	pitch = torque_strength
	pitching = true
	if not flipped:
		for c in plane_body.get_children():
			if not c is Sprite:
				c.position.y = -c.position.y
	plane_model.invert()
	flipped = true

func throttle_up():
	engine_thrust_percentage += 0.01
	if engine_thrust_percentage > 1:
		engine_thrust_percentage = 1
	target_speed = max_speed * engine_thrust_percentage

func throttle_down():
	engine_thrust_percentage -= 0.01
	if engine_thrust_percentage < 0:
		engine_thrust_percentage = 0
	target_speed = max_speed * engine_thrust_percentage

func set_throttle(throttle):
	target_speed = max_speed * throttle

func fire_machinegun():
	machinegun.fire()

func fire_missile():
	missile_in_the_air = true
	missile_launcher.fire()

func fire_flares():
	flare_dispenser.fire()

func update_engine_visuals():
	engine_sound.pitch_scale = engine_thrust_percentage * 3 + 1
	engine_particles.process_material.set("gravity", Vector3(-100 * engine_thrust_percentage - 40, 0, 0))

func spawn_explosion():
	var expl = explosion.instance()
	world.call_deferred("add_child", expl)
	yield(expl, "ready")
	expl.global_position = global_position
	expl.explode(linear_velocity)

func explode(number):
	if number == 1:
		spawn_explosion()
	else:
		for n in number:
			spawn_explosion()
			yield(get_tree().create_timer(0.24), "timeout")

func get_sounds()->AudioStreamPlayer2D:
	return engine_sound

func get_missile_sensor()->bool:
	return missile_launcher.targeting

func get_machinegun()->MachineGun:
	return machinegun

func get_missile_launcher()->MissileLauncher:
	return missile_launcher

func get_flare_dispenser()->FlareDispenser:
	return flare_dispenser

func _on_missile_destroyed():
	missile_in_the_air = false

func _on_body_entered(body):
	if body is RigidBody2D:
		#to prevent crashing into smoke
		#check if there's any collision happening
		#bullets will get included in this, but it will help in randomizing damage, bullets have low weight, so they shoulnd't affect that much
		var collision_force_vector = Vector2(0,0)
		var collision_force = 0.0
		var velocity_difference : Vector2 = linear_velocity - previous_linear_velocity
		collision_force_vector = velocity_difference
		collision_force = sqrt(pow(collision_force_vector.x, 2.0) + pow(collision_force_vector.y, 2.0))
		#a bullet collision will give a collision force of 8 - 40
		#a plane collision will give >300
		recieve_damage(collision_force * body.mass / 2)
