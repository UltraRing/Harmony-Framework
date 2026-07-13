	// Make the button solid
	var col = player_act_solid();

   // Correct side conditions
	var side = (sign(image_yscale)) ? C.TOP : C.BOTTOM;
    
    if(col == side)
	{
		if(image_index == 0 && triggered)
		{
			play_sound(sfx_beep);
		}
		
		image_index = 1;
		
		if(!triggered)
		{
	        triggered = true;
        
	        with (obj_aaz_door)
			{
	            if (door_id == other.button_id)
				{
	                if (move_once && moved) 
						continue;
	                state = DOOR.MOVING;
					play_sound(sfx_opendoor);
	            }
	        }
		}
    }
	else
	{
		image_index = 0;
	}