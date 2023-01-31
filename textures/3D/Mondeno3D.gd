extends Airframe3D

func customize(airframe_color, belly_color, cockpit_color, insigna_tail, insigna_wing):
	body.get_surface_material(1).albedo_color = airframe_color #airframe
	body.get_surface_material(3).albedo_color = belly_color #belly
	cockpit_color.a = 0.3 #now it's transparent
	body.get_surface_material(2).albedo_color = cockpit_color #cockpit
	
	tail_insigna.get_mesh().surface_get_material(0).albedo_texture = insigna_tail
	wing_insigna.get_mesh().surface_get_material(0).albedo_texture = insigna_wing
