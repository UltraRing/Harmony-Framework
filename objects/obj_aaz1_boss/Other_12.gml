	/// @description Boss Death
	death_timer++;
	
	obj_level.disable_timer = true;
	
	if(FRAME_TIMER mod 4 == 0 && !has_died)
	{
		sound_play(sfx_explosion);
		instance_create_particle(x + random_range(-32, 32), y + random_range(-16, 16), spr_effect_explosion_red, 0.3);
	}
	
	if(death_timer == 120)
	{
		instance_create_debris(x - 25, y - 13, spr_aaz1_boss_debris, 0, -2, 0, 0, 0.2);
		var d = instance_create_debris(x + 25, y - 13, spr_aaz1_boss_debris, 0, 2, 0, 0, 0.2);
		d.image_xscale = -1;
		animation_play(animator, 1);	
	}
	
	if(death_timer > 120)
	{
		y += y_speed;
		y_speed += 0.2;
		
		var p = instance_place(x, y, obj_breakable_tile);
		if(p)
		{
			instance_create_debris(x, y, spr_aaz1_boss_dead_body, 0, -2, -2, 0, 0.2);
			instance_create_debris(x, y, spr_aaz1_boss_dead_body, 0, -2, -1, 1, 0.2);
			instance_create_debris(x, y, spr_aaz1_boss_dead_body, 0, 2, -2, 0, 0.2,,,, -1);
			instance_create_debris(x, y, spr_aaz1_boss_dead_body, 0, 2, -1, 1, 0.2,,,, -1);
			music_set_fade(FADE.OUT, 1);
			
			with(player_find(0))
			{
				ground = false;
				
				x_speed = 0;
				y_speed = -6;
				
				if(abs(other.xstart - x) > 128)
					x_speed = 2 * sign(other.xstart - x);
				
				state = player_state_knockout;
			}
			
			has_died = true;
			visible = false;
			
			obj_camera.target_bottom = room_height;
			obj_camera.shake_x = 32;
			
			sound_play(sfx_break);
			instance_destroy(p);	
		}
	}
	
	if(has_died)
	{
		post_death_timer++;
		
		if(post_death_timer == 120)
		{
			level_create_signpost();
		}
	}