/// @description Script
	//Update the animator
	animator_update(animator);
	
	var c = player_act_solid();
	var player = player_find(0);
	var m = detach_sides ? 0 : player.mode;
	
	if(c == C.TOP && sign(image_yscale) == 1)
	{
		animator.animation_finished = false;
		triggered = true;
		
		switch(m)
		{
			case 0:
			player.ground = false;
			player.y_speed = -spring_power;
			player.state = player_state_spring;
			break;
			
			case 1:
			case 3:
			player.facing = player.x_dir;
			player.ground_speed = spring_power * player.x_dir;
			break;
		}
		
		play_sound(sfx_spring);
	}
	
	if(c == C.BOTTOM && sign(image_yscale) == -1)
	{
		animator.animation_finished = false;
		triggered = true;
		
		switch(m)
		{
			case 0:
			player.ground = false;
			player.y_speed = spring_power;
			player.state = player_state_normal;
			break;
			
			case 1:
			case 3:
			player.facing = -player.x_dir;
			player.ground_speed = -spring_power * player.x_dir;
			break;
		}
		
		play_sound(sfx_spring);
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