	animator_update(animator);
	
	if(player_find(0).x > x - 64 && !entrance_trigger)
	{
		entrance_trigger = true;
		music_set_fade(FADE.OUT, 2);
		
		// yes, horizontal boundaries are supposed to be hardcoded
		obj_camera.target_left = xstart - (512 / 2);
		obj_camera.target_right = xstart + (512 / 2);
		
		//obj_camera.target_top = obj_camera.target_bottom - CAMERA_VIEW_H;
		//obj_camera.target_bottom = ystart + (CAMERA_VIEW_H / 2);
	}
	
	if(entrance_trigger)
	{
		entrance_timer++;	
		
		// The boss has begun
		if(entrance_timer == 60)
		{
			// Boss init code
			visible = true;	
			
			y = CAMERA_VIEW_Y - 64;
			
			boss_enable = true;
			
			music_play(MUSIC.MAJOR_BOSS);
			music_reset_fade();
		}
	}
	
	// Do not execute anything boss related if its not enabled
	if(!boss_enable)
		exit;
	
	// Hurt the boss
	if(player_collide_object() && inv_timer == 0 && hp > 0)
	{
		hp--;
		inv_timer = 30;
			
		var p = player_find(0);
			
		p.x_speed *= -0.5;
		p.y_speed *= -0.5;
			
		sound_play(sfx_boss_hit);
	}
		
	if(inv_timer > 0)
		inv_timer--;
			
	event_user(boss_state);
	
	spike_y_target = y + 32;
	
	// Kill the boss when the HP is 0
	if(hp == 0)
	{
		boss_state = AAZ2_BSTATE.DEATH;
	}
	else
	{
		// Animate eggman
		if(inv_timer > 0)
			animation_play(animator, 2);
		else
			animation_play(animator, 0);
	}
	
	timer++;