function player_state_wallclimb()
{
	//Change flags
	movement_allow = false;
	direction_allow = false;
	gravity_allow = false;
	
	
	//Change direction
	image_xscale = facing;
	
	//Get input presses
	var mov = hold_down - hold_up;
	
	//Move up and down
	y_speed = (1 + super) * mov;
	x_speed = 0;

	// Grounded flag fix
	if(y_speed <= 0)
		ground = false;
	
	//Change animation
	if(y_speed != 0) 
	{
		animation_play(animator, sign(y_speed) == 1 ? ANIM.KNUXCLIMBDOWN : ANIM.KNUXCLIMBUP);
	}
	else
	{
		animation_play(animator, ANIM.KNUXCLIMBIDLE);	
	}
	
	// Wall collision
	var wallCol = collision_get_distance(x + wall_w * facing, max(y,obj_camera.limit_top), facing == 1 ? COLLISION_MODE.LEFT_WALL : COLLISION_MODE.RIGHT_WALL, plane, false);
	var wallColUpper = collision_get_distance(x + wall_w * facing,  max(y - 4,obj_camera.limit_top), facing == 1 ? COLLISION_MODE.LEFT_WALL : COLLISION_MODE.RIGHT_WALL, plane, false);
	var wUpperAngle = math_uangle(collision_get_angle(x + wall_w * facing,  max(y - 4,obj_camera.limit_top), facing == 1 ? COLLISION_MODE.LEFT_WALL : COLLISION_MODE.RIGHT_WALL, plane));

	//Has reached the ground
	if(ground && hold_down)
	{
		if(ground_angle > 45 && ground_angle < 315)
		{
			x += (wall_w - hitbox_h) * x_dir;
			player_mode();
			animation_play(animator, ANIM.ROLL);
			sound_play(sfx_roll);
			control_lock = 4;
			ground_speed = -2.5 * dsin(ground_angle);
			state = player_state_roll;
			exit;
		}
		
		state = player_state_normal;
		exit;
	}
	
	var detachDist = floor(wUpperAngle) < 48 ? 0 : 14;
	
	//When there's no more wall
	if(wallCol > detachDist)
	{
		if(wallColUpper > detachDist && mov == -1)
		{
			//If using smooth scroll
			if(global.knux_camera_smooth)
			{
				obj_camera.mode = 2;
			}
			
			animation_set_frame(animator, 0);
			control_lock = 5;
			clamp_storex = x
			clamp_storey = y
			state = player_state_ledgeclimb;
			exit;
		}
		
		if(mov == 1)
		{
			state = player_state_knuxfall;
			exit;
		}
		
		if (wallCol >= 16) 
		{
			// detach anyway because josh was like "thats bad"
			state = player_state_knuxfall;
			exit;
		}
	}
	
	x += wallCol * facing;
	
	//Jump off the wall
	if(press_action && control_lock = 0)
	{
		facing *= -1;
		x_speed = 4 * facing;
		y_speed = -4;
		state = player_state_jump;
		animation_play(animator, ANIM.ROLL);
		sound_play(sfx_jump);
		exit;
	}
}