/// @description Flip player
	if(player_collide_object(C.MAIN))
	{
		if(!triggered && obj_player.mode = 3)
		{
			obj_player.ground_angle = 90;
			obj_player.visual_angle = 90;
			obj_player.ground_speed *= -1;
		}
		triggered = true;	
	}else
	{
		triggered = false;	
	}