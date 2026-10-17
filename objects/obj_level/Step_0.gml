/// @description Script

	//Timers
	if(!disable_timer) global.stage_timer += 1000/60
	
	//Cap the stage timer
	global.stage_timer = min(global.stage_timer, 599999);
	
	//Hide collision layer
	if(layer_exists("CollisionTriggers")) layer_set_visible("CollisionTriggers", false);
	if(layer_exists(global.col_tile[0])) layer_set_visible(global.col_tile[0], false);
	if(layer_exists(global.col_tile[1])) layer_set_visible(global.col_tile[1], false);
	if(layer_exists(global.col_tile[2])) layer_set_visible(global.col_tile[2], false);
	if(layer_exists(global.col_tile[3])) layer_set_visible(global.col_tile[3], false);
	
	//Reset act transition flag
	global.act_transition = false;
	
	//Extra life with rings
	if(global.rings >= global.ring_extralife)
	{
		global.ring_extralife += 100;
		global.life += 1;
		music_play_jingle();
	}
	if(global.rings <= global.ring_extralife-200 && !instance_exists(obj_combine_ring))
	{
		global.ring_extralife -= 100;

	}
	
	//Extra life with rings
	if(global.score >= global.score_extralife)
	{
		global.score_extralife += 50000;
		global.life += 1;
		music_play_jingle();
	}
	if(global.score <= global.score_extralife-100000)
	{
		global.score_extralife -= 50000;

	}