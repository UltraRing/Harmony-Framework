/// @description Main player
	//Change character
	character = global.character;
	
	//Hitbox variables
	hitbox_top_offset = 0;
	hitbox_left_offset = 0;
	hitbox_bottom_offset = 0;
	hitbox_right_offset = 0;
	
	//Player input scripts
	player_get_input();
	
	//Hande player physics values
	player_handle_physics();
	
	//prevent player for dieing in the bonus stage
	if (instance_exists(obj_bonus_cont)) 
	{
		disable_death = true	
	}
	
	//check if player should be able to turn super
	allow_super = true
	if (input_disable || obj_level.disable_timer || instance_exists(obj_bonus_cont) || instance_exists(obj_shield))
	{
		allow_super = false	
	}
	
	//Handle invincibility and speed shoes
	player_inv_speed();
	
	//Step movement for sticking on the collision
	steps = min(1 + abs(round(x_speed / PLAYER_STEPS_AMOUNT)) + abs(round(y_speed / PLAYER_STEPS_AMOUNT)), PLAYER_MAX_STEPS);
	
	//Cancel when in debug mode
	if(debug)
	{
		player_debug();
		exit;	
	}

	//Include step movement
	repeat(steps)
	{
		//Handle player movement:
		player_movement();
		
		//Handle how player changes floor modes:
		if(!PLAYER_ALT_COLLISION_MODE)
			player_mode();
		
		//Handle player terrain collision:
		player_collision();
	}
	
	//Handle how player is controlled:
	player_control();

	//Update player's animator
	animator_update(animator);
	
	//Handle player states
	player_states();
		
	//Player facing direction
	player_direction();
	
	//Handle partial visual rotation
	player_visual_angle();
	
	//Various hitbox cases
	_player_hitbox(ground);
	
	//Misc. player stuff
	player_misc();
	
	//Handle player's interaction with water
	player_water();
	
	// Update the recorder
	instance_recorder_update(recorder);