/// @description Add background
	
	//Inherit the parent event
	event_inherited();
	
	//Vertical scroll factor
	var v_scroll = 0.7;
	
	//Add backgrounds, ID starting out from 0, increments by 1 with each background added
	background_add_layer(spr_bg_base, 0, 0.7, v_scroll, -0.25, -0.25, 0, 0, true);