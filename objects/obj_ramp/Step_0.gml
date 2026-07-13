/// @description Script
	
	if(player_collide_object(C.MAIN))
	{
		//If angle is in the range
		if(obj_player.ground_angle >= angle_start && obj_player.ground_angle <= angle_end)
		{
			obj_player.on_edge = true;
		}
	}