/// @description Script
	var player = player_find(0),
		waterCheck = (instance_exists(obj_water) ? player.y < obj_water.y : true);
	
	//In the player object
	with(player)
	{
		//If you're colliding with a water pool
		if(player_collide_waterpool())
		{
			//Set the flag to true
			player_set_underwater(true, other.id);
		}
		else
		{
			//If you're above the water level object, set the flag to false
			if(waterCheck) player_set_underwater(false, obj_waterpool);
		}
	}