/// @description Destroy tiles
	//Temp values
	var tilelayer, tileset, data, size_x, size_y, obj, l_depth, min_x, max_x, min_y, max_y;
	
	var target_tile_layers = string_split(target_layer,",", true)
	
	//Get sprite size
	size_x = sprite_width / 16;
	size_y = sprite_height / 16;
	
	//Play sound
	sound_play(sfx_break1);
    
	//Collapsing platform's bounding box in 16x16 size
	min_x = floor(x / 16.0);
    max_x = min_x + size_x;
    min_y = floor(y / 16.0);
    max_y = min_y + size_y;
	
	var layers_size = array_length(target_tile_layers)
	
	if layers_size == 0 {
		show_debug_message("WARNING! No Tile Layers found... Should have at least one.")	
		return
	}
	
	for (var p = 0; p < layers_size; ++p) {
	    //Get layer tilemap
		tilelayer = layer_tilemap_get_id(target_tile_layers[p]);
        
		//Get the used tileset
		tileset = tilemap_get_tileset(tilelayer);
        
		 for (var i = min_x; i < max_x; i++) 
		 {
	        for (var j = min_y; j < max_y; j++) 
			{
				//Create piece object
	            var piece = instance_create_depth((i * 16.0), (j * 16.0), layer_get_depth(target_tile_layers[p]) - 2, obj_tilepiece);
                
				//Add the general delay
				piece.delay += collapsing_delay;
                
				piece.tileset = tileset;
				piece.tile_id = tilemap_get_at_pixel(tilelayer, piece.x, piece.y);
				piece.collapse = true;
				piece.permanent = permanent
				piece.refrence = self
                
				//Remove tiles from the area
				tilemap_set_at_pixel(tilelayer, 0, piece.x, piece.y);
                
				//Different cases for collapsing delay
				switch(collapsing_type)
				{
					//From right to left
					case "Right to Left":
						piece.delay = collapsing_speed * (size_y + 2 * (max_x - 1 - i) - (j - min_y));
					break;
                    
					//From left to right
					case "Left to Right":	
						piece.delay = collapsing_speed * (size_y + 2 * (i - min_x) - (j - min_y));
					break;
                    
					//From the center
					//and from both left and right
					case "From the Center":
					case "Both Left and Right":
						var tx = i - min_x;
		                var collapsing_point = collapsing_type == "From the Center" ? (tx < size_x / 2) : (tx > size_x / 2);
						if (collapsing_point)
						{
		                    tx = max_x - 1 - i;
						}
		                
						var collapsing_point_delay = collapsing_type == "From the Center" ? (size_x * 3) : 0;
						piece.delay = collapsing_speed * ((size_y + 2 * (tx) - (j - min_y))) - collapsing_point_delay;
					break;
				}
	        }
	    }
	}