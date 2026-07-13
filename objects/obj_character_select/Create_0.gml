	menu = obj_main_menu;
	
	for(var i = 0; i < global.character_total; i++)
	{
		sprites[i] = char_get_menu_sprite(i);
		char_names[i] = string_upper(char_get_name(i));
	}
	
	char_y = array_create(global.character_total, 0);
	select = 0;
	
	transition_offset = 256;
	transition_timer = 1;
	
	leave = false;
	returning = false;
	return_timer = 0;