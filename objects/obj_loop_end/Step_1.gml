/// @description Loop back to the start trigger
	if(obj_player.x >= x)
	{
		with(par_background)
			// Offset the background layers
			for(var i = 0; i <= bg_id; i++)
				offset_x[i] -= (obj_player.x - obj_loop_start.x) * (1-factor_x[i]);
		
		// Offset the position of the camera and the player
		obj_camera.target_x -= obj_player.x - obj_loop_start.x;
		obj_player.x -= obj_player.x - obj_loop_start.x;
	}