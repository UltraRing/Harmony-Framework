/// @description Script
	sprite_index = asset_get_index("spr_bubble_" + string(type+1)); 
	
	var water = collision_point(x, bbox_top, obj_water, true, true);
	
	//Movement
	y -= 0.5;
	x = xstart + 3*dsin(angle)
	
	//Add and modulate angle
	angle = (angle + 2) mod 360;
	
	//Destroy outside of window or above water horizon
	if(!on_screen() || water == noone)
	{
		instance_destroy();
		exit;
	}
	
	//Utilize animation system
	if(image_index >= image_number-1)
	{
		image_index = image_number-1;
		image_speed = 0;
	}
	
	//Suck it!
	if(player_collide_object() && !obj_player.ground && image_index >= image_number-1 && sprite_index = spr_bubble_3 && obj_player.shield != S_BUBBLE)
	{
		with(obj_player)
		{
			air = 0;
			x_speed = 0;
			y_speed = 0;
			ground_speed = 0;
			state = player_state_normal;
			animation_play(animator, ANIM.BREATHE);
			play_sound(sfx_breathe);
		}
		//PlaySound(Breathe);
		instance_destroy();	
	}
	