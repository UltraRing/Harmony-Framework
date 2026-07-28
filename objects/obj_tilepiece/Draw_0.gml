/// @description Draw pieces
	if(!is_tile) 
		draw_tile(tileset, tile_id, 0, x, y);
	else
		draw_sprite_part_ext(sprite_index, image_index, ox, oy, 16, 16, x, y, image_xscale, image_yscale, image_blend, image_alpha);