/// @self					obj_player	
/// @description			Function that handles player's interaction with the water and water pools
function player_water()
{
	// Reset the water run flag
	water_run = false;
    
    //Get the water object the player is currently inside of
    var water = instance_place(x, y, par_water);
    
    //Hard setting the water object to the main one if it's in proximity of the Player
    with(par_water)
	{
        if (object_index != obj_water_pool && obj_player.y >= y - 32)
		{
            water = self;
            break;
        }
    }
    
    var is_pool = water && water.object_index = obj_water_pool;
	
	//Stop executing if theres no water
	if(!water || !collision_allow){
		if (underwater){
			underwater = false	
		}
	} else {
		_player_water_check(water,is_pool)	
	}
	
	_player_underwater_process(water)
	
}

function _player_water_check(water, is_pool){
	// Constants 
	var waterY = (is_pool)? water.pos_y : water.y;
	var waterRange = 8;
	var waterSpd = 6;
	
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
				var splash = instance_create_depth(obj_player.x, waterY, obj_player.depth - 1, obj_water_splash);
				splash.par = water;
				sound_play(sfx_water_splash);	
			}
		}
		
		// Flag player to be on water
		water_run = true;
		
		// Play the water run sound
		if(global.water_running_effect == 0 && !audio_is_playing(sfx_water_run))
			sound_play(sfx_water_run, true);
	}
	
	// Stop the water run sound
	if(!water_run || on_terrain)
		audio_stop_sound(sfx_water_run);
    
    var pool_enter = (is_pool && ((y >= waterY && y < water.bbox_bottom-sprite_height/2) || (y <= water.bbox_bottom && y > water.bbox_bottom-sprite_height/2)));
    
	//Boundary check if nearest water is a pool
    if ((is_pool && x >= water.x && x <= water.bbox_right) || !is_pool)
    {
        //Entering water
    	if((!is_pool && y >= waterY) || pool_enter)
        {
            //Player hitting the water
            if(!underwater)
            {
                //Slow down the player
                x_speed *= 0.5;
                y_speed *= 0.25;
                
                //Create effects
                if (!is_pool || is_pool && y < water.pos_y+8)
                {
                    var splash = instance_create_depth(obj_player.x, waterY, obj_player.depth - 1, obj_water_splash);
                    splash.par = water;
                }
                
				//Play sound if on screen
				var cy = camera_get_view_y(view_camera[view_current]);
				var sh = global.window_height;
				if (cy < water.pos_y && cy + sh > water.pos_y)
					sound_play(sfx_water_splash);
            }
		      
            //Trigger the flag
            underwater = true;
        }
	}
    
    //Exiting water
    var pool_leave_v = (is_pool && (((y < waterY && y < water.bbox_bottom-sprite_height/2) || (y > water.bbox_bottom && y > water.bbox_bottom-sprite_height/2))));
    var pool_leave_h = (is_pool && (x < water.x) || (x > water.bbox_right));
    
    //Making sure the underwater state presists between two water pools next to each other
        var left_pool, right_pool;
        left_pool = instance_place(x-16, y, obj_water_pool);
        right_pool = instance_place(x+16, y, obj_water_pool);
        var pool_neighbours = (left_pool && right_pool && left_pool != right_pool);
    
    if (((!is_pool && y < waterY) || pool_leave_v || pool_leave_h) && !pool_neighbours)
    {
        //Player hitting the water
        if(underwater)
        {
            //Speed up the player
            y_speed *= 1.25;
            
            //Create effects
            if (!pool_leave_h) {
                var splash = instance_create_depth(obj_player.x, waterY, water.depth - 1, obj_water_splash);
                splash.par = water;
            }
            
            //Play sound if on screen
			var cy = camera_get_view_y(view_camera[view_current]);
			var sh = global.window_height;
			if (cy < water.pos_y && cy + sh > water.pos_y)
				sound_play(sfx_water_splash);
        }
        
        //Trigger the flag
        underwater = false;
    }
}

function _player_underwater_process(water){
	// Reset if there's air
	if(air < 20 * 60) 
	{
		bubble_number = 5;
		audio_stop_sound(j_drowning);
	}
	
	if(!underwater || !water){
		air = 0;
		exit;
	}
	
	
	if(shield == SHIELD.ELECTRIC || shield == SHIELD.FIRE)
	{
		if(shield == SHIELD.ELECTRIC)
		{
			sound_play(sfx_electric_shield_lose);
			water.flash_hold_timer = 4;
		}
			
		shield = SHIELD.NONE;
	}
		
	if (shield != SHIELD.BUBBLE) 
	{
		//bubbles
		if (bubble_delay > 0 && (air % bubble_delay == 0))
		{
			bubble_delay = 0
			var bubble = instance_create_depth(x + 6 * facing, y, depth - 1, obj_bubble);
            bubble.par = water;
			bubble.type = 0;	
			bubble.angle = facing == -1 ? 180 : 0;
		}
		
		if(air % 60 == 0)
		{
			var rand = irandom(1);

			if (rand == 0)
				bubble_delay = irandom_range(6,16) * 2;
				
			if (air < 20*60) 
			{
				var bubble = instance_create_depth(x+6*facing, y-4, depth-1, obj_bubble);
                bubble.par = water;
				bubble.type = 0;	
				bubble.angle = facing == -1 ? 180 : 0;
			}
		}
		
		//Add air timer
		air++;
	}
	else
	{
		air = 0;
	}
			
	//Uh oh drowning music
	if(!audio_is_playing(j_drowning) && air == 20 * 60)
		audio_play_sound(j_drowning, 0, false, global.bgm_volume);
		
	
	
	switch(air)
	{
		// Bubble warning sounds
		case 6 * 60:
		case 12 * 60:
		case 18 * 60:
			sound_play(sfx_air_warning);
		break;
		
		// Play the drowning theme
		case 20 * 60:
			if(!audio_is_playing(j_drowning))
				audio_play_sound(j_drowning, 0, false, global.bgm_volume);
		
		// Begin the count down
		case 22 * 60:
		case 24 * 60:
		case 26 * 60:
		case 28 * 60:
		case 30 * 60:
			var drown_bubble = instance_create_depth(x + 6 * facing, y - 4, depth - 10, obj_drown_bubble);
			drown_bubble.type = bubble_number;
			drown_bubble.angle = facing == -1 ? 180 : 0;
			bubble_number--;
			
		break;
		// The end, drown the player
		case 32 * 60:
			sound_play(sfx_drown);
			camera_set_mode(CAM_NULL);
			state = player_state_drown;
			x_speed = 0;
			y_speed = 0;
		break;
	}
}