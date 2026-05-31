function player_water()
{
	// Reset the water run flag
	water_run = false;
    
    //Get the water object the player is currently inside of
    var water = instance_place(x, y, obj_water);
    
    //Hard setting the water object to the main one if it's in proximity of the Player
    with (obj_water){
        if (!is_pool && obj_player.y >= y-32){
            water = self;
            break;
        }
    }
	
	//Stop executing if theres no water
	if(!water || !collision_allow) exit;
	
	// Constants 
	var waterY = water.pos_y;
	var waterRange = 8;
	var waterSpd = 4;
	
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
	
	
    //Boundary check if nearest water is a pool
    if ((water.is_pool && x >= water.bbox_left && x <= water.bbox_right) || !water.is_pool)
    {
        //Entering water
        var pool_condition = (water.is_pool && ((y >= waterY && y < water.bbox_bottom-sprite_height/2) || (y <= water.bbox_bottom && y > water.bbox_bottom-sprite_height/2)));
    	if((!water.is_pool && y >= waterY) || pool_condition)
        {
            //Player hitting the water
            if(!underwater)
            {
                //Slow down the player (while making sure they can jump inside shallow waters)
    			x_speed *= (y_speed > 0)? 0.5 : 0.75;
    			y_speed *= (y_speed > 0)? 0.25 : 0.65;
                
                //Create effects
                if (y <= waterY+16) create_effect(x, waterY, spr_water_splash, 0.35);
                
                //Play sound
                play_sound(sfx_water_splash);
            }
            
            //Trigger the flag
            underwater = true;
        }
        
        //Exiting water
        pool_condition = (water.is_pool && ((y < waterY && y < water.bbox_bottom-sprite_height/2) || (y > water.bbox_bottom && y > water.bbox_bottom-sprite_height/2)));
    	if((!water.is_pool && y < waterY) || pool_condition)
        {
            //Player hitting the water
            if(underwater)
            {
                //Speed up the player
                y_speed *= 1.25;
                
                //Create effects
                create_effect(x, waterY, spr_water_splash, 0.35);
                
                //Play sound
                play_sound(sfx_water_splash);
            }
            
            //Trigger the flag
            underwater = false;
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
                    bubble.water = water;
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
                        bubble.water = water;
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
            
        }else
        {
            air = 0;
        }
        
        if(air < 20*60) audio_stop_sound(j_drowning);
        
        //Drown!
        if(air > 32*60 && knockout_type != K_DROWN){
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
    //Check to make sure you can leave the pool from the sides
    else if (water.is_pool)
    {
        if(underwater) { 
            y_speed *= 1.25;
            if (y < waterY){
                create_effect(x, waterY, spr_water_splash, 0.35, depth-1);
            }
            play_sound(sfx_water_splash); 
        } 
        underwater = false;
    }
}