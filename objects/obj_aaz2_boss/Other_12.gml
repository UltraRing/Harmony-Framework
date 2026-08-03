	if(keyboard_check_pressed(vk_control))
	{
		x_speed = 0;
		boss_state = AAZ2_BSTATE.MOVE;
		found_collision = noone;	
		timer = 0;
		touched_block = false;
		spike_y_spd = 0;
		raise_delay = 0;
		exit;
	}
	
	// Edge case lol
	//if(timer == 60)
	//	found_collision = noone;
		
	if(timer > 60)
	{
		if(!touched_block)
		{
			spike_y += spike_y_spd;
			spike_y_spd += 0.2;	
			
			var newBox = instance_position_hitbox(x, spike_y, [-4, -4, 4, 4], id);
			
			if(instance_collide(found_collision, [-16, -16, 16, 16], id, newBox))
			{
				obj_camera.shake_y = 8;
				touched_block = true;
			}
		}
		else
		{
			if(instance_exists(found_collision))
			{
				if(++raise_delay > 30)
					found_collision.y--;
					
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
					
				}
			}
				
			show_debug_message(found_collision)	
		}
		
		
	}
	
	//x = math_approach(x, found_collision.x, 2);