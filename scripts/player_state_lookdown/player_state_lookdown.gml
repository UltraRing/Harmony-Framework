function player_state_lookdown(){
	
	//Change flags
	movement_allow = false;
	direction_allow = false; 
	
	//Change animation
	animation_play(animator, ANIM.LOOKDOWN);
	
	//Slow crouch
	ground_speed = math_approach(ground_speed, 0, friction_speed);
	
	//Slope influence
	if(ground_angle >= 40 && ground_angle <= 320) 
	{
		ground_speed -= 0.125 * dsin(ground_angle);
	}
	
	//Stop crouching when releasing the down key
	if(!hold_down) 
	{
		state = player_state_normal;
		exit;
	}
	
	//Trigger the spindash
	if(press_action && global.use_spindash)
	{
		//Reset the spindash pitch
		audio_sound_pitch(sfx_charge, 1);
		
		//Change animation
		animation_play(animator, ANIM.SPINDASH);
	
		//Reset variables
		spindash_rev = 0;
		spindash_pitch = 0;
		spindash_dust_frames = 0;
		
		//Update the state
		state = player_state_spindash;
		sound_play(sfx_charge);
		exit;
	}
	
	//Trigger rolling
	if(player_check_roll())
		exit;
	
	if(player_check_jump())
		exit;
}