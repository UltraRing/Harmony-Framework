/// @description Add background
	
	//Inherit the parent event
	event_inherited();
	
	//Add backgrounds, ID starting out from 0, increments by 1 with each background added
	background_add_layer(spr_bg_bonus, 0, 1, 0.75, 0, 0, 0, 0, true);
	background_add_layer(spr_bg_bonus, 1, 1, 0.5, 0, 0, 0, 0, true);