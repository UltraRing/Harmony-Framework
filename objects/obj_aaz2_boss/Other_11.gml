	
	var topSpd = 2;
	
	x += x_speed;
	
	x_speed += 0.05 * facing;
	x_speed = clamp(x_speed, -topSpd, topSpd);
	
	spike_y = spike_y_target;
	
	if(x > obj_camera.target_right - 32)
		facing = -1;
		
	if(x < obj_camera.target_left + 32)
		facing = 1;
	
	// Don't even bother finding anything when turning
	//if(abs(x_speed) != topSpd)
	//	exit;
	
	// Patrol area
	var realX = (round((x + 16) / 32) * 32) - 16;
	var c = collision_rectangle(realX - 16, obj_camera.target_top, realX + 16, obj_camera.target_bottom, obj_aaz_boss_block, true, false);
	
	var player = player_find();
	var f = sign(x_speed);
	
	if(point_in_rectangle(player.x, player.y, realX - 16, obj_camera.target_top, realX + 16, obj_camera.target_bottom) && !found_collision && c)
	{
		if(f == 1 && x < c.x || f == -1 && x > c.x)
			found_collision = c;
	}
	
	if(found_collision)
	{
		if(f == 1 && x > found_collision.x)
		{
			boss_state = AAZ2_BSTATE.SPIKE_DROP;
			x = found_collision.x;
			exit;
		}
		
		if(f == -1 && x < found_collision.x)
		{
			boss_state = AAZ2_BSTATE.SPIKE_DROP;
			x = found_collision.x;
			exit;
		}	
	}