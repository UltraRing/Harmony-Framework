	
	var c = player_act_solid();
	
	if(c == COLLISION.TOP)
	{
		var player = player_find();
		
		player.y = bbox_top - player.hitbox_h - 1;
	}