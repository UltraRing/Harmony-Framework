/// @description Script
	//Code written by joshyflip
	bouncing = false
	
	// Make them semi solid
	var boxLeft = instance_position_hitbox(left_platform_x, left_platform_y, [-8, 0, 8, 4]);
	var platformLeft = player_act_semi_solid(boxLeft);
	
	var boxRight = instance_position_hitbox(right_platform_x, right_platform_y, [-8, 0, 8, 4]);
	var platformRight = player_act_semi_solid(boxRight);
	
	var boxWeight = instance_position_hitbox(weight_x, weight_y, [-8, -26, 8, 0]);
	var weightCollision = player_act_solid(boxWeight);
	
	// Get old position
	var oldYL = left_platform_y;
	var oldYR = right_platform_y;
	var oldY = weight_y;
	
	// Position the weights
	left_platform_y = floor(y + 64 + weight);
	right_platform_y = floor(y + 64 - weight);
	
	// Weight adjusting
	weight = math_approach(weight, -16 * stepping_side, 6);
	
	// Weight behaviour
	if(weight_ground)
	{
		weight_y = right_platform_y
		weight_grav = 0;
	}
	else
	{
		weight_y += weight_grav;
		weight_grav += 0.22;
		
		if(weight_y > right_platform_y)
		{
			weight_y = right_platform_y;
			weight_ground = true;
			weight_landed = true;
		}
	}
	
	// Get the first player object
	var player = player_find(0);
	
	// Move the player
	if(weightCollision == C.BOTTOM || weightCollision == C.TOP)
		player.y += floor(weight_y - oldY);
		
	// Position the player
	if(platformLeft)
	{
		stepping_side = weight_landed ? 1 : -1;
		player.y += floor(left_platform_y - oldYL);
		
		// Launch the weight
		if(weight == 16 && weight_ground && !weight_landed)
		{
			weight_ground = false;
			weight_grav = -8;
			
			play_sound(sfx_spring);
		}
		
		// Launch the player when the weight lands
		if(weight == -16 && weight_landed)
		{
			with(player)
			{
				animation_play(animator, ANIM.SPRING);
				state = player_state_spring;
				y_speed = -10;
				ground = false;
			}	
			
			play_sound(sfx_spring);
			weight_landed = false;
		}
	}
	else
	{
		weight_landed = false;
		
		if(weight_ground && weight == 16)
			stepping_side = 1;
	}
	
	// Standing on the right platform
	if(platformRight)
	{
		// Crush the player
		if(weightCollision == C.BOTTOM)
			player_hurt(0, K_DIE);	
	
		stepping_side = 1;
		player.y += floor(right_platform_y - oldYR);
	}
	