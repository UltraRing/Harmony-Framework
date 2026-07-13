/// @description Script
	if(sign(image_xscale) = 1)
	{
		if(obj_player.ground_speed > 0 && player_collide_object(C.MAIN))
		{
			//Play the sound
			if(obj_player.state != player_state_roll)
			{
				play_sound(sfx_roll);	
			}
			
			obj_player.force_roll = true;
			obj_player.state = player_state_roll;
		}
		
		if(obj_player.ground_speed < 0 && player_collide_object(C.MAIN))
		{
			obj_player.force_roll = false;	
		}
	}
	else
	{
		if(obj_player.ground_speed < 0 && player_collide_object(C.MAIN))
		{
			//Play the sound
			if(obj_player.state != player_state_roll)
			{
				play_sound(sfx_roll);	
			}
			
			obj_player.force_roll = true;
			obj_player.state = player_state_roll;
		}
		
		if(obj_player.ground_speed > 0 && player_collide_object(C.MAIN))
		{
			obj_player.force_roll = false;	
		}
	}