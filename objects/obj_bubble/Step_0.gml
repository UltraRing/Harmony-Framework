/// @description Script
    var pool, water, top_y;
    pool = instance_place(x, y, obj_water_pool);
    water = instance_exists(obj_water);
    
    if ((water && y < obj_water.y || !water) && pool) {
        top_y = pool.pos_y;
    }
    else if (water) {
        top_y = obj_water.y;
    }
    else instance_destroy();
    
    // Update the animator
	animator_update(animator);
	animation_play(animator, type);
	
	// Bounding box reasons
	sprite_index = animation_get_sprite(animator);
	
	//Movement
	y -= 0.53125;
	x = xstart + 4 * dsin(angle);
	
	//Add and modulate angle
	angle = (angle + 2.8125) mod 360;
	
	//Destroy outside of window or above water horizon
	if(!instance_on_screen() || bbox_top < top_y) 
	{
		instance_destroy();
		exit;
	}
	
	// Get the player object
	var player = player_find(0);
	
	//Suck it!
	if(player_collide_object([-8, -8, 8, 8]) && !player.ground && player.shield != SHIELD.BUBBLE && animation_is_playing(animator, 2) && animation_has_finished(animator))
	{
		with(player)
		{
			air = 0;
			x_speed = 0;
			y_speed = 0;
			ground_speed = 0;
			state = player_state_normal;
			animation_play(animator, ANIM.BREATHE);
			sound_play(sfx_breathe);
		}
		
		instance_destroy();	
	}
	