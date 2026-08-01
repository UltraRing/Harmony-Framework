	
	x += x_speed;
	
	x_speed += 0.05 * facing;
	x_speed = clamp(x_speed, -2, 2);
	
	
	if(x > obj_camera.target_right - 128)
		facing = -1;
		
	if(x < obj_camera.target_left + 128)
		facing = 1;