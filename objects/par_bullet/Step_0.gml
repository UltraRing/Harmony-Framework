/// @description Script
	
	//Update speeds
	x += x_speed;
	y += y_speed;
	
	//Gravity
	y_speed += grav;
	
	//Hurt the player
	if(player_collide_object(COLLISION.MAIN))
	{
		var fly_angle = 90 - point_direction(obj_player.x, obj_player.y,x,y) 
		var fly_cond = (obj_player.state == player_state_tailsfly && abs(fly_angle) < 45)
		if(obj_player.shield == SHIELD.NONE && !fly_cond)
		{
			player_hurt();
		}
		else
		{
			if(!bounce)
			{
				var angle = point_direction(x, y, obj_player.x, obj_player.y);
				x_speed = 12 * -dcos(angle);
				y_speed = 12 * dsin(angle);
				grav = 0;
				bounce = true;
			}
		}
	}
	//Destroy off screen
	if(!instance_on_screen(64, 64)) 
	{
		instance_destroy();
	}