	//NOTE: Duplicate this room to make levels!
	with(obj_level)
	{
		//Set stage music and loop points
		stage_music = MUSIC.TECHDEMO_TOWER
		
		//Set level name
		stage_name = "Template Level";
		
		//Set stage act
		act = 0;
		
		//Is next level doing act transition in case if you do a multi-zone level.
		act_transition = false;
		
		//Animal array
		animal = [A_FLICKY, A_CUCKY, A_RICKY];
		
		//Next level
		next_level = room;
	}