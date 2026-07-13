/// @description Script
	
	//If player fucking dies stop executing
	if(obj_player.knockout_type == K_DIE || obj_player.knockout_type == K_DROWN) exit;
	
	//Change the boundary
	if(player_collide_object(C.MAIN))
	{
		if(!triggered)
		{
			obj_camera.target_bottom = bbox_bottom;
		}
		triggered = true;	
	}else
	{
		if(triggered)
		{
			obj_camera.target_bottom = room_height;	
		}
		triggered = false;	
	}