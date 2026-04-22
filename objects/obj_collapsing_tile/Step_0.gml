///@description Update

    // Collapse trigger
    if (obj_player.ground && player_collide_object(C_BOTTOM) && !triggered) {
        triggered = true;
        event_user(0);
    }
    
    // Restore when offscreen
    if (triggered && !on_screen(32,32) && !permanent) {
    
        /// restore visual tiles 
        while (ds_list_size(tile_memory)) {
            var data = tile_memory[| 0];
            var tilelayer = layer_tilemap_get_id(data._layer);
    
            tilemap_set_at_pixel(tilelayer, data._id, data._x, data._y);
    
            ds_list_delete(tile_memory, 0);
        }
    
        // Restore collision
        for (var i = 0; i < 2; i++) {
            var tilelayer = layer_tilemap_get_id(global.col_tile[i]);
    
            while (ds_list_size(collision_memory[i])) {
                var data = collision_memory[i][| 0];
    
                tilemap_set_at_pixel(tilelayer, data._id, data._x, data._y);
    
                ds_list_delete(collision_memory[i], 0);
            }
        }
    
        triggered = false;
    }