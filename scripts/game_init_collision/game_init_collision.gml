function game_init_collision()
{
	// Initilize tile arrays
	global.tile_top = ds_map_create();
	global.tile_bottom = ds_map_create();
	global.tile_left = ds_map_create();
	global.tile_right = ds_map_create();
	
	var tiles_to_compile = [spr_tile_collision_new]
	game_calculate_heights(tiles_to_compile)
	
}

function game_calculate_heights(array){
	
	// Get the old sprite mask
	var oldMask = mask_index;
	
	for (var j = 0; j < array_length(array); ++j) 
	{
		// For debugging purposes
		var oldTime = current_time;
		
		var sprite = array[j]
		
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
	//UNUSED
	if !layer_exists(global.col_tile[0]){
		return	
	}
	
	for (var j = 0; j < array_length(global.col_tile); ++j) 
	{
		global.col_tile_sprite[j] = layer_tilemap_get_colmask(layer_tilemap_get_id(global.col_tile[j]))
	}
	
	game_calculate_heights(global.col_tile_sprite)
}

/*
function game_tile_file_save(){
	//UNUSED
	show_debug_message("STARTING FILE SAVE...")
	
	var map_len = ds_map_size(global.tile_top)	
	for (var i = 0; i < map_len; ++i) {
	    var name = ds_map_keys_to_array(global.tile_top)[i];
		var maps = [global.tile_top,global.tile_bottom,global.tile_left,global.tile_right]
		var files = [".tilet",".tileb",".tilel",".tiler"]
		var m = 0
		repeat(4){
			var buff = buffer_create(1, buffer_grow, 1)
			var curr_map = maps[m][? name]
			var tile_len = array_length(curr_map)
			for (var j = 0; j < tile_len; ++j) {
				var t = 0
				repeat(16){
					buffer_write(buff,buffer_u8, curr_map[j][t])
					t++
				}
			}
			buffer_save(buff,sprite_get_name(name) + files[m])
			show_debug_message("SAVED TILE DATA TO {0}", sprite_get_name(name) + files[m])
			m++
			
		}
	}
}

function game_tile_file_load(){
	//UNUSED
	show_debug_message("STARTING FILE LOAD...")
	//top
	var _file_name = file_find_first("*.tilet", fa_none);
	while (_file_name != "")
	{
		var buff = buffer_load(_file_name)
		show_debug_message(_file_name)
		var sprite_name = string_split(filename_name(_file_name),".")[0]
		sprite_name = asset_get_index(sprite_name)
		var b_size = buffer_get_size(buff)
		
		ds_map_add(global.tile_top, sprite_name, [])
		var i = 0
		while (buffer_tell(buff) < b_size){
			
			array_push(global.tile_top[? sprite_name],[])
			repeat(16){
				array_push(global.tile_top[? sprite_name][i],buffer_read(buff,buffer_u8))
			}
			i++
		}
	    _file_name = file_find_next();
	}
	file_find_close();
	//bottom
	var _file_name = file_find_first("*.tileb", fa_none);
	while (_file_name != "")
	{
		var buff = buffer_load(_file_name)
		show_debug_message(_file_name)
		var sprite_name = string_split(filename_name(_file_name),".")[0]
		sprite_name = asset_get_index(sprite_name)
		var b_size = buffer_get_size(buff)
		
		ds_map_add(global.tile_bottom, sprite_name, [])
		var i = 0
		while (buffer_tell(buff) < b_size){
			
			array_push(global.tile_bottom[? sprite_name],[])
			repeat(16){
				array_push(global.tile_bottom[? sprite_name][i],buffer_read(buff,buffer_u8))
			}
			i++
		}
	    _file_name = file_find_next();
	}
	file_find_close();
	//left
	var _file_name = file_find_first("*.tilel", fa_none);
	while (_file_name != "")
	{
		var buff = buffer_load(_file_name)
		show_debug_message(_file_name)
		var sprite_name = string_split(filename_name(_file_name),".")[0]
		sprite_name = asset_get_index(sprite_name)
		var b_size = buffer_get_size(buff)
		
		ds_map_add(global.tile_left, sprite_name, [])
		var i = 0
		while (buffer_tell(buff) < b_size){
			
			array_push(global.tile_left[? sprite_name],[])
			repeat(16){
				array_push(global.tile_left[? sprite_name][i],buffer_read(buff,buffer_u8))
			}
			i++
		}
	    _file_name = file_find_next();
	}
	file_find_close();
	//right
	var _file_name = file_find_first("*.tiler", fa_none);
	while (_file_name != "")
	{
		var buff = buffer_load(_file_name)
		show_debug_message(_file_name)
		var sprite_name = string_split(filename_name(_file_name),".")[0]
		sprite_name = asset_get_index(sprite_name)
		var b_size = buffer_get_size(buff)
		
		ds_map_add(global.tile_right, sprite_name, [])
		var i = 0
		while (buffer_tell(buff) < b_size){
			
			array_push(global.tile_right[? sprite_name],[])
			repeat(16){
				array_push(global.tile_right[? sprite_name][i],buffer_read(buff,buffer_u8))
			}
			i++
		}
	    _file_name = file_find_next();
	}
	file_find_close();
}
*/
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
		
		array_push(global.tile_left[? collision_index][tile_index],pX);
		
		// Right side of the collision
		pX = 16;
		while(!position_meeting(x + tileX + pX - 1, y + tileY + w, self) && pX > 0)
		{
			pX--;
		}
		
		array_push(global.tile_right[? collision_index][tile_index],pX);
		
	}

}