/// @description Script
	
	//Render behind the player
	depth = obj_player.depth + 10
	
	//Add angle value
	angle = (angle + spin_speed) mod 360;
	
	//Get the player
	var player = instance_nearest(x, y, obj_player);
	
	//Trigger the spin
	if(player.x > x - player.ground_speed && !triggered)
	{
		//Play sound
		sound_play(sfx_signpost);
		
		//Lock the camera
		obj_camera.target_left = x - obj_camera.center_x;
		obj_camera.target_right = x + obj_camera.center_x;
		
		//Spin
		spin_speed = 16;
		triggered = true;
		
		//Sonic be too fast!!!
		if (player.ground_speed > 6)
		{
			ground = false;
			y_speed = abs(player.ground_speed) / -3;
		}
		obj_level.disable_timer = true;
	}
	
	//Slow dow the spin
	if(triggered && ground)
	{
		//Slow down normally
		spin_speed = max(spin_speed - 0.126, 4);
		
		//Patch
		if(spin_speed <= 4 && angle >= 170 && angle <= 180)
		{
			angle = 180;
			spin_speed = 0;
		}
	}
	
	//Bump the sign
	if(triggered && y_speed > 0 && player_collide_object(COLLISION.TOP) && player.y_speed < 0 && !player.ground)
	{
		sound_play(sfx_twinkle);
		instance_create_score(0, -48);
		global.score += 100;
		obj_level.badnik_chain = 1;
		
		y_speed = -2;
		x_speed = (x - player.x) / 16;
	}
	
	//Update speeds
	x += x_speed;
	y += y_speed;
	
	//Add gravity
	if(!ground) 
		y_speed += 0.046875;
	
	//Ground detection
	var c = collision_get_distance(x, y - 1, COLLISION_MODE.FLOOR, PLANE.A, true);
	if(c < 0 && !ground)
	{
		y += c;
		ground = true;
		x_speed = 0;
		y_speed = 0;
		sound_play(sfx_slide);
	}
	
	//Wall detection
	c = collision_get_distance(x + 8 * sign(x_speed), y - 8, sign(x_speed) ? COLLISION_MODE.LEFT_WALL : COLLISION_MODE.RIGHT_WALL, PLANE.A, true);
	if(c < 0)
	{
		x += c;
		x_speed *= -1;
	}
	
	
	//Sparkle effects
	if(angle != 180 && triggered && FRAME_TIMER mod 12 == 0)
	{
		instance_create_particle(x + random_range(-24, 24), (y - 32) + random_range(-16, 16), spr_ring_sparkle, 0.2);
		instance_create_particle(x + random_range(-24, 24), (y - 32) + random_range(-16, 16), spr_ring_sparkle, 0.2);
	}
	
	
	//Screen sides bounce
	if(x < obj_camera.limit_left + 32 && x_speed < 0 || x > obj_camera.limit_right - 32 && x_speed > 0)
	{
		x_speed *= -1;
	}
	var monitor = noone;
	
	//Get grounded monitor collision
	monitor = instance_place(x, y, obj_monitor_signpost);
	
	//Hidden monitors event
	if(monitor)
	{
		if(y_speed >= 0 && triggered && !ground)
		{
			var new_monitor = instance_create_depth(monitor.x, monitor.y, depth-30, obj_monitor);
			new_monitor.ground = false;
			new_monitor.y_speed = -4;
			new_monitor.monitor_type = monitor.monitor_type;
			new_monitor.culling_struct.type = CULL_TYPE.DISABLE;
			
			y_speed = -2.75;
			instance_destroy(monitor);	
			sound_play(sfx_bubble_jump);
			global.monitor_store[global.monitor_id] = new_monitor;
			global.monitor_id += 1;
			
		}
	}

	//Create act clear object
	if(!instance_exists(obj_act_clear) && triggered && angle = 180 && spin_speed = 0) 
	{
		instance_create_depth(0, 0, 0, obj_act_clear);
	}