	death_timer++;
	obj_level.disable_timer = true;
	
	audio_stop_sound(sfx_chain);
	
	if(FRAME_TIMER mod 4 == 0 && !has_died)
	{
		sound_play(sfx_explosion);
		instance_create_particle(x + random_range(-32, 32), y + random_range(-16, 16), spr_effect_explosion02, 0.3);
	}
	
	if(!has_died && death_timer == 60 * 2)
	{
		x_speed = 0;
		y_speed = 3;
		has_died = true;
		timer = 0;
		
		// Debris
		if(touched_block)
			instance_destroy(found_collision);
		
		var chainAmount = floor((spike_y - spike_y_target) / 16);
	
		for (var i = 0; i < chainAmount + 1; ++i) 
		{
			instance_create_debris(x, (spike_y - 8) - 16 * i, spr_aaz2_boss_chain, 0, random_range(-3, 3), 0);
		}
		
		instance_create_debris(x, spike_y, spr_aaz2_boss_spike, 0, random_range(-3, 3), 0);
	}
	
	if(has_died)
	{
		
		if(timer > 80)
		{
			x += 2.5;
			y -= 0.1;
			facing = 1;
			
			animation_play(animator, 0);
		}
		else
		{
			y += y_speed;
			y = max(y, target_y);
		
			y_speed -= 0.1;
		}
		
		if(timer == 60 * 2)
		{
			music_set_fade(FADE.OUT, 2);	
		}
		
		if(timer == 60 * 3)
		{
			with(obj_level)
				music_play(stage_music);
				
			music_reset_fade();
			
			obj_camera.target_right = obj_capsule.x + (CAMERA_VIEW_W / 2);
			obj_camera.limit_right = obj_camera.target_right;
			obj_camera.mode = 1;
			obj_camera.target_x = obj_camera.camera_x;
			obj_camera.target_y = obj_camera.camera_y - 16;
		}
	}
	else
	{
		animation_play(animator, 3);
	}