/// @description Script
	//Temp values
	var old_x, old_y;
	
	var col = player_act_semi_solid();
	var p = player_find(0);
	
	//Get previous position values
	old_x = round(x);
	old_y = round(y);
	

	//Position the platform
	x = round(origin_x + range_x * dsin(angle_x));
	y = round(origin_y + range_y * dcos(angle_y)) + sink_offset + (fall_offset);
	
	//Add angle and modulate it
	if fall_timer > 0 {
		angle_x = (angle_x + x_speed) mod 360;
		angle_y = (angle_y + y_speed) mod 360;
	}
	
	if fall_timer = 61 {
		for(var i = 0; i < ds_list_size(attached_list); i++){
			with(attached_list[| i])
			{
				if variable_instance_exists(self, "attached") {
					x = other.xstart - attach_offset_x;
					y = other.ystart - attach_offset_y;
					show_debug_message("{0} : {1}",x , y)
					show_debug_message("{0} : {1}",other.x , other.y)
					show_debug_message("{0} : {1}",round(other.x - old_x) , round(other.y - old_y))
				} else {
					show_debug_message("attached variable not found, falling case {0}", id)	
				}
			}
		}
		fall_timer = 60
	}
	
	//make the platform fall
	if (fall && fall_timer = 60 && col && p.ground) {
		fall_timer--	
	}
	if (fall && fall_timer < 60) {
		fall_timer--
		
		if fall_timer = 0 {
			last_x = x
			last_y = y
		}
		
		if fall_timer < 0 {
			fall_speed += 0.21875
			if (fall_timer < -30 && col && p.ground) {
				//eject player off after falling for too long
				p.ground = false
				p.y_speed = fall_speed
				collision_flag = false
			}
			fall_offset += fall_speed
			if (!on_screen() && !origin_on_screen(sprite_width + 16, sprite_height + 16, last_x, last_y)) {
				//reset to return back to normal
				collision_flag = true
				fall_timer = 61
				fall_speed = 0
				fall_offset = 0
				
			}
		}
	}
	
	//Sink the platform
	if(sink && col && p.ground)
	{
		sink_offset = lerp(sink_offset, 8, 0.2);
	}else
	{
		sink_offset = lerp(sink_offset, 0, 0.2);	
	}
	
	//Move the player
	if(col && p.ground)
	{
		p.x += round(x - old_x);
		p.y += round(y - old_y);	
		p.y = round(p.y);
	}
	
	//Move the objects
	if !ds_list_empty(attached_list) {
		for(var i = 0; i < ds_list_size(attached_list); i++)
		{
			with(attached_list[| i])
			{
					if variable_instance_exists(self, "attached") {
						if(attached && other.fall_timer > 0 && other.fall_timer != 61)
						{
							if object_get_parent(object_index) != par_moving_platform {
								x += round(other.x - old_x);
								y += round(other.y - old_y);
							} else {
								origin_x += round(other.x - old_x);
								origin_y += round(other.y - old_y);
							}
						}
					
						if (other.fall_timer = 0) {
								attached = false;
								ds_list_delete(other.attached_list, i);
						}
					} else {
						show_debug_message("attached variable not found, moving case. deleting {0} from list", id)	
						ds_list_delete(other.attached_list, i);	
					}
			}
		}
	}