function player_state_knockout()
{	
	//Change flags
	direction_allow = false;
	movement_allow = false;
	
	//Change animation
	animation_play(animator, ANIM.HURT);
			
	//Exit when grounded
	if(ground)
	{
		state = player_state_normal;
		ground_speed = 0;
	}
}

function player_state_death()
{
	//Remove underwater physics
	underwater = false;
	
	// Correct the facing
	facing = 1;
	
	// Change the object's depth to be in front of everything
	depth = layer_get_depth("Utilities");
	
	//Change animation
	animation_play(animator, ANIM.DIE);
			
	//Disable collision
	collision_allow = false;
	x_speed = 0;
	ground_speed = 0;
			
	//Add death timer
	death_timer++;
			
	//Remove effects
	shield = S_NONE;
	invincible_timer = 0;
	speed_shoes = 0;
	invincible = false;
	speed_shoes_flag = false;
	hitbox_allow = false;
	direction_allow = false;
			
	//Fade out
	if(death_timer == 120)
	{
		// Decrement life
		global.life = max(global.life - 1, 0);
		
		if(global.life != 0 && !is_time_over)
		{
			fade_change(FADE.OUT, 3,FADE.BLACK)
			music_set_fade(FADE.OUT, 2);
		}
		else
		{
			// Clear stuff
			global.store_player_state.combinering = 0;
			global.store_player_state.shield = S_NONE;
			global.store_player_state.rings = 0;
			ds_list_clear(global.store_object_state);
			
			// Create the game over or time over object
			if(!instance_exists(obj_game_over))	
			{
				var a = instance_create_layer(0, 0, "Utilities", obj_game_over);
				a.type = (global.life != 0);
			}	
		}
	}

	//Restart
	if(death_timer == 180 && global.life != 0 && !is_time_over)
	{
		global.store_player_state.combinering = 0;
		global.store_player_state.shield = S_NONE;
		global.store_player_state.rings = 0;
		ds_list_clear(global.store_object_state);
		room_restart();
	}
}

function player_state_drown()
{
	// Correct the facing
	facing = 1;
	
	// Change the object's depth to be in front of everything
	depth = layer_get_depth("Utilities") + 100;
	
	//Change animation
	animation_play(animator, ANIM.DROWN);
			
	//Disable collision
	collision_allow = false;
	x_speed = 0;
	ground_speed = 0;
			
	//Add death timer
	death_timer++;
			
	//Remove effects
	shield = S_NONE;
	invincible_timer = 0;
	speed_shoes = 0;
	invincible = false;
	speed_shoes_flag = false;
	hitbox_allow = false;
	direction_allow = false;
	ground = false;
	
	//Fade out
	if(death_timer == 120)
	{
		// Decrement life
		global.life = max(global.life - 1, 0);
		
		if(global.life != 0 && !is_time_over)
		{
			fade_change(FADE.OUT, 3,FADE.BLACK)
			music_set_fade(FADE.OUT, 2);
		}
		else
		{
			// Clear stuff
			global.store_player_state.combinering = 0;
			global.store_player_state.shield = S_NONE;
			global.store_player_state.rings = 0;
			ds_list_clear(global.store_object_state);
			
			// Create the game over or time over object
			if(!instance_exists(obj_game_over))	
			{
				var a = instance_create_layer(0, 0, "Utilities", obj_game_over);
				a.type = (global.life != 0);
			}	
		}
	}

	//Restart
	if(death_timer == 180 && global.life != 0 && !is_time_over)
	{
		global.store_player_state.combinering = 0;
		global.store_player_state.shield = S_NONE;
		global.store_player_state.rings = 0;
		ds_list_clear(global.store_object_state);
		room_restart();
	}
			
	//Create bunch of bubbles for drowning event
	if(FRAME_TIMER mod 4 == 0){
		var bubble = instance_create_depth(x, y-12, depth-1, obj_bubble);
		bubble.type = 0;	
		bubble.angle = random(360);
	}
}