extends Spatial
class_name Airframe3D

onready var shape = $Plane
onready var body = $Plane/Airframe
onready var tail_insigna = $Plane/Airframe/TailInsigna
onready var wing_insigna = $Plane/Airframe/WingInsigna


var rng = RandomNumberGenerator.new()

var rotating = false
var control = true
var parent

var elapsed_time = 0.0

var rot_to_straight = Vector3(0, 0, 2) #the current vector being used to straighten the plane
var rot_to_inverted = Vector3(0, 0, 2) #the same but to invert it

var last_rot = 0

func initialize(prnt, airframe_color, belly_color, cockpit_color, insigna_tail, insigna_wing):
	parent = prnt
	customize(airframe_color, belly_color, cockpit_color, insigna_tail, insigna_wing)

func customize(_airframe_color, _belly_color, _cockpit_color, _insigna_tail, _insigna_wing):
	pass

func _process(delta):
	if control:
		#to smooth out movement
		elapsed_time += delta
		if rotating:
			#prevents the straightening from occuring
			elapsed_time = 0.0
		else:
			mantain_momentum()
		rotating = false
		if elapsed_time >= 3.0:
			#the plane will straighten out in the direction its facing
			if abs(parent.rotation_degrees) >= 90:
				#facing left
				flip_to_inverted_no_rot()
			else:
				flip_to_straight_no_rot()
	else:
		shape.rotation_degrees += Vector3(0, 0, 3)
	

func mantain_momentum():
	last_rot = last_rot * 0.5
	shape.rotation_degrees.z = shape.rotation_degrees.z + last_rot

func flip_to_straight():
	rotating = true
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
		last_rot = 0
		return #no need to flip
	else:
		#mid rotation, the plane needs to get to the closest rotation position, either 0 or 360
		var rot_amount = (abs_rot / rot.z) * 2
		if abs_rot <= 180.0:
			shape.rotation_degrees.z = rot.z - rot_amount
			last_rot = -rot_amount * 5
			#if it is at 177 this will return 177 - (177 / 177) = 176, if it's at -177, -177 - (177 / -177) = -176
		else:
			shape.rotation_degrees.z = rot.z + rot_amount
			last_rot = rot_amount * 5
		return 
	shape.rotation_degrees.z = rot.z + rot_to_straight.z
	last_rot = rot_to_straight.z
	keep_within_360_degrees()

func flip_to_inverted():
	rotating = true
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
		last_rot = 0
		return
	else:
		#mid rotation, the plane needs to get to the closest rotation position, either 0 or 360
		var rot_amount = (abs_rot / rot.z) * 2
		if abs_rot <= 180.0:
			shape.rotation_degrees.z = rot.z + rot_amount
			last_rot = rot_amount * 5
		else:
			shape.rotation_degrees.z = rot.z - rot_amount
			last_rot = -rot_amount * 5
		return 
	shape.rotation_degrees.z = rot.z + rot_to_straight.z
	keep_within_360_degrees()

func flip_to_straight_no_rot():
	flip_to_straight()
	rotating = false

func flip_to_inverted_no_rot():
	flip_to_inverted()
	rotating = false

func keep_within_360_degrees():
	if abs(shape.rotation_degrees.z) >= 360.0:
		shape.rotation_degrees.z = fmod(shape.rotation_degrees.z, 360.0)
