/// @description Draw pieces
	if(is_tile)
		draw_tile(tileset, tile_id, 0, x, y);
	else
		draw_sprite_part(sprite_index, 0, ox, oy, 16, 16, floor(x), floor(y));