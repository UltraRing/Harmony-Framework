/// @description Script
	//Update the animator
	animator_update(animator);
	
	//Get player's instance
	var player = player_find(0);
	var c = player_act_solid()
	
	//Get player's speed
	var player_speed = player.x_speed;
	
	if(c == C.LEFT && sign(image_xscale) == 1 || c == C.RIGHT && sign(image_xscale) == -1)
	{
		triggered = true;
		animator.animation_finished = false;
		play_sound(sfx_spring);
		
		if(player.ground && !detach_sides || player.ground && player.mode == 0 && detach_sides)
		{
			player.ground_speed = -spring_power * sign(image_xscale) * player.y_dir;
			player.facing = -sign(image_xscale) * player.y_dir;
			player.control_lock = 20;
			player.skid_timer = 0;
		}
		else
		{
			player.ground = false;
			player.x_speed = -spring_power * sign(image_xscale);
			player.facing = -sign(image_xscale);	
		}
		
		//Knuckles fix
		if(player.state = player_state_glide || player.state = player_state_knuxslide || player.state = player_state_wallclimb) 
		{
			player.state = player_state_normal;
		}
	}
	
	//Stop the animation
	if(!triggered) 
	{
		animation_set_frame(animator, 0);
	}
	
	//Reset the trigger
	if(animation_has_finished(animator) && triggered) 
	{
		triggered = false;
	}