function player_state_glide(){
	
	//Change flags
	movement_allow = false;
	direction_allow = false;
	gravity_allow = false;
	attacking = true;
	
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
	
	//Accelerate
	if(knuckles_angle == 90 || knuckles_angle == -90)
	{
		if (!super) {
			glide_speed += 0.015625;
		} else {
			glide_speed += 0.046875;
		}
	}
	
	//Limit the glide speed
	glide_speed = clamp(glide_speed, -24, 24);
	
	//Get input
	var mov = hold_right - hold_left;
	
	//Glide turn animation
	if(mov == -1 && facing == 1 || mov == 1 && facing == -1)
	{
		facing *= -1;
		animation_set_frame(animator, 0);

		animation_play(animator, ANIM.KNUXGLIDETURN);
	}
	
	//Turn glide
	if(mov != 0) 
	{
		facing = mov;
	}
	
	//Adjust angle
	knuckles_angle = math_approach(knuckles_angle, 90 * facing, 2.8125);
	
	if (animation_is_playing(animator, ANIM.KNUXGLIDETURN)) {
		if (facing == 1)
		{
			animation_set_frame(animator, 2 + (knuckles_angle/ 45));
		} else 
		{
			animation_set_frame(animator, 5 - (2 + (knuckles_angle/ 45)));
		}
	}
	
	if(animation_has_finished(animator) && animation_is_playing(animator, ANIM.KNUXGLIDETURN))
	{
		
		animation_play(animator, ANIM.KNUXGLIDE);	
	}
	
	//Attach to the wall
	var wallCol = collision_get_distance(x + wall_w * facing, y, facing == 1 ? CMODE.LWALL : CMODE.RWALL, plane, false);
	if(wallCol < 1)
	{
		//Change direction
		play_sound(sfx_grab);
		state = player_state_wallclimb;
		exit;
	}
	
	//Get grounded
	if(ground && ground_angle > 45 && ground_angle < 315)
	{
		state = player_state_normal;
		control_lock = 4;
		exit;
	}
	
	//Trigger falling if player is not pressing action button
	if(!hold_action)
	{
		ceiling_lock = 4;
		x_speed *= 0.25;
		y_speed = 0;
		state = player_state_knuxfall;
		exit;
	}
	
}