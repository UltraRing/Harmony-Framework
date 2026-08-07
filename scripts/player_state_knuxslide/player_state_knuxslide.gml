function player_state_knuxslide(){
	//Change flags
	direction_allow = false;
	movement_allow = false;
	attacking = true;
	
	// Change the direction depending on ground speed
	if(sign(ground_speed) != 0)
		facing = sign(ground_speed);
	
	//Change animation
	if(ground_speed != 0)
	{
		animation_play(animator, ANIM.KNUXSLIDE);
	}
	
	//Get grounded
	if(ground && ground_angle > 45 && ground_angle < 315)
	{
		state = player_state_normal;
		control_lock = 4;
		exit;
	}
	
	//Ground event
	if(ground)
	{
		//Decelerate
		ground_speed = math_approach(ground_speed, 0, 0.125);
		
		//Create dust effect
		if(FRAME_TIMER mod 8 == 0 && ground_speed != 0)
		{
			sound_play(sfx_slide);
			
			if(global.chaotix_dust_effect)
			{
				instance_create_particle(x - hitbox_w * -facing, y + hitbox_h, spr_dust_effect, 0.4, depth-1, irandom_range(0.4, 1.2) * facing, -2, 0, 0.15);
			}
			else
			{
				instance_create_particle(x - hitbox_w * -facing, y + hitbox_h, spr_effects_dust, 0.2, depth-1, 0, 0, 0, 0);	
			}
		}
	}
	
	//Make knuckles fall if detached
	if(!ground)
	{
		state = player_state_knuxfall;	
		exit;
	}
	
	//Change animation
	if(ground_speed == 0) 
	{
		animation_play(animator, ANIM.KNUXGETUP);
	}
	
	//Reset the state
	if(animation_is_playing(animator, ANIM.KNUXGETUP) && animation_has_finished(animator)) 
	{
		animation_play(animator, ANIM.STAND);
		state = player_state_normal;
		exit;
	}
}