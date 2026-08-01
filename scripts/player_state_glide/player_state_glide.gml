function player_state_glide(){
	
	//Change flags
	movement_allow = false;
	direction_allow = false;
	gravity_allow = false;
	attacking = true;
	
	static glide_direction = facing
	
	//Trigger the slide
	if(ground)
	{
		state = player_state_knuxslide;
		exit;
	}
	
	//Adjust y speed
	if(y_speed < 0.5) 
	{
		y_speed += 0.125;
	}
	if(y_speed > 0.5) 
	{
		y_speed -= 0.125;
	}
	
	//Force x speed to glide speed
	x_speed = glide_speed * dsin(knuckles_angle);
	
	if(knuckles_angle == 90 || knuckles_angle == -90)
	{
		glide_speed += !super ? 0.015625 : 0.046875; //accelerate
		glide_direction = sign(knuckles_angle);
	}
	
	//Limit the glide speed
	glide_speed = clamp(glide_speed, -24, 24);
	
	//Get input
	var mov = hold_right - hold_left;
	
	
	//Turn glide and facing direction
	if(mov != 0)
	{
		glide_direction = mov
	}
	
	//Adjust angle
	knuckles_angle = math_approach(knuckles_angle, 90 * glide_direction, 2.8125);
	
	/*
	To make a glide turn based on glide angle,
	without bloating the turn animation to have frames where knuckles looks head on, 
	we do some fractions to act like they are there.
	
	this just makes the transition between turning and gliding look nice but not a slog either.
	This code should work as intended as long as the turn frame count is a ODD number.
	*/
	
	if(KNUCKLES_S3_GLIDE_TURN)
	{
		//Determine Glide turn frame
		var glide_fake_frame_count = animation_get_frame_count(animator, ANIM.KNUXGLIDETURN) + 2;
		var animation_glide_frame = abs((((90 * facing) + knuckles_angle) / 90) / 2) * (glide_fake_frame_count-1);
	
		var animation_glide_percent = animation_glide_frame / (glide_fake_frame_count-1);
	
		//check if you should use turn animation
		if(animation_glide_percent > (1 / glide_fake_frame_count) && animation_glide_percent < ((glide_fake_frame_count - 1) / glide_fake_frame_count))
		{
			if (!animation_is_playing(animator, ANIM.KNUXGLIDETURN))
			{
				facing = sign(knuckles_angle);
				animation_play(animator,ANIM.KNUXGLIDETURN);
			}	
		} 
		else 
		{
			if (animation_is_playing(animator, ANIM.KNUXGLIDETURN))
			{
				animation_play(animator,ANIM.KNUXGLIDE);
				facing = sign(knuckles_angle);
			}
		}
	
		//Adjusting glide turn animation based on glide angle
		if (animation_is_playing(animator, ANIM.KNUXGLIDETURN))
			animation_set_frame(animator, round(animation_glide_frame) - 1);
	}
	else
	{
		// Glide turn animation
		if(mov == -1 && facing == 1 || mov == 1 && facing == -1)
		{
			facing *= -1;
			animation_set_frame(animator, 0);
			animation_play(animator, ANIM.KNUXGLIDETURN);
		}
		
		if(animation_has_finished(animator) && animation_is_playing(animator, ANIM.KNUXGLIDETURN))
			animation_play(animator, ANIM.KNUXGLIDE);	
	}
	
	
	//Attach to the wall
	var wallCol = collision_get_distance(x + wall_w * facing, max(y,obj_camera.limit_top), facing == 1 ? COLLISION_MODE.LEFT_WALL : COLLISION_MODE.RIGHT_WALL, plane, false);
	if(wallCol < 1)
	{
		//Change direction
		sound_play(sfx_grab);
		state = player_state_wallclimb;
		exit;
	}
	
	//Get grounded
	if(ground && ground_angle > 45 && ground_angle < 315)
	{
		facing = sign(x_speed)
		state = player_state_normal;
		control_lock = 4;
		exit;
	}
	
	//Trigger falling if player is not pressing action button
	if(!hold_action)
	{
		ceiling_lock = 4;
		facing = sign(x_speed)
		x_speed *= 0.25;
		y_speed = 0;
		state = player_state_knuxfall;
		exit;
	}
	
}