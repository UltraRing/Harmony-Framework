function player_state_normal()
{
	//Add the idle timer
	if(ground_speed == 0 && !input_disable && ground)
		idle_timer++;
	else
		idle_timer = 0;	
	
	//Trigger look down:
	if(ground && abs(ground_speed) < 0.5 && mode = 0 && hold_up)
	{
		state = player_state_lookup;
		idle_timer = 0
		exit;
	}
	
	if(skid_timer <= 0)
	{
		//Value for the animation
		var anim = ANIM.STAND;
	
		//Default animation:
		if (ground)
		{
			anim = ANIM.STAND;
		}
		else
		{
			if(!animation_is_playing(animator, ANIM.BREATHE))
				anim = ANIM.WALK;
		}
		
		//Walking animation:
		if(abs(ground_speed) > 0 && abs(ground_speed) <= 6)
		{
			anim = ANIM.WALK;
		
			//Change animation duration when player is only on the ground:
			if(ground)
			{
				animation_set_duration(animator, (max(0, 8-abs(obj_player.ground_speed))));
			}
		}
		
		//Running animation:
		if(abs(ground_speed) >= 6)
		{
			//Update the animation
			anim = ANIM.RUN;
		
			//Change animation duration when player is only on the ground:
			if(ground)
			{
				switch(character)
				{
					//Tails has different running animation duration
					case CHAR_TAILS: 
						animation_set_duration(animator, 1); 
					break;
				
					//Animation duration for everyone expect tails
					default: 
						animation_set_duration(animator, (max(0, 8-abs(obj_player.ground_speed)))); 
					break;
				}
			}
		}
		
		//Running animation:
		if(abs(ground_speed) >= 12)
		{
			anim = ANIM.MAXRUN;
		}
	
		//Idle animations
		switch(character)
		{
			case CHAR_SONIC:
				if(idle_timer > 160)
				{
					anim = ANIM.WAIT;	
				}
			break;
		
			case CHAR_TAILS:
				if(idle_timer > 240)
				{
					anim = ANIM.WAIT;
				}
			break;
		
			case CHAR_KNUX:
				if(idle_timer > 160)
				{
					anim = ANIM.WAIT;	
				}
			break;
		}
		
		
		// Trigger the skidding
		if(abs(ground_speed) > 4 && mode == COLLISION_MODE.FLOOR && (hold_right - hold_left) == -sign(ground_speed) && control_lock == 0 && ground && !water_run)
		{
			skid_timer = 24;
			
			if(sign(ground_speed) != 0)
				facing = sign(ground_speed);
				
			sound_play(sfx_skid);
		}
		
		var ledgeSensor = collision_get_distance(x, y + hitbox_h, mode, plane, true);	
		if(ledgeSensor > 14 && ground_speed == 0 && ground)
		{
			var left = collision_get_distance(x - hitbox_w, y + hitbox_h, mode, plane, true);
			var right = collision_get_distance(x + hitbox_w, y + hitbox_h, mode, plane, true);
			
			if(left > 14 && !on_object || on_object && ledge == -1 && on_object_count == 1)
				anim = facing = 1 ? ANIM.LEDGE1 : ANIM.LEDGE2;
			
			if(right > 14 && !on_object || on_object && ledge == 1 && on_object_count == 1)
				anim = facing = 1 ? ANIM.LEDGE2 : ANIM.LEDGE1;
		}

		// Wall sensors
		var wall = collision_get_distance(x + (wall_w * facing), y + wall_h, facing == 1 ? COLLISION_MODE.LEFT_WALL : COLLISION_MODE.RIGHT_WALL, plane);
		
		//Get input presses
		var mov = hold_right - hold_left;
		
		//Pushing animation
		if(mov = facing && ground && abs(ground_speed) <= x_accel + 0.5 && mode == COLLISION_MODE.FLOOR)
		{
			if(wall < 1 || (pushing == COLLISION.LEFT && hold_right) || (pushing == COLLISION.RIGHT && hold_left))
			{
				anim = ANIM.PUSH;
			}
		}
		
		// Play the animations
		if(!animation_is_playing(animator, ANIM.BREATHE) || animation_has_finished(animator) && animation_is_playing(animator, ANIM.BREATHE))
			animation_play(animator, anim);
	}
	else
	{
		// Disable directions
		direction_allow = false;
		
		// No more skid
		if(!ground || mode != COLLISION_MODE.FLOOR)
			skid_timer = 0;
		
		// Skidding
		if(sign(ground_speed) == facing)
		{
			// Play the skid animation
			animation_play(animator, ANIM.SKID);
			
			// Create skid dust
			if(FRAME_TIMER % 5 == 0) 
			{
				if(global.chaotix_dust_effect)
				{
					instance_create_particle(x - hitbox_w * -facing, y + hitbox_h, spr_dust_effect, 0.4, depth-1, irandom_range(0.4, 1.2) * facing, -2, 0, 0.15);
				}
				else
				{
					instance_create_particle(x - hitbox_w * -facing, y + hitbox_h, spr_effects_dust, 0.2, depth-1, 0, 0, 0, 0);	
				}
			}
		}
		else	// Skid turning
		{
			// Play the skid turn
			animation_play(animator, ANIM.SKIDTURN);	
			
			// If skid turning is finished, stop skidding
			if(animation_has_finished(animator))
			{
				animation_play(animator, ANIM.WALK);
				skid_timer = 0;	
				facing *= -1;
			}
		}
		
		// Get the player inputs
		var i = hold_right - hold_left;
		
		// Subtract from the skid timer
		if(i == facing || i == 0)
			skid_timer--;
	}

	
	//Trigger rolling
	if(player_check_roll())
		exit;
	
	//Trigger jump
	if(player_check_jump())
		exit;
}