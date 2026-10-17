/// @description Draw dev menu
	
	//Get the screen position
	var c = view_camera[view_current];
	var cx = camera_get_view_x(c);
	var cy = camera_get_view_y(c);
	
	// Make the HUD follow the camera
	draw_set_follow_camera();
	
	//Screen center values
	var center_x = WINDOW_WIDTH / 2;
	var center_y = WINDOW_HEIGHT / 2;
	
	//Change the font
	draw_set_font(global.font_debug);
	
	//Draw rectangle for the background
	draw_set_color(bg_color);
	draw_rectangle(center_x - 153, center_y - 28 - 44, center_x + 152, center_y + 34 - 44, false);
	draw_rectangle(center_x - 153, center_y - 28 + 28, center_x + 152, center_y + 27 + 44, false);
	draw_set_color(text_color);
	
	//Change text alingment to the center
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	
	//Draw the game header
	draw_text(center_x, center_y - 64, "HARMONY FRAMEWORK DEV MENU");
	draw_set_color(unselected_text_color);
	draw_text(center_x, center_y - 48, window_get_caption());
	draw_text(center_x, center_y - 40, GM_version);
	draw_text(center_x, center_y - 32, game_os_get_string() + " - Runtime: " + GM_runtime_version + "\nBuild Time: " + date_date_string(GM_build_date) + " " + date_time_string(GM_build_date));
	draw_set_color(text_color);
	
	//Draw dev menu's text
	switch(state)
	{
		//Draw normal menu selections
		case dev_menu_state.normal:
			for (var i = 0; i < array_length(menu_list); ++i) 
			{
				draw_set_color(menu_select == i ? text_color : unselected_text_color);
				draw_text(center_x, center_y + 8 + (16 * i), menu_list[i]);
			}
		break;
		
		//Draw the character select
		case dev_menu_state.character_select:
			draw_set_halign(fa_left);
			for (var i = character_select_offset; i < min(character_id, 7) + character_select_offset; ++i) 
			{
				draw_set_color(character_select == i ? text_color : unselected_text_color);
				draw_text(center_x - 64, center_y + 8 + (8 * (i - character_select_offset)), char_name[i]);
			}
		break;
		
		//Draw category select
		case dev_menu_state.category_select:
			draw_set_halign(fa_left);
			for (var i = category_offset; i < min(category_id, 7) + category_offset; ++i) 
			{
				draw_set_color(category_select == i ? text_color : unselected_text_color);
				draw_text(center_x - 80, center_y + 8 + (8 * (i - category_offset)), category_name[i]);
			}
		break;
		
		//Stage stage select
		case dev_menu_state.stage_select:
			draw_set_halign(fa_right);
			for (var i = scene_offset; i < min(array_length(scene_name[category_select + 1]), 7) + scene_offset; ++i) 
			{
				draw_set_color(scene_select == i ? text_color : unselected_text_color);
				draw_text(center_x + 80, center_y + 8 + (8 * (i - scene_offset)), scene_name[category_select + 1][i]);
			}
		break;
		
		//Draw options
		case dev_menu_state.options:
			for (var i = option_offset; i < min(option_id, 7) + option_offset; ++i) 
			{
				//Draw the name of the option
				draw_set_color(option_select == i ? text_color : unselected_text_color);
				draw_set_halign(fa_left);
				draw_text(center_x - 80, center_y + 8 + (8 * (i - option_offset)), option_name[i]);
				
				//Draw the number of the option
				draw_set_halign(fa_right);
				var number = variable_instance_get(global, option_variable[i]);
				var flag = number == 1 ? "True" : "False";
				draw_text(center_x + 80, center_y + 8 + (8 * (i - option_offset)), option_flag[i] ? flag : string(number));
			}
		break;
	}
	
	//Reset the color and text alingment
	draw_set_color(c_white);
	draw_set_halign(fa_left)

	// Stop following the camera
	draw_set_follow_end();