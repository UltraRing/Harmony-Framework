/// @description Find and set Event Type data

	// Get the event type
	switch ds_map_find_value(async_load, "event_type")
	{
	    // We found a gamepad!!!
		case "gamepad discovered":
			// Find the gamepad index and set it accordingly!
	        input_controller_id = ds_map_find_value(async_load, "pad_index");
	        break;
			
		// We lost a gamepad...
	    case "gamepad lost":
			// Find the newly reset gamepad index and get depressed from it.
	        input_controller_id = ds_map_find_value(async_load, "pad_index");
	        break;
	}

