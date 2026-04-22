///@description Initialize variables

    triggered = false;
    
    tile_memory = ds_list_create();
    collision_memory = [ds_list_create(), ds_list_create()];
    
    if (is_string(target_layer)) {
        var names = string_split(target_layer, ",");
        var arr = [];
    
        for (var n = 0; n < array_length(names); n++) {
            array_push(arr, layer_get_id(string_trim(names[n])));
        }
    
        target_layer = arr;
    }
    else if (!is_array(target_layer)) {
        target_layer = [target_layer];
    }