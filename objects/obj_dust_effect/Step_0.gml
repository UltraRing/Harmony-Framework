/// @description Script
	death_timer++;
	
	for(var w = 0; w < array_length(dust); w++)
	{
		for(var h = 0; h < array_length(dust[w]); h++)
		{
			//If the info array is empty, continue to the next loop
			if(!is_struct(dust[w][h])) continue;
			
			//Add speeds
			if(dust[w][h].timer > array_length(dust[w]) - h && type == 1 || type == 0)
			{
				dust[w][h].x += dust[w][h].x_speed;
				dust[w][h].y += dust[w][h].y_speed;
			}
			
			//Timer
			dust[w][h].timer++;
			
			//Destroy dust info
			if(dust[w][h].timer > dust[w][h].timer_end + 4)
				dust[w][h] = -1;
		}
	}
	
	//Filter out the empty info arrays
	dust = array_filter(dust,
	function(element, index)
	{
		//Checks if the info array is empty
		return (!is_struct(element));
	});
	
	//Destroy the effect if there's no more dust
	if(death_timer > 40) 
		instance_destroy();