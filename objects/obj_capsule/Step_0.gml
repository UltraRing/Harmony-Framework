/// @description Capsule script
	
	// Make the capsule solid
	player_act_solid();
	
	var buttonBox = instance_position_hitbox(x, button_y, [-16, -16, 16, 0]);
	var buttonSolid = player_act_solid(buttonBox);
	var player = player_find(0);
	
	var oldY = floor(button_y);
	
	if(buttonSolid == C.TOP)
	{
		// Move the button down
		button_y = math_approach(button_y, y + 8, 2);
		
		// If button is fully pressed, activate the capsule
		if(button_y == y + 8 && !active)
		{
			active = true;
			
			//Create pieces
			var piece = instance_create_depth(x-20, y+32, depth-200, obj_capsule_piece)
			piece.image_index = 1;
			piece.x_speed = -2;
			piece.y_speed = -4;
			
			piece = instance_create_depth(x, y+32, depth-200, obj_capsule_piece)
			piece.image_index = 2;
			piece.y_speed = -5;
			
			piece = instance_create_depth(x+20, y+32, depth-200, obj_capsule_piece)
			piece.image_index = 0;
			piece.x_speed = 2;
			piece.y_speed = -4;
			
			//Create flickies
			for(var i = 0; i < 10; i++)
			{
				var animal = instance_create_depth(other.x + random_range(-24, 24), other.y+32, depth, obj_flicky);
				animal.delay = 16+(4 * i);
			}
		}
		
		// Carry the player
		player.y -= floor(oldY - button_y);	
	}
	else
	{
		if(!active)
			button_y = math_approach(button_y, y, 2);	
		else
			button_y = y + 8;
	}

	if(active)
	{
		//Add the timer
		timer++;
		
		//Change capsule sprite to destroyed
		image_index = 1;
		
		//Lock the obj_camera
		obj_camera.target_left = x - obj_camera.center_x;
		obj_camera.target_right = x + obj_camera.center_x;
		
		//Exploder
		if(timer < 32 && timer mod 4 = 1){
			create_effect(x+random_range(-32, 32), y + 32 + random_range(-32, 32), spr_effect_explosion02, 0.3);
			play_sound(sfx_destroy);
		}
		
		//Act clear
		if(!instance_exists(obj_act_clear) && timer = 100)
		{
			obj_level.disable_timer = true;
			obj_level.act_transition = false;
			instance_create_depth(0, 0, obj_hud.depth, obj_act_clear);
		}
		
	}