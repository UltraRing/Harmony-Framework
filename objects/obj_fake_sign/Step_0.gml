	/// @description Script
	
	//Update the position
	y += y_speed;
	
	var c = collision_get_distance(x, y - 1, CMODE.FLOOR, PLANE.A, true);
	
	//Airborne events
	if(!ground)
	{
		//Gravity
		y_speed += grav;
		
		//Floor detection
		if(c < 0)
		{
			y += c;
			ground = true;
			y_speed = 0;
		}
	}
	
	//If there's no floor, make the signpost airborn
	if(c > 14)
		ground = false;	