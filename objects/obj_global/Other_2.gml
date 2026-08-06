/// @description Set the value
	// Force the controller object to be above everything
	depth = -1000;
	
	// Variables for this object only
	process_object_list = ds_list_create();
	instance_list = ds_list_create();
	time_start = 0;
	time_end = 0;
	
	// Initilize the game globals
	game_init_global_variables();
	game_init_font();
	game_init_collision();	
	game_init_audio();
	
	// Controllers init
	input_init();
	music_init();
	fade_init();
	bss_init();
	game_call_window_resize();
	
	// Define input actions
	input_add_action(INPUT.UP, vk_up, gp_padu, [gp_axislv, true]);
	input_add_action(INPUT.DOWN, vk_down, gp_padd, [gp_axislv, false]);
	input_add_action(INPUT.LEFT, vk_left, gp_padl, [gp_axislh, true]);
	input_add_action(INPUT.RIGHT, vk_right, gp_padr, [gp_axislh, false]);
	input_add_action(INPUT.A, "A", gp_face1);
	input_add_action(INPUT.B, "S", gp_face2);
	input_add_action(INPUT.C, "D", gp_face3);
	input_add_action(INPUT.START, vk_enter, gp_start);
	
	//Controlers for dev mode
	if(global.dev_mode) 
	{
		instance_create_depth(0, 0, 0, obj_dev);
		instance_create_depth(0, 0, 0, obj_shell);
	}
	
	//Ending event:
	room_goto_next();
	
