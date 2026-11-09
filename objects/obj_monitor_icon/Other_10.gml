/// @description Rewards
	switch(monitor_type)
	{
		case MONITOR.RINGS:
			global.rings += 10;
			sound_play(sfx_ring10);
		break;
		
		case MONITOR.SHIELD:
			player_set_shield(SHIELD.NORMAL);
			sound_play(sfx_shield);
		break;
		
		case MONITOR.ELECTRIC_SHIELD:
			player_set_shield(SHIELD.ELECTRIC);
			sound_play(sfx_shield_electric);
		break;
		
		case MONITOR.FIRE_SHIELD:
			player_set_shield(SHIELD.FIRE);
			sound_play(sfx_shield_fire);
		break;
		
		case MONITOR.BUBBLE_SHIELD:
			player_set_shield(SHIELD.BUBBLE);
			sound_play(sfx_shield_bubble);
		break;
		
		case MONITOR.INVINCIBLE:
			obj_player.invincible = true
			obj_player.invincible_timer = 1200;
			if(!audio_is_playing(j_super))
				music_play(MUSIC.INVINCIBLE, Jingle);
		break;
		
		case MONITOR.SPEED_SHOES:
			obj_player.speed_shoes = 1200;
			if(!audio_is_playing(j_super))
				music_play(MUSIC.SPEEDSHOES, Jingle);	
		break;
		
		case MONITOR.EGGMAN:
			player_hurt();
		break;
		
		case MONITOR.EXTRA_LIFE:
			music_play_jingle();
			global.life += 1;
		break;
		
		case MONITOR.COMBINE_RING:
			obj_player.combinering = 1;
			sound_play(sfx_combinering);
		break;
		
	}