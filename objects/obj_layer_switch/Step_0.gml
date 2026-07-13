/// @description Collision Test
	if (player_collide_object(C.MAIN))
	{
		if (!ground_only || (ground_only && obj_player.ground)) {
			switch(layer_type)
			{
				case "Layer A":
					obj_player.plane = 0;
				break;
			
				case "Layer B":
					obj_player.plane = 1;
				break;
			
				case "From A to B":
				if(obj_player.ground_speed > 0) obj_player.plane = 1; else obj_player.plane = 0;
				break;
			
				case "From B to A":
				if(obj_player.ground_speed > 0) obj_player.plane = 0; else obj_player.plane = 1;
				break;
			}
		}
	}