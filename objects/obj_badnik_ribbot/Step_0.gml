	// Inherit the parent event's code for the badnik
	event_inherited();
	
	// Gravity
	y_speed += 0.18; 

	// Change some values
	x += x_speed;
	y += y_speed;
	
	
	// Check for collision on ground
	if(y_speed > 0)
	{
		var c = collision_get_distance(x, y, CMODE.FLOOR, PLANE.A, true)
		if(c < 0)
		{
			x_speed *= -1;
			y_speed = -5;
			animator_reset(animator);
			
			// Snap it to the floor
			y += c;
			
			// Play spring sound when on screen
			if(origin_on_screen(32, 32))
			{
				var jump_sound = play_sound(sfx_spring);
				audio_sound_pitch(jump_sound, 1.5);
			}
		}
	}

	// Visuals etc
	image_xscale = sign(x_speed); // Point badnik in the direction of the speed in which it's going
	animator_update(animator);