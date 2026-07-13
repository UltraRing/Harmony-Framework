	if(!returning)
	{
		// Get the input direction
		var in = input_press(INPUT.RIGHT) - input_press(INPUT.LEFT);
	
		// Change the character
		if(in != 0)
		{
			select = math_wrap(select + in, 0, 2);	
			play_sound(sfx_beep);
		}
	
		// Update the Y offset
		for (var i = 0; i < 3; ++i) 
		{	
			char_y[i] = lerp(char_y[i], 12 * (select == i), 0.3);
		}
	
		// Transitioning in
		transition_timer = math_approach(transition_timer, 0, 0.03);
		transition_offset = 200 * ease_in_cubic(transition_timer);
	
		// Confirm
		if(transition_timer == 0)
		{
			if((input_press(INPUT.A) || input_press(INPUT.START)) && !leave)
			{
				leave = true;
			
				fade_to_room(rm_arboreal_agate1, 2);
				music_set_fade(FADE.OUT, 2);
			
				play_sound(sfx_menu_select);
			}
		
	
			// Leave the character select
			if(input_press(INPUT.B))
			{
				play_sound(sfx_menu_select);	
				returning = true;
			}
		}
	}
	else
	{
		return_timer++;	
		
		transition_timer = math_approach(transition_timer, 1, 0.03);
		transition_offset = 200 * ease_in_cubic(transition_timer);
		
		if(return_timer > 40)
		{
			instance_destroy();	
			
			with(menu)
			{
				selected = false;
				selected_timer = 0;
				timer = 0;	
				different_bg = false;	
			}
		}
	}