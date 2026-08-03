	collision_flag = true;
	
	var box = _instance_make_hitbox(id);
	box = _instance_orient_hitbox(id, box);
	
	instance_register_culling(box);