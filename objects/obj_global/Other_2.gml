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
	
	
	/*
		"CompileTiles" is a project config. that config will run functions to generate a file that stores
		all the tile collsion data for the sprites listed in the array below. These files are then loaded
		on game start.
		
		This should only be used if you use large, unoptimzied collision tilesets (i.e. the collision
		tileset prior to 1.0.) The collision generation during runtime is a fair bit expencive, 
		so in the worse case scenario it can cause the level to take a second to load on room start.
		
		After running the game in the "CompileTiles" config. Go to the project's runtime data directory.
		(On Windows, this would be in "%LOCALAPPDATA%" and whatever your project name is.)
		If generated correctly, the files should have the file extention of ".tilet", ".tileb", etc.
		
		Make sure to copy these files and place them within the project's "Included Files", or else
		other users (developers or players) will not have these in their copy of the game.
	*/
	if (COMPILETILES){
		var tiles_to_compile = [spr_tile_collision_new]
		
		game_calculate_heights(tiles_to_compile)
		game_tile_file_save()
		game_end();	
	} else {
		game_tile_file_load()
	}
	
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
	
