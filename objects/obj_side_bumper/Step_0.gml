	if(sign(image_xscale) == 1)
	{
		//Hit from the bottom
		if(player_collide_object(C.LEFT) && triggered == 0 && obj_player.x_speed < 3)
		{
			triggered = -1;
			play_sound(sfx_spring);
			
			//Player stuff
			var player = instance_nearest(x, y, obj_player)
			with(player)
			{
				animation_play(animator, ANIM.SPRING);
				state = player_state_spring;
				y_speed = -6;
				x_speed = 3;
				ground = false;
			}
		}
	}
	
	//Facing Right
	if(sign(image_xscale) == -1)
	{		
		//Hit from the bottom
		if(player_collide_object(C.RIGHT) && triggered == 0 && obj_player.x_speed > -3)
		{
			triggered = 1;
			play_sound(sfx_spring);
			
			//Player stuff
			var player = instance_nearest(x, y, obj_player)
			with(player)
			{
				animation_play(animator, ANIM.SPRING);
				state = player_state_spring;
				y_speed = -6;
				x_speed = -3;
				ground = false;
			}
		}
	}

	if (triggered == 1) {
		x += 4
	} else if (triggered == -1) {
		x -= 4
	}	
	
	if abs(x - xstart) > 16 {
		instance_destroy()
	}
	