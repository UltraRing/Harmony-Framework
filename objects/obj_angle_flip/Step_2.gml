/// @description Flip player
	if(player_collide_object(C.MAIN))
	{
		if(!triggered)
		{
			obj_player.ground_angle += 180;
			obj_player.visual_angle += 180;
			obj_player.ground_angle %= 360;
			obj_player.ground_speed *= -1;
			with(obj_player)
			{
				disable_mode = true
				player_reposition_mode()
			}
			
		}
		triggered = true;	
	}else
	{
		triggered = false;	
	}