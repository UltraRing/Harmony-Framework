	//Essential values
	zone_sel = 0;
	act_sel = 0;
	sound_sel = 0;
	sound_arr = ds_map_keys_to_array(global.music_map);
	input_disable = false;
	
	show_debug_message("key for map 0");
	show_debug_message(sound_arr[0]);
	
	//Zone list array
	//Example: ["YOUR ZONE", rm_your_zone1, rm_your_zone2, rm_your_zone3] and so on... for as many acts as you want
	zone_list = [
	["ARBOREAL AGATE", rm_arboreal_agate1, rm_arboreal_agate2],
	["TEST STAGE", rm_techdemo_tower],
	];
	
	level_reset_data();
	level_reset_bg_visibility();
	global.score = 0;
	
	quotes = ["WELCOME TO HARMONY FRAMEWORK!"];
	
	//Choose a random quote out of the ones defined above
	quote_index = irandom(array_length(quotes)-1);
	
	image_speed = 0;
	image_index = 0;
	
	fade_in_room(5);
	music_play(MUSIC.MAIN_MENU);
	
	//Create background deform data for shader
	for (var i = 0; i < 128; ++i) 
	{
	    deform_data[i] = 12 * dsin((360 / 128) * i);
	}