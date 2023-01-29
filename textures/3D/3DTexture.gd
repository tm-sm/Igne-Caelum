extends Spatial

onready var shape = $Neski
onready var body = $Neski/Airframe
onready var animation_player = $AnimationPlayer
onready var tail_insigna = $Neski/Tail/TailInsigna
onready var wing_insigna = $Neski/Wings/WingInsigna


var rng = RandomNumberGenerator.new()

var rot_to_straight = Vector3(0, 0, 2) #the current vector being used to straighten the plane
var rot_to_inverted = Vector3(0, 0, 2) #the same but to invert it

func initialize(airframe_color, belly_color, cockpit_color, insigna_tail, insigna_wing):
	body.get_surface_material(0).albedo_color = airframe_color #airframe
	body.get_surface_material(2).albedo_color = belly_color #belly
	cockpit_color.a = 0.5 #now it's transparent
	body.get_surface_material(4).albedo_color = cockpit_color #cockpit
	
	tail_insigna.get_mesh().surface_get_material(0).albedo_texture = insigna_tail
	wing_insigna.get_mesh().surface_get_material(0).albedo_texture = insigna_wing

func flip_to_straight():
	var rot = shape.get_rotation_degrees()
	var abs_rot = abs(rot.z)
	if abs_rot <= 182.0 and abs_rot >= 178.0:
		#plane is inverted
		if rng.randf_range(0, 1.0) > 0.5:
			rot_to_straight = Vector3(0, 0, 2)
		else:
			rot_to_straight = -Vector3(0, 0, 2)
	elif abs_rot <= 2.0 or abs_rot >= 358.0: #using == 0.0 doesn't work due to float precision
		#plane is straight
		return #no need to flip
	else:
		#mid rotation, the plane needs to get to the closest rotation position, either 0 or 360
		if abs_rot <= 180.0:
			shape.rotation_degrees.z = rot.z - (abs_rot / rot.z) * 2
			#if it is at 177 this will return 177 - (177 / 177) = 176, if it's at -177, -177 - (177 / -177) = -176
		else:
			shape.rotation_degrees.z = rot.z + (abs_rot / rot.z) * 2
		return 
	shape.rotation_degrees.z = rot.z + rot_to_straight.z
	keep_within_360_degrees()

func flip_to_inverted():
	var rot = shape.get_rotation_degrees()
	var abs_rot = abs(rot.z)
	if abs_rot <= 2.0 or abs_rot > 358.0:
		#plane is straight
		if rng.randf_range(0, 1.0) > 0.5:
			rot_to_straight = Vector3(0, 0, 2)
		else:
			rot_to_straight = -Vector3(0, 0, 2)
	elif abs_rot <= 182.0 and abs_rot >= 178.0:
		#plane is inverted
		return
	else:
		#mid rotation, the plane needs to get to the closest rotation position, either 0 or 360
		if abs_rot <= 180.0:
			shape.rotation_degrees.z = rot.z + (abs_rot / rot.z) * 2
		else:
			shape.rotation_degrees.z = rot.z - (abs_rot / rot.z) * 2
		return 
	shape.rotation_degrees.z = rot.z + rot_to_straight.z
	keep_within_360_degrees()

func keep_within_360_degrees():
	if abs(shape.rotation_degrees.z) >= 360.0:
		shape.rotation_degrees.z = fmod(shape.rotation_degrees.z, 360.0)
