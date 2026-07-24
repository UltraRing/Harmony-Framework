/// @description Draw background
    for(var i = 0; i < bg_id; i++)
    {
        with(bg_layers[i])
        {
            background_update_layer_values();
            background_position_layer();
            background_draw_layer();
        }
    }	