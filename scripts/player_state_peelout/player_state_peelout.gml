function player_state_peelout(){
	
	//Create dust effect
	if(FRAME_TIMER mod 3 == 0 && global.chaotix_dust_effect) 
	{
		instance_create_particle(x - hitbox_w * facing, y + hitbox_h, spr_effect_dust, 0.4, depth-1, (3 * facing) * dcos(random_range(180, 270)), 3 * dsin(random_range(180, 270)));
	}
	
	//Stop movement
	ground_speed = 0;
	
	//Change flags
	direction_allow = 1 - ground;
	movement_allow = 1 - ground;
	
	//Add rev value and clamp it
	spindash_rev += 1;
	spindash_rev = min(spindash_rev, 30);
	
	//Temp value for animation
	var anim = ANIM.WALK;
	
	//Change animations
	anim = ANIM.WALK;
	if(spindash_rev >= 15) 
	{
		anim = ANIM.RUN;
	}
	if(spindash_rev = 30) 
	{
		anim = ANIM.MAXRUN;
	}
	
	//Play the animations
	animation_play(animator, anim);
	
	//Release the peel out
	if(!hold_up)
	{
		//Stop the peelout charge audio
		audio_stop_sound(sfx_peelout_charge);
		
		//Play the release sound
		sound_play(sfx_peelout_release);
		
		//Set player's speed and back to normal state
		ground_speed = (2+(spindash_rev / 2.9)) * facing;
		if(!ground)
		{
			x_speed = (2+(spindash_rev / 2.9)) * facing;
		}
		state = player_state_normal;	
	}
}