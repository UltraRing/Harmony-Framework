	if(keyboard_check_pressed(vk_control))
	{
	
	}
	
	// Edge case lol
	//if(timer == 60)
	//	found_collision = noone;
		
	if(timer > 60)
	{
		if(!touched_block)
		{
			if(!audio_is_playing(sfx_chain))
				sound_play(sfx_chain, true);
				
			spike_y += spike_y_spd;
			spike_y_spd += 0.2;	
			
			var newBox = instance_position_hitbox(x, spike_y, [-4, -4, 4, 4], id);
			
			if(instance_collide(found_collision, [-16, -16, 16, 16], id, newBox))
			{
				obj_camera.shake_y = 8;
				touched_block = true;
				
				sound_play(sfx_impact);
				
				audio_stop_sound(sfx_chain);
			}
		}
		else
		{
			if(instance_exists(found_collision))
			{
				if(++raise_delay > 30)
				{
					if(!audio_is_playing(sfx_chain))
						sound_play(sfx_chain, true);
					
					found_collision.y--;
				}
					
				spike_y = found_collision.y - 18;
				
				if(spike_y < spike_y_target + 32)
				{
					obj_camera.shake_x = 8;
					instance_destroy(found_collision);
				}
			}
			else
			{
				spike_y = math_approach(spike_y, spike_y_target, 1);
				
				if(spike_y == spike_y_target)
				{
					audio_stop_sound(sfx_chain);
					
					x_speed = 0;
					boss_state = AAZ2_BSTATE.MOVE;
					found_collision = noone;	
					timer = 0;
					touched_block = false;
					spike_y_spd = 0;
					raise_delay = 0;
					exit;
				}
			}
		}
		
		
	}