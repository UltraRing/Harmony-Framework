	animator_update(animator);
	
	var player = player_find(0);
	
	// Enter the ring
	if(player_collide_object() && !entered)
	{
		if(game_has_all_emeralds())
		{
			global.rings += 50;
			sound_play(sfx_specialring);
			instance_create_particle(x, y, spr_special_ring_effect, 0.5);
			global.special_ring_store[| id] = true;
			instance_destroy();
			exit;
		}

		entered = true;
		
		//Store backgrounds for next respawn
		level_store_bg_visibility();

		with(player)
		{
			visible = false;
			flag_override = false;
			speed_allow = false;
			hitbox_allow = false;
			state = player_state_null;
		}
		
		if(instance_exists(obj_shield))
			obj_shield.visible = false;
		
		visible = false;
		
		instance_create_particle(x, y, spr_special_ring_effect, 0.5);
		sound_play(sfx_specialring);
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
			
			fade_to_room(game_special_stage_room(), 2, FADE_COLOR.WHITE, 30);
			music_set_fade(FADE.OUT, 2);
			
			sound_play(sfx_specialring_warp);
		}
	}