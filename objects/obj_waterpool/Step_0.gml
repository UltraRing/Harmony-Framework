/// @description Script
	var player = player_find(0),
		collision = player_collide_object();
	
	with(player)
	{
		if(!collision_rectangle(x - wall_w, y - hitbox_h, x + wall_w, y + hitbox_h, obj_waterpool, true, false))
		{
			player_set_underwater(false, obj_waterpool);
		}
		
		if(collision)
		{
			player_set_underwater(true, other.id);
		}
	}