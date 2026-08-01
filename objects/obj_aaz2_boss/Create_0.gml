	entrance_trigger = false;
	entrance_timer = 0;
	
	boss_state = AAZ1_BSTATE.ENTER;
	boss_enable = false;
	
	timer = 0;
	orbit_time = 0;
	move_time = 0;
	move_spd = 0;
	
	target_y = y;
	
	hp = 6;
	inv_timer = 0;
	death_timer = 0;
	has_died = false;
	post_death_timer = 0;
	
	y_speed = 0;
	
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