/// @description Add background
	
	//Inherit the parent event
	event_inherited();
	
	//Vertical scroll factor
	var v_scroll = 0.88;
	
	//Add backgrounds, ID starting out from 0, increments by 1 with each background added
    with (background)
    {
        background_add_layer(spr_bg_aaz_clouds, 0, 0.9, v_scroll, -0.2, 0, 0, 0);
        background_add_layer(spr_bg_aaz_clouds, 1, 0.93, v_scroll, -0.15, 0, 0, 0);
        background_add_layer(spr_bg_aaz_clouds, 2, 0.95, v_scroll, -0.1, 0, 0, 0);
        background_add_layer(spr_bg_aaz_clouds, 3, 0.97, v_scroll, -0.05, 0, 0, 0);
        background_add_layer(spr_bg_aaz_clouds, 4, 0.99, v_scroll, 0, 0, 0, 0);
        background_add_line_layer(spr_bg_aaz_water, 0, 0.94, v_scroll, 0, 0, 0, 128, 2, 0.006);
        background_add_layer(spr_bg_aaz_mountains, 0, 0.98, v_scroll, 0, 0, 0, 80);
        background_add_layer(spr_bg_aaz_mountains, 1, 0.94, v_scroll, 0, 0, 0, 80);
        background_add_layer(spr_bg_aaz_bottom, 4, 1, v_scroll, 0, 0, 0, 164);
        background_add_layer(spr_bg_aaz_bottom, 2, 0.84, v_scroll, 0, 0, 0, 144);
        background_add_layer(spr_bg_aaz_bottom, 0, 0.8, v_scroll, 0, 0, 0, 144);
        background_add_layer(spr_bg_aaz_bottom, 1, 0.78, v_scroll, 0, 0, 0, 144);
        background_add_layer(spr_bg_aaz_bottom, 3, 0.72, v_scroll, 0, 0, 0, 144);
    }