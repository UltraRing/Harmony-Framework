/// @description Script
    //Set in front of the player
    depth = obj_player.start_depth - 1;
    
	if(!ringloss)
	{
	    //Sync the animation
	    image_index = FRAME_TIMER / 4;
	}
	
    //Collect
    if(player_collide_object(C.MAIN) && obj_player.state != player_state_knockout)
    {
		//Play the sound
		play_sound(sfx_ring);
		
        //Add rings!
        global.rings += 1;    
        
        //Create the effect
        create_effect(x, y, spr_ring_sparkle, 0.2);
        
        //Destroy the ring
		global.store_object_state[| id] = true
		
        instance_destroy();
    }
	
	//Ring physics
	if(magnet)
	{
		// Disable culling
		culling_struct.type = CULL_TYPE.DISABLE;
		
		//when i steal from the physics guide (:exploding_head:)
		var ringacceleration = [0.75, 0.1875];
		
		//relative positions
		var signx = sign(obj_player.x - x);
		var signy = sign(obj_player.y - y);
		
		//check relative movement
		var arrayx = (sign(x_speed) == signx);
		var arrayy = (sign(y_speed) == signy);
		
		x += x_speed;
		y += y_speed;
		
		if(!ringloss)
		{
			//add to speed
			x_speed += (ringacceleration[arrayx] * signx);
			y_speed += (ringacceleration[arrayy] * signy);
		
		}
		
		//Turn into ringloss if player doesn't have magnet shield
		if(obj_player.shield != S_ELECTRIC && magnet)
		{
			ringloss = true;
			magnet = false;
		}
	}
	
	//Ring loss physics
	if(ringloss)
	{
		// Disable culling
		culling_struct.type = CULL_TYPE.DISABLE;
		
		x += x_speed;
		y += y_speed;
			
		//Update sprite frame
		image_index += animation_speed;
			
		//Change ringloss animation speed
		if(timer > 32)
		{
			animation_speed = 1 - (timer / 298);
		} 
		else 
		{
			animation_speed = 0.8
		}	
			
		//Limit the speed
		animation_speed = max(animation_speed, 0.02);
			
		//Add timer
		timer += 1;
			
		//Destroy
		if(timer > 256) 
			instance_destroy();
			
		//Gravity
		y_speed += 0.09375;
			
		//Collision detection
		var hc = collision_get_distance(x + 8 * sign(x_speed), y, sign(x_speed) ? CMODE.LWALL : CMODE.RWALL, plane, false);
		var vc = collision_get_distance(x, y + 8 * sign(y_speed), sign(y_speed) ? CMODE.FLOOR : CMODE.CEILING, plane, sign(y_speed));
		
		// Bounce off floor and ceiling
		if(vc < 0)
		{
			y += vc * sign(y_speed);
			y_speed *= -1;
		}
		
		// Bounce off walls
		if(hc < 0)
		{
			x += hc * sign(x_speed);
			x_speed *= -1;
		}
	}