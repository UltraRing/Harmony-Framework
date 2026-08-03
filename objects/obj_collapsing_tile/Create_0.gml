	triggered = false
	var str = string_split(target_layer,",", true)
	for (var i = 0; i < array_length(str); ++i) 
	{
	    tile_memory[i] = ds_list_create()
	}
	collision_memory = [ds_list_create(),ds_list_create()]
	offscreen = false
	
	var box = _instance_make_hitbox(id);
	box = _instance_orient_hitbox(id, box);
	
	instance_register_culling(box);