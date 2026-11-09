/// @description End script
	
	//Stop if player doesn't exist
	if(!instance_exists(obj_player)) exit;
	
	//Show collision
	if(layer_exists("CollisionTriggers")) layer_set_visible("CollisionTriggers", show_collision);
	if(layer_exists(global.col_tile[0])) layer_set_visible(global.col_tile[0], show_collision);
	if(layer_exists(global.col_tile[1])) layer_set_visible(global.col_tile[1], show_collision);
	if(layer_exists(global.col_tile[2])) layer_set_visible(global.col_tile[2], obj_player.plane == 0 ? show_collision : false);
	if(layer_exists(global.col_tile[3])) layer_set_visible(global.col_tile[3], obj_player.plane == 1 ? show_collision : false);
	
	