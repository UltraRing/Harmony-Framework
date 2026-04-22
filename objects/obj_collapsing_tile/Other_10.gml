///@description Collapse it

    // Temp values
    var size_x = sprite_width / 16;
    var size_y = sprite_height / 16;
    
    // Play sound
    play_sound(sfx_break1);
    
    // Bounds
    var min_x = floor(x / 16);
    var max_x = min_x + size_x;
    var min_y = floor(y / 16);
    var max_y = min_y + size_y;
    
    // Loop tiles
    for (var i = min_x; i < max_x; i++) {
        for (var j = min_y; j < max_y; j++) {
    
            var px = i * 16;
            var py = j * 16;
    
            var piece = instance_create_depth(px, py, 100, obj_tilepiece);
            piece.delay += collapsing_delay;
            piece.collapse = true;
    
            piece.tile_id = 0;
    
            var layer_count = array_length(target_layer);
    
            // Process all visual layers
            for (var l = 0; l < layer_count; l++) {
    
                var tilelayer = layer_tilemap_get_id(target_layer[l]);
                var tile_id = tilemap_get_at_pixel(tilelayer, px, py);
    
                // store original tile
                if (!permanent) {
                    ds_list_add(tile_memory, {
                        _layer: target_layer[l],
                        _id: tile_id,
                        _x: px,
                        _y: py
                    });
                }
    
                // Pick the non-empty tile for visuals
                if (piece.tile_id == 0 && tile_id != 0) {
                    piece.tileset = tilemap_get_tileset(tilelayer);
                    piece.tile_id = tile_id;
                }
    
                // Remove tile
                tilemap_set_at_pixel(tilelayer, 0, px, py);
            }
    
            // Collision memory 
            if (!permanent) {
                for (var z = 0; z <= 1; z++) {
                    var tilelayer_c = layer_tilemap_get_id(global.col_tile[z]);
                    var data_c = tilemap_get_at_pixel(tilelayer_c, px, py);
    
                    ds_list_add(collision_memory[z], {
                        _id: data_c,
                        _x: px,
                        _y: py
                    });
                }
            }
    
            // Delay patterns 
            switch (collapsing_type) {
    
                case 0:
                    piece.delay = collapsing_speed * (size_y + 2 * (max_x - 1 - i) - (j - min_y));
                break;
    
                case 1:
                    piece.delay = collapsing_speed * (size_y + 2 * (i - min_x) - (j - min_y));
                break;
    
                case 2:
                    var tx = i - min_x;
                    if (tx < size_x / 2) tx = max_x - 1 - i;
                    piece.delay = collapsing_speed * ((size_y + 2 * tx - (j - min_y))) - size_x * 3;
                break;
    
                case 3:
                    var tx = i - min_x;
                    if (tx > size_x / 2) tx = max_x - 1 - i;
                    piece.delay = collapsing_speed * ((size_y + 2 * tx - (j - min_y)));
                break;
            }
        }
    }