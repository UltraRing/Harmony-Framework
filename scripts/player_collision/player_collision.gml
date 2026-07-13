function player_collision()
{
	// Reset the flag
	on_terrain = false;
	
	// Disable the collision if the flag is off
	if(!collision_allow)
		exit;
		
	// Player's airborne state
	if(!ground)
	{
		// Reset the ground angle to default
		ground_angle = 0;
		
		// Make sure to reset the mode in alt mode
		if(PLAYER_ALT_COLLISION_MODE)
		{
			mode = CMODE.FLOOR;
			player_mode();
		}
		
		// Wall collision
		var wallR = collision_get_distance(x - wall_w, y, CMODE.RWALL, plane);
		var wallL = collision_get_distance(x + wall_w, y, CMODE.LWALL, plane);
		
		// Snap to the wall
		if(wallL <= 0)
			x += wallL;	
			
		if(wallR <= 0)
			x -= wallR;	
		
		// If player is going up, disable semi solids [NOTE: THIS IS WHERE THE IMPROVEMENTS WILL HAPPEN FOR 1.1]
		if(y_speed < 0)
			semi_solid_condition = false;
		else
			semi_solid_condition = true;
		
		// Get the active collision sensor
		var c = collision_active_sensor(hitbox_w, hitbox_h, CMODE.FLOOR, plane, semi_solid_condition);
		
		// If player is colliding with floor, then ground the player
		if(c.height < 0 && y_speed > 0)
		{
			// Push the player out of the ground
			c = collision_active_sensor(hitbox_w, hitbox_h, mode, plane, semi_solid_condition);
			ground_angle = c.angle;
			ground = true;	
			on_terrain = true;
			
			// Landing physics
			ground_speed = x_speed;
			
			// Shallow slopes
			if(abs(x_speed) <= abs(y_speed / 2) && math_uangle(ground_angle) >= 24)
				ground_speed = (y_speed / 2) * -sign(dsin(ground_angle));
			
			// Steep slope landing
			if(abs(x_speed) <= abs(y_speed) && math_uangle(ground_angle) >= 45)
				ground_speed = y_speed * -sign(dsin(ground_angle));
			
			// Trigger the landing callback and mode reposition
			player_land_callback();
			player_mode();
			
			// Get new collision to prevent floor clipping
			c = collision_active_sensor(hitbox_w, hitbox_h, mode, plane, semi_solid_condition);
			
			// Snap player to the floor
			ground_angle = c.angle;
			y += c.height * y_dir;
			exit;
		}
		
		// Ceiling collison
		c = collision_active_sensor(hitbox_w, hitbox_h, CMODE.CEILING, plane);	
		
		// Touching the ceiling
		if(c.height < 0)
		{
			// Check if player can ceiling land
			if(math_uangle(c.angle) <= PLAYER_CEIL_RANGE && y_speed < -PLAYER_CEIL_LAND_SPD)
			{
				// Set the angle and apply momentum
				ground_angle = c.angle;
				ground_speed = y_speed * -sign(dsin(ground_angle));
				
				// Trigger the landing callback and reposition the mode
				player_land_callback();
				player_mode();
				
				// Snap player to the floor
				y += c.height * y_dir;
				x += c.height * x_dir;
				
				// Flag as grounded
				ground = true;
				exit;
			}
			else
			{
				// If conditions aren't met for ceiling landing, just stop player's vertical movement
				if(y_speed < 0)
					y_speed = 0;	
				
				// Push out of the ceiling
				y -= c.height
			}
		}
		
		// Wall stoppers
		if(wallL < 0 || wallR < 0)
			x_speed = 0;
	}
	else
	{
		// Wall collision
		var wallR = collision_get_distance(x + (wall_w * y_dir), y - (wall_w * x_dir) + wall_h, (CMODE.LWALL + mode) mod 4, plane);
		var wallL = collision_get_distance(x - (wall_w * y_dir), y + (wall_w * x_dir) + wall_h, (CMODE.RWALL + mode) mod 4, plane);
		
		// Snap to the left wall with the right sensor
		if(wallR < 0)
		{
			x += wallR * y_dir;	
			y -= wallR * x_dir;	
		}
		
		// Snap to the right wall with the left sensor
		if(wallL < 0)
		{
			x -= wallL * y_dir;	
			y += wallL * x_dir;	
		}
		
		// If the ground collision mode isn't floor, make sure semi solids are inactive
		if(mode != CMODE.FLOOR)
			semi_solid_condition = false;
		else
			semi_solid_condition = true;
		
		// Get the active sensor
		var c = collision_active_sensor(hitbox_w, hitbox_h, mode, plane, semi_solid_condition);
		
		// Mark the player object to be on terrain
		if(c.height < 16)
		{
			on_terrain = true;	
		}
				
		// Get the previous angle and angle from the active sensor
		var oldAngle = ground_angle;
		var newAngle = c.angle;
				
		// Calculate the difference between both of the angles
		var angleDiff = abs(math_uangle(newAngle) - math_uangle(oldAngle));
		
		// If there's nothing below sonic, detach
		if(c.height > (angleDiff > PLAYER_SLOPE_TOLERANCE ? 1 : PLAYER_DETACH_DIST) && !water_run && !on_object)
		{
			ground = false;
			exit;
		}
		
		// Default the flag
		var canSnap = true;
		
		// Halt ground snapping and new angle if the difference is above the tolerance
		if(angleDiff > PLAYER_SLOPE_TOLERANCE || water_run && c.height > 0 && !on_terrain)
			canSnap = false;
		
		// Snap player to the floor
		if((!on_object && on_terrain || on_terrain && on_object) && canSnap)
		{
			y += c.height * y_dir;
			x += c.height * x_dir;
		
			// Apply the new angle
			ground_angle = newAngle;
		}
		
		// Plyer ground collision mode
		if(PLAYER_ALT_COLLISION_MODE)
		{
			// Get the old angle
			oldAngle = ground_angle;
			
			// Position sensor to the right side
			var px = x + hitbox_h * y_dir + hitbox_w * x_dir;
			var py = y + hitbox_w * y_dir + hitbox_h * -x_dir;
			
			// Get the collision distance and angle of the right sensor
			var col = collision_get_distance(px, py, (mode + CMODE.LWALL) % 4, plane, true);
			var a = collision_get_angle(px, py, (mode + CMODE.LWALL) % 4, plane);
			
			// Calculate the difference between old and new angle
			angleDiff = abs(math_uangle(a) - math_uangle(oldAngle));
			
			// If the conditions are met, change the ground collision mode
			if(col < 0 && angleDiff < PLAYER_SLOPE_TOLERANCE)
			{
				ground_angle = a
				player_mode();
			}
			
			// Position sensor to the left side
			px = x - hitbox_h * y_dir + hitbox_w * x_dir;
			py = y + hitbox_w * y_dir - hitbox_h * -x_dir;
			
			// Get the collision distance and angle of the left sensor
			col = collision_get_distance(px, py, (mode + 3) % 4, plane, true);
			a = collision_get_angle(px, py, (mode + 3) % 4, plane);

			// Calculate the difference between old and new angle
			angleDiff = abs(math_uangle(a) - math_uangle(oldAngle));
			
			// If the conditions are met, change the ground collision mode
			if(col < 0 && angleDiff < PLAYER_SLOPE_TOLERANCE)
			{
				ground_angle = a
				player_mode();
			}
		}
		
		// Wall stoppers
		if(wallR < 0 || wallL < 0)
		{
			if(mode != CMODE.FLOOR)
			{
				ground_angle = 0;
				player_mode();	
			}
			
			ground_speed = 0;
		}
	}
}