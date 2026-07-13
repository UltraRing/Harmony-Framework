function player_state_wallclimb(){
	
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
	var wallCol = collision_get_distance(x + wall_w * facing, y, facing == 1 ? CMODE.LWALL : CMODE.RWALL, plane, false);
		
	//Has reached the ground
	if(ground && hold_down)
	{
		if(ground_angle > 45 && ground_angle < 315)
		{
			player_mode();
			animation_play(animator, ANIM.ROLL);
			play_sound(sfx_roll);
			control_lock = 4;
			ground_speed = -2.5 * dsin(ground_angle);
			state = player_state_roll;
			exit;
		}
		
		state = player_state_normal;
		exit;
	}
	
	//When there's no more wall
	if(wallCol > 14)
	{
		if(mov == -1 || mov == 0)
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
		play_sound(sfx_jump);
		exit;
	}
}