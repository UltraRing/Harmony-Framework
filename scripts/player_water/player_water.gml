function player_water()
{
	// Reset the water run flag
	water_run = false;
	
	//Stop executing if theres no water
	if(!instance_exists(obj_water) && !instance_exists(obj_waterpool) || !collision_allow) exit;

	// Constants 
	var waterY = (instance_exists(obj_water) ? obj_water.y : 0);
	var waterRange = 8;
	var waterSpd = 4;
	var waterPool = collision_point(x, y + hitbox_h + waterRange, obj_waterpool, true, false);
	
	// Check for water pools below you
	if(waterPool)
	{
		// Change the constant to the found waterpool's Y
		waterY = waterPool.y;
	}
	
	// Is player's bottom side in the water's range?
	if(y + hitbox_h > waterY - waterRange && y + hitbox_h < waterY + waterRange && ground
	&& abs(ground_speed) > waterSpd && y_speed >= -0.1)
	{
		// Attach player to the water horizon
		if(!on_terrain)
		{
			y = waterY - hitbox_h - 1;	
			ground_angle = 0;
			
			//Player effect
			if(FRAME_TIMER mod 4 == 0 && global.water_running_effect == 1)
			{
				//Create effects
				create_effect(obj_player.x, waterY, spr_water_splash, 0.35, obj_player.depth - 1);
				play_sound(sfx_water_splash);	
			}
		}
		
		// Flag player to be on water
		water_run = true;
		
		// Play the water run sound
		if(global.water_running_effect == 0 && !audio_is_playing(sfx_water_run))
			play_sound(sfx_water_run, true);
	}
	
	// Stop the water run sound
	if(!water_run || on_terrain)
		audio_stop_sound(sfx_water_run);
	
	if(instance_exists(obj_water))
	{
		//Entering water
		if(y >= obj_water.y)
		{
			//Player hitting the water
			player_set_underwater(true);
		}
	
		//Exiting water
		if(y < obj_water.y)
		{
			//Player hitting the water
			player_set_underwater(false);
		}
	}
	
	//Aquaphobia
	if(underwater)
	{
		if (shield != S_BUBBLE) {
			//bubbles
			if (bubble_delay > 0 && (air mod bubble_delay == 0)){
				bubble_delay = 0
				var bubble = instance_create_depth(x+6*facing, y-4, depth-1, obj_bubble);
				bubble.type = 0;	
				bubble.angle = facing == -1 ? 180 : 0;
			}
		
			if(air mod 60 == 0 ){
				var rand = round(random(1));
				show_debug_message(rand);
				if (rand == 0){
					bubble_delay = irandom_range(6,16)*2
				}
				if (air < 20*60) {
					var bubble = instance_create_depth(x+6*facing, y-4, depth-1, obj_bubble);
					bubble.type = 0;	
					bubble.angle = facing == -1 ? 180 : 0;
				}
			
			}
		}
		//Add air timer
		air += 1;
			
		//Play warning sound
		if(air == 6*60 || air == 12*60 || air == 18*60) play_sound(sfx_air_warning);
			
		//Uh oh drowning music
		if(!audio_is_playing(j_drowning) && air == 20 * 60){
			var jing = audio_play_sound(j_drowning, 0, false);
			audio_sound_gain(jing, global.bgm_volume, 0);
		}
		
	}
	else
	{
		air = 0;
	}
	
	if(air < 20*60) audio_stop_sound(j_drowning);
	
	//Drown!
	if(air > 32*60 && knockout_type != K_DROWN)
	{
		play_sound(sfx_drown);
		obj_camera.mode = 99;
		state = player_state_knockout;
		knockout_type = K_DROWN;
		x_speed = 0
		y_speed = 0
	}
	
	//Create the countdown
	switch(air){
		case 20*60:
			var drown_bubble = instance_create_depth(x+6*facing, y-4, depth-10, obj_drown_bubble);
			drown_bubble.animation = spr_bubble_number_5;
			drown_bubble.angle = facing == -1 ? 180 : 0;
			break;
				
		case 22*60:
			var drown_bubble = instance_create_depth(x+6*facing, y-4, depth-10, obj_drown_bubble);
			drown_bubble.animation = spr_bubble_number_4;
			drown_bubble.angle = facing == -1 ? 180 : 0;
			break;	
				
		case 24*60:
			var drown_bubble = instance_create_depth(x+6*facing, y-4, depth-10, obj_drown_bubble);
			drown_bubble.animation = spr_bubble_number_3;
			drown_bubble.angle = facing == -1 ? 180 : 0;
			break;	
				
		case 26*60:
			var drown_bubble = instance_create_depth(x+6*facing, y-4, depth-10, obj_drown_bubble);
			drown_bubble.animation = spr_bubble_number_2;
			drown_bubble.angle = facing == -1 ? 180 : 0;
			break;	
				
		case 28*60:
			var drown_bubble = instance_create_depth(x+6*facing, y-4, depth-10, obj_drown_bubble);
			drown_bubble.animation = spr_bubble_number_1;
			drown_bubble.angle = facing == -1 ? 180 : 0;
			break;
				
		case 30*60:
			var drown_bubble = instance_create_depth(x+6*facing, y-4, depth-10, obj_drown_bubble);
			drown_bubble.animation = spr_bubble_number_0;
			drown_bubble.angle = facing == -1 ? 180 : 0;
			break;	
	}
}

function player_set_underwater(value, object = obj_water)
{
	//If the underwater flag is the same, no need to run this again
	if(underwater == value) exit;
	
	//Retrieve collision side
	var side;
	with(object) side = player_collide_object();
	
	//Player hitting the water
	if(!value)
	{
		//Speed up the player
		y_speed *= 1.25;
	}
	else
	{		
		//Slow down the player
		x_speed *= 0.5;
		y_speed *= 0.25;
	}
	
	//Execute this only if the collision happens at the top
	if(side == C_TOP)
	{
		//Create effect
		create_effect(x, object.y, spr_water_splash, 0.35);
			
		//Play sound
		play_sound(sfx_water_splash);
	}
	
	//Trigger the flag
	underwater = value;
}