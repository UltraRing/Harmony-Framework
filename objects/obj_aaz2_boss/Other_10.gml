	/// @description Boss Entering
	y = math_approach(y, target_y, 1);
	
	if(y == target_y)
	{
		boss_state = AAZ2_BSTATE.MOVE;	
		timer = 0;
	}