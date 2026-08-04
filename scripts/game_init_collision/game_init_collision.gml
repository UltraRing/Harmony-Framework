function game_init_collision()
{
	// Initilize tile arrays
	global.tile_top = ds_map_create();
	global.tile_bottom = ds_map_create();
	global.tile_left = ds_map_create();
	global.tile_right = ds_map_create();
	
}

function game_calculate_heights(){
	
	if !layer_exists(global.col_tile[0]){
		return	
	}
	
	// Get the old sprite mask
	var oldMask = mask_index;
	
	for (var j = 0; j < array_length(global.col_tile_sprite); ++j) 
	{
		// For debugging purposes
		var oldTime = current_time;
		
		var sprite = global.col_tile_sprite[j]
		
		if (ds_map_exists(global.tile_top, sprite)){
			continue;
		}
		show_debug_message(sprite)
		// Get the tile count
		var tileW = floor(sprite_get_width(sprite) / 16);
		var tileH = floor(sprite_get_height(sprite) / 16);
		var tileCount = tileW * tileH;
	
		mask_index = sprite;
		
		ds_map_add(global.tile_top, sprite, [])
		ds_map_add(global.tile_bottom, sprite, [])
		ds_map_add(global.tile_left, sprite, [])
		ds_map_add(global.tile_right, sprite, [])
		
		for (var i = 0; i < tileCount; ++i) 
		{
			_game_calculate_height(sprite, i, tileW);
		}
	
		show_debug_message("Collision index {1} height map baking took: {0} ms", current_time - oldTime, sprite);
	}
	// Restore it
	mask_index = oldMask;
}

function game_update_tile_sprites(){
	if !layer_exists(global.col_tile[0]){
		return	
	}
	
	for (var j = 0; j < array_length(global.col_tile); ++j) 
	{
		global.col_tile_sprite[j] = layer_tilemap_get_colmask(layer_tilemap_get_id(global.col_tile[j]))
	}
}

function _game_calculate_height(collision_index, tile_index, tile_width)
{
	var tileX = 16 * (tile_index % tile_width);
	var tileY = 16 * floor(tile_index / tile_width);
	
	array_push(global.tile_top[? collision_index],[])
	array_push(global.tile_bottom[? collision_index],[])
	array_push(global.tile_left[? collision_index],[])
	array_push(global.tile_right[? collision_index],[])
	
	for(var w = 0; w < 16; w++)
	{
		var pY = 16;
		while(!position_meeting(x + tileX + w, y + tileY + 16 - pY, self) && pY > 0)
		{
			pY--;
		}
		
		array_push(global.tile_top[? collision_index][tile_index],pY);
		
		pY = 16;
		while(!position_meeting(x + tileX + w, y + tileY + pY - 1, self) && pY > 0)
		{
			pY--;
		}
		
		array_push(global.tile_bottom[? collision_index][tile_index],pY);
		
		var pX = 16;
		while(!position_meeting(x + tileX + 16 - pX, y + tileY + w, self) && pX > 0)
		{
			pX--;
		}
		
		array_push(global.tile_left[? collision_index][tile_index],pY);
		
		// Right side of the collision
		pX = 16;
		while(!position_meeting(x + tileX + pX - 1, y + tileY + w, self) && pX > 0)
		{
			pX--;
		}
		
		array_push(global.tile_right[? collision_index][tile_index],pY);
		
	}

}