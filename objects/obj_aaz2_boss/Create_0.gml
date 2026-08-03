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
	
	spike_y_target = 0;
	spike_y = 0;
	spike_y_spd = 0;
	
	found_collision = noone;
	touched_block = false;
	raise_delay = 0;
	laugh_timer = 0;
	
	depth = player_find(0).depth + 10;
	
	enum AAZ2_BSTATE
	{
		ENTER,
		MOVE,
		SPIKE_DROP,
		DEATH
	}
	
	animator = new animator_create();
	
	animation_add(0, spr_aaz2_boss_eggman, 4, 0, true, true);
	animation_add(1, spr_aaz2_boss_eggman_laugh, 4, 0, true, true);
	animation_add(2, spr_aaz2_boss_eggman_shock, 2, 0, true, true);
	animation_add(3, spr_aaz2_boss_eggman_burnt, 2, 0, true, true);
	
	animation_play(animator, 0);