	teleport_id = 0;
	var in_excluded_room = false
	for(var i = 0; i < array_length(room_exclusion); ++i) {
		in_excluded_room |= room&room_exclusion[i] > 0;
	}
	
	
	// Grab metadata for objects
	if(array_length(object_list_metadata) < object_list_length && !in_excluded_room) {
		for(var i = 0; i < object_list_length; ++i) {
			object_list_metadata[i] = {};
			var obj = instance_create_depth(0,0,0,object_list[i])
			var obj_names = variable_instance_get_names(obj);		// Gets the names from the object
			for(var j = 0; j < variable_instance_names_count(obj); ++j) {
				object_list_metadata[i][$ obj_names[j]] = variable_instance_get(obj, obj_names[j]);		// Adds values
			}
			instance_destroy(obj);
		}
	}