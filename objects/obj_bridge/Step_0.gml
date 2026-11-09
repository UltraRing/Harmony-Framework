/// @description Script

	//Get player object
	var player = instance_nearest(x, y, obj_player);
	
	// Get the current log that the player is standing on
	var currentLog = clamp(((player.x - x) / 16), 0, bridge_size - 1);
	var clampedLog = clamp(currentLog, 1, bridge_size - 1);
	var logOffset = abs(-1 + ((currentLog / (bridge_size + 1)) * 2.5));
	
	// Calculate the tension on the left side
	var logMulti = ((clampedLog - logOffset) / bridge_size) * 2
	
	// Calculate the tension for the right side
	if(currentLog > (bridge_size / 2))
		logMulti = ((bridge_size - (clampedLog + logOffset)) / bridge_size) * 2

	//Make bridge dip when you land
	standing_multi = lerp(standing_multi, standing, 0.2);
	
	// Lerp fix
	if(!standing && standing_multi < 0.1 || currentLog > bridge_size - 1.5)
		standing_multi = 0;
		
	//Get max dipping
	if(currentLog <= (bridge_size) / 2)
	{
		max_dip = currentLog * dip_multiplier;
	}else
	{
		max_dip = ((bridge_size)-currentLog) * dip_multiplier;
	}	
	
	// Logic for individual bridge logs
	var t;
	for (var i = 0; i < bridge_size; i++)
	{
		// Calcualte the offset for the logs
		if (i < currentLog)
			t = i / currentLog;
		else
			t = (bridge_size - 1 - i) / max(bridge_size - 1 - currentLog, 1);
		
		// Push the logs down
		log_offset[i] = max_dip * standing_multi * logMulti * dsin(t * 90);
	}
	
	// Make the bridge semi solid
	var c = player_act_semi_solid();
	
	// Tilted bridge offset
	var pushOffset = ((ystart + push_offset) - ystart) * ((1 / bridge_size) * currentLog);
	
	// Offset the hitbox
	y = ystart + log_offset[floor(min(currentLog, bridge_size - 1))] + pushOffset;

	//Player standing on the bridge
	if(c && player.mode = 0 && player.ground)
	{
		if(!player.on_terrain)
		{
			player.y = bbox_top - player.hitbox_h - 1;
		}
		standing = true;
	}
	else
		standing = false;	
