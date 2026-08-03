/// @description Script
	//Always enable flag
	collision_flag = true;
	
	//Get colliding player
	var player = player_find(0);
	var col = noone;
	
	//Disable flag when attacking


	
	//When monitor isn't destroyed
	if(!destroyed)
	{
		if(player)
		{
			if(sign(image_yscale) == 1)
			{
				if(player.attacking && player.y_speed >= 0 && player.state != player_state_spindash && ground)
				{
					collision_flag = false;
				}
			}
			else
			{
				if(player.attacking && player_collide_object(COLLISION.TOP))
				{
					collision_flag = false;
				}
			}
		}
		
		// Hacky fixes
		var oldPlayerY = player.y;
		var oldMonitorX = x;
		
		// Make monitor solid
		if(collision_flag)
			col = player_act_solid();
		
		//Bump the monitor
		if(col == COLLISION.BOTTOM && sign(image_yscale) == 1)
		{
			ground = false;
			y_speed = -2;	
			
			player.y_speed = 0;
			
			//Change depth
			if(layer_bump)
			{
				depth = layer_get_depth("Objects");	
			}
			
			// Make sure the player doesn't clip
			if(!ground && player.ground)
				player.y = oldPlayerY;
			
			// Make the player solid for the monitor
			instance_act_solid(id, noone, player, player_get_hitbox(0));
			
			// Make sure the monitor doesn't move
			x = oldMonitorX;
		}
		
		//Destroy the monitor
		if(player_collide_object() || player_insta_shield_collide())
		{

			destroyed = true;
			ground = false;
			y_speed = -2 * sign(image_yscale);
			player.y_speed = max(abs(player.y_speed), 4) * -sign(image_yscale);
			instance_create_particle(x, y, spr_effect_explosion01, 0.3);
			sound_play(sfx_destroy);
			
			if(!instance_exists(obj_bonus_cont)) 
			{
				global.store_object_state[| id] = true
			}
			
			//Create icons
			var icon = instance_create_depth(x, y, depth, obj_monitor_icon);
			icon.monitor_type = monitor_type;
			icon.sprite_index = monitor_icon;
			icon.y_speed *= sign(image_yscale);
		}
	}
	else
	{
		//No more collision
		collision_flag = false;
		
		//Destroyed sprite
		sprite_index = spr_monitor_broken;
		
		//Flip it back
		image_yscale = 1;
	}
	
	if(!ground)
	{
		//Update position by speed
		y += y_speed;
		
		//Gravity
		if(!ground) 
		{
			y_speed += 0.2;
		}
		
		//Collision
		var c = collision_active_sensor(floor((bbox_right - bbox_left) / 2), floor(bbox_bottom - y - 1), COLLISION_MODE.FLOOR, PLANE.A, true);
		
		if(c.height < abs(y_speed) / 2 && y_speed >= 0)
		{
			y_speed = 0;
			ground = true;
			y += c.height;
		}
	}
	else if(check_ground_below)
	{
		//Collision
		var c = collision_active_sensor(floor((bbox_right - bbox_left) / 2), floor(bbox_bottom - y - 1), COLLISION_MODE.FLOOR, PLANE.A, true);
		
		// Detach if theres nothing below
		if(c.height > 14)
			ground = false;
	}

	// Character life icon
	var charIcon = [spr_monitor_icon_life_sonic, spr_monitor_icon_life_tails, spr_monitor_icon_life_knuckles];
	
	// Make the monitor icon list
	var iconList = [spr_monitor_icon_10ring, spr_monitor_icon_shield, spr_monitor_icon_fire_shield,
					spr_monitor_icon_electric_shield, spr_monitor_icon_bubble_shield, spr_monitor_icon_inv,
					spr_monitor_icon_shoes, spr_monitor_icon_life_sonic, spr_monitor_icon_eggman, spr_monitor_icon_combine_ring];
	
	// Correct the life icon
	iconList[MONITOR.EXTRA_LIFE] = charIcon[player_find(0).character];
	
	// Give it the correct icon
	monitor_icon = iconList[monitor_type];