/// @description Values
	type = 0;
	frame = 0;
	death_timer = 0;
	
	for(var w = 0; w < sprite_width; w++)
	{
		for(var h = 0; h < sprite_height; h++)
		{
			//Set the default speeds
			def_xspd = (random_range(0.5, 3) * dsin(random_range(-35, 35))) / 1.5;
			def_yspd = (random_range(0.5, 3) * dcos(random_range(-80, 80))) / 1.5;
			
			//Type 1
			if(type == 0)
			{
				def_timer = 0;
				def_timer_end = random(16) + 4;
			}
			
			//Type 2
			if(type == 1)
			{
				def_timer = 3 * h;
				def_timer_end = 32;
			}
			
			dust[w][h] = {
				timer : def_timer, 
				timer_end : def_timer_end, 
				x : w, 
				y : h,
				x_speed : def_xspd, 
				y_speed : def_yspd
			};
		}
	}