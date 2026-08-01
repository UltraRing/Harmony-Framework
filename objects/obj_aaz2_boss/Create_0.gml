	entrance_trigger = false;
	entrance_timer = 0;
	
	boss_state = AAZ2_BSTATE.ENTER;
	boss_enable = false;
	
	timer = 0;
	orbit_time = 0;
	move_time = 0;
	move_spd = 0;
	
	target_y = y - 72;
	
	hp = 8;
	inv_timer = 0;
	death_timer = 0;
	has_died = false;
	post_death_timer = 0;
	
	x_speed = 0;
	y_speed = 0;
	facing = 1;
	
	spike_y_target = y + 32;
	spike_y = spike_y_target;
	
	depth = player_find(0).depth + 10;
	
	enum AAZ2_BSTATE
	{
		ENTER,
		MOVE,
		DEATH
	}
	
	animator = new animator_create();
	
	/*animation_add(0, spr_aaz1_boss, 2, 0, true, true);
	animation_add(1, spr_aaz1_boss_dead, 2, 0, true, true);
	
	animation_play(animator, 0);