	var pool = instance_place(x, y, obj_water_pool);
    var top_y = (y < obj_water.y && pool)? pool.pos_y : obj_water.y;
    
    // Hide above water horizon & Outside of pools
	if(bbox_top < top_y)
	{
		visible = false;
		exit;
	}
	else
	{
		visible = true;
	}

	animator_update(animator);

	var emitting_type = 2
	switch(emit_big)
	{
		case "Every Cycle":
			emitting_type = 0
		break;
		case "Every Other Cycle":
			emitting_type = 1
		break;
		case "Every Third Cycle":
			emitting_type = 2
		break;
	}
	
	cycle = cycle mod (emitting_type + 1)
	
	if (!is_emitting)
	{
		if (time_until == 0)
		{
			time_until = irandom_range(128,255)
		}
		else
		{
			if (time == time_until)
			{
				is_emitting = true
				cycle_index = irandom_range(0,array_length(bubble_sets)-1)
				cycle_size = irandom_range(1,array_length(bubble_sets[cycle_index])-1)
				cycle_set_index = 0
				time_until = irandom_range(0,31)
			}
		}
	}
	else
	{
		if (cycle_set_index > cycle_size)
		{
			is_emitting = false;
			time_until = 0;
			spawned_big = false;
			cycle += 1;
			exit;
		}
		
		if (time == time_until) 
		{
			var big_chance = irandom_range(0,3)
			var bubble = instance_create_depth(x + irandom_range(-8,7), y-4, depth-1, obj_bubble);
			
			if (cycle mod (emitting_type + 1) == 0)
			{
				if (big_chance == 3 && !spawned_big)
				{
					bubble.type = 2
					spawned_big = true
				}
				else if (cycle_set_index == cycle_size && !spawned_big)
				{
					bubble.type = 2
					spawned_big = true
				}
				else
				{
					bubble.type = bubble_sets[cycle_index][cycle_set_index]
				}
			}
			else
			{
				bubble.type = bubble_sets[cycle_index][cycle_set_index]
			}
			
			time_until = irandom_range(0,31)
			time = 0
			cycle_set_index += 1 	
			
		}
	}
	
	time = min(time + 1, time_until)