/// @description Values
	bridge_size = sprite_width / 16;
	max_dip = 0;
	standing = false;
	standing_multi = 0;
	
	log_offset = array_create(bridge_size, 0);
	log_frames = array_create(bridge_size, 0);
	
	// Register the object for culling
	var box = _instance_make_hitbox(id);
	box = _instance_orient_hitbox(id, box);
	
	instance_register_culling(box);