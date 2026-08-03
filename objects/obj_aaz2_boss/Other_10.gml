	/// @description Boss Entering
	y = math_approach(y, target_y, 1);
	
	if(y == target_y)
	{
		if(timer > 30)
		{
			boss_state = AAZ2_BSTATE.MOVE;	
			timer = 0;
		}
	}
	else
	{
		timer = 0;	
	}
	
	spike_y = spike_y_target;