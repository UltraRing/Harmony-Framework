function player_state_spindash(){
	
	//Create dust effect
	if(FRAME_TIMER mod 4 == 0 && global.chaotix_dust_effect) 
	{
		instance_create_particle(x - hitbox_w * facing, y + hitbox_h, spr_dust_effect, 0.4, depth-1, (2.5 * facing) * dcos(random_range(180, 270)), 2.5 * dsin(random_range(180, 270)));
	}
	
	//Animate spindash dust effect
	spindash_dust_frames += 0.5;
	spindash_dust_frames %= sprite_get_number(spr_effect_spindash);
	
	//Stop the movement
	ground_speed = 0;
	
	//Change flags
	direction_allow = 1 - ground;
	movement_allow = 1 - ground;
	attacking = true;
	
	//Change animation
	animation_play(animator, ANIM.SPINDASH);
	
	//Subtract the spindash rev
	spindash_rev -= spindash_rev / 32;
	spindash_pitch -= spindash_pitch / 28;
	
	//Rev up!
	if(press_action)
	{
		//Play spindash sound
		sound_play(sfx_spindash);
		
		//Reset the spindash frame
		if(animation_is_playing(animator, ANIM.SPINDASH))
		{
			animation_set_frame(animator, 0);
		}
		
		//Update spindash rev
		spindash_pitch = min(spindash_pitch + 1, 12);
		spindash_rev = min(spindash_rev + 2, 9);
		
		//Change the spindash sound pitch
		if(spindash_pitch != 1) 
		{
			audio_sound_pitch(sfx_spindash, 1 + spindash_pitch / 13);
		}
	}
	
	//Release the spindash
	if(!hold_down)
	{
		//Stop the spindash sound
		audio_stop_sound(sfx_spindash);
		
		//Play the release sound
		sound_play(sfx_release);
		
		//Lag the camera
		camera_set_lag(20 - spindash_rev);
		
		//Set the ground speed and update the state
		if(ground)
		{
			ground_speed = (8+(floor(spindash_rev)/2)) * facing;
		}
		else
		{
			x_speed = (8+(floor(spindash_rev)/2)) * facing;
		}
		
		// Play the rolling animation
		animation_play(animator, ANIM.ROLL);
		
		// Update the hitbox
		_player_hitbox(ground);
		
		state = player_state_roll;
	}
}