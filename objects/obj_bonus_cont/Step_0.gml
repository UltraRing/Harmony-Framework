	// Exiting the bonus stage
	with(obj_bonus_exit)
	{
		// Colliding with the trigger
		if(player_collide_object() && !instance_exists(obj_titlecard_bonus) && !other.exiting)
		{
			// Disable the inputs
			obj_player.visible = false;	
			obj_player.input_disable = true;
			
			// Fade back to the level
			fade_to_room(global.previous_room, 2, FADE.BLACK, 30);
			
			// Set the flag
			other.exiting = true;
			
			// Store important player data
			if (instance_exists(obj_player))
			{
				obj_player.input_disable = true
				global.store_player_state.combinering = obj_player.combinering
				global.store_player_state.shield = obj_player.shield
				global.store_player_state.rings = global.rings
			}
		}
	}