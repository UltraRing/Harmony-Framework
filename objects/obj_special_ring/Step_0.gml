	animator_update(animator);
	
	var player = player_find(0);
	
	// Enter the ring
	if(player_collide_object() && !entered)
	{
		entered = true;
		
		with(player)
		{
			visible = false;
			flag_override = false;
			speed_allow = false;
			hitbox_allow = false;
			state = player_state_null;
			
		}
		
		visible = false;
		
		create_effect(x, y, spr_special_ring_effect, 0.5);
		play_sound(sfx_special_ring);
	}
	
	// Enter events
	if(entered)
	{
		enter_timer++;
		
		if(enter_timer == 60)
		{
			global.store_player_state.combinering = obj_player.combinering;
			global.store_player_state.shield = obj_player.shield;
			global.store_player_state.rings = global.rings;
			global.previous_room = room;
			global.checkpoint_type = CHECKPOINT.SPECIAL_RING;
			
			global.time_store = global.stage_timer;
			
			global.special_ring_x = x;
			global.special_ring_y = y;
			
			global.special_ring_store[| id] = true
			
			fade_to_room(rm_blue_spheres, 2, FADE.WHITE, 30);
			music_set_fade(FADE.OUT, 2);
			
			play_sound(sfx_warp_into);
		}
	}