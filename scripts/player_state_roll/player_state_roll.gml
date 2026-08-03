function player_state_roll(){
	
	//Change animation and speed
	animation_play(animator, ANIM.ROLL);
	if(ground && character != CHAR_TAILS)
	{
		animation_set_duration(animator, floor(max(0, 4-abs(ground_speed))));
	}
	
	//Change flags
	attacking = true;
	
	//Change on ground flag
	if(ground)
	{
		movement_allow = false;
	}
	
	//Rolling physics
	if(sign(ground_speed) = sign(dsin(ground_angle))) 
	{
		ground_speed -= roll_influence_up * dsin(ground_angle);
	}
	else 
	{
		ground_speed -= roll_influence_down * dsin(ground_angle);
	}
	
	//Rolling driction
	ground_speed = math_approach(ground_speed, 0, roll_friction);
	
	//Trigger jump
	if(player_check_jump())
		exit;
	
	//Stop rolling
	if(ground_angle < 40 || ground_angle > 320)
	{
		if(ground_speed == 0 && !force_roll && ground) 
		{
			state = player_state_normal;
			
			// A hack
			script_execute(state);
			
			// Update the hitbox
			_player_hitbox(true);
			exit;
		}
	}
	
	//Get input
	var mov = hold_right - hold_left;
	
	//Turning to different direction
	if(mov = -sign(ground_speed) && !force_roll) 
	{
		ground_speed -= 0.125 * -mov;	
	}
	
	//Force roll push
	if(abs(ground_speed) < 0.5 && force_roll)
	{
		if(ground_angle < 20 || ground_angle > 360 - 20)
		{
			ground_speed = 2 * facing;
		}
	}
	
	//Rolling speed cap
	ground_speed = clamp(ground_speed, -roll_speed_cap, roll_speed_cap);
}

function player_check_roll()
{
	//Trigger rolling
	if(hold_down && abs(ground_speed) > 1 && ground)
	{
		//Play the rolling animation
		animation_play(animator, ANIM.ROLL);
		
		//Update the state
		state = player_state_roll;
		idle_timer = 0;
		
		// Update the hitbox
		_player_hitbox(true);
		
		//Play the sound
		sound_play(sfx_roll);
		return true;				// Needed for exit
	}
}