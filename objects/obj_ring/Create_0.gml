/// @description Values
	x_speed = 0;
	y_speed = 0;
	magnet = false;
	ringloss = false;
	culling = true;
	timer = 0;
	animation_speed = 0.55;
	plane = PLANE.A;
	image_speed = 0;
	
	if (global.store_object_state[| id]) 
	{
		instance_destroy()	
	}

	
	instance_register_culling();