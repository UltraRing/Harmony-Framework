	animator_update(animator);
	
	if(player_find(0).x > x - 64 && !entrance_trigger)
	{
		entrance_trigger = true;
		music_set_fade(FADE.OUT, 2);
		
		// yes, horizontal boundaries are supposed to be hardcoded
		obj_camera.target_left = xstart - (512 / 2);
		obj_camera.target_right = xstart + (512 / 2);
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
	if(player_collide_object() && hp > 0)
	{
		var p = player_find(0);
		
		if(p.attacking && inv_timer == 0)
		{
			hp--;
			inv_timer = 30;
			laugh_timer = 0;
			
			p.x_speed *= -0.5;
			p.y_speed *= -0.5;
			
			sound_play(sfx_boss_hit);
		}
		
		if(!p.attacking)
		{
			player_hurt();	
			laugh_timer = 60;
		}
		
	}
	
	// Make spike a hazard
	var b = instance_position_hitbox(x, spike_y, [-2, 4, 2, 24], id);
	if(player_collide_object(b) && hp > 0 && !touched_block)
	{
		player_hurt();	
		laugh_timer = 60;
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
		if(laugh_timer == 0)
		{
			if(inv_timer > 0)
				animation_play(animator, 2);
			else
				animation_play(animator, 0);
		}
		else
		{
			laugh_timer--;	
			animation_play(animator, 1);
		}
	}
	
	timer++;