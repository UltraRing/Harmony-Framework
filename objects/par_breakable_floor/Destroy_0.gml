	//Temp values
	var size_x, size_y, angle, angle_point, ox, oy;
	
	//Top left position
	ox = bbox_left;
	oy = bbox_top;
	
	//Set the size of the tile
	size_x = sprite_width / 16;
	size_y = sprite_height / 16;
	
	//Set half point of the block
	angle_point = (bbox_right - bbox_left) / 2;
	
	//Play sound
	sound_play(sfx_break1);
	
	var left = bbox_left;
	var top = bbox_top;
	
	//Create pieces
	for (var i = 0; i < size_x; ++i) 
	{
		for (var j = 0; j < size_y; ++j) 
		{
			var obj = instance_create_depth(left + 16 * i, top + 16 * j, 300, obj_tilepiece);
			obj.sprite_index = sprite_index;
			obj.is_tile = false;
			obj.ox = 16 * i;
			obj.oy = 16 * j;
			
			//Angle speed
			angle = point_direction(ox+angle_point, bbox_bottom, obj.x + 8, obj.y + 8);
			obj.x_speed = i-size_x/2+0.5
			obj.y_speed = -(size_y+2)+j;
		}
	}