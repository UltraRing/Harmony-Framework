/// @description Script

	//Exit the dev menu
	if(keyboard_check_pressed(vk_escape) && cool_down = 0 || input_press(INPUT.B) && cool_down = 0 && state == dev_menu_state.normal)
	{
		//Trigger the window event
		game_call_window_resize();
		
		global.process_objects = true;
		instance_destroy();
	}
	
	//Cool down the exit timer
	cool_down = max(cool_down - 1, 0);
	
	//Horizontal inputs
	var input_h_final = input_get_x(8),
		input_v_final = -input_get_y(8);
	
	//Menu state machine
	switch(state)
	{
		//Normal menu state
		case dev_menu_state.normal:
			//Change the menu selection
			menu_select += input_v_final;
			menu_select = math_wrap(menu_select, 0, array_length(menu_list) - 1);
		
			//Change the menu state
			if(input_press(INPUT.START) || input_press(INPUT.A))
			{
				switch(menu_select)
				{
					//Start the whole game
					case 0:	
						game_restart();
					break;
					
					//Go to the character select
					case 1:
						state = dev_menu_state.character_select;
					break;
					
					//Go to options
					case 2:
						state = dev_menu_state.options;
					break;
				
					//Exit the game
					case 3:
						game_end();
					break;
				}
			}
		break;
		
		//Character select state
		case dev_menu_state.character_select:
			//Change the menu selection
			character_select += input_v_final;
			character_select = math_wrap(character_select, 0, character_id - 1);
			
			//Scroll menu text up
			if(character_select > 6 + character_select_offset)
			{
				character_select_offset = character_select - 6;
			}
			
			//Scroll menu text down
			if(character_select < character_select_offset)
			{
				character_select_offset = character_select;
			}
			
			//Go back to the normal state
			if(input_press(INPUT.B))
			{
				character_select = 0;
				state = dev_menu_state.normal;
			}
			
			//Proceed to the scene category select
			if(input_press(INPUT.START) || input_press(INPUT.A))
			{
				state = dev_menu_state.category_select;
			}
			
		break;
		
		//Category select state
		case dev_menu_state.category_select:
			//Change the menu selection
			category_select += input_v_final;
			category_select = math_wrap(category_select, 0, category_id - 1);
			
			//Scroll menu text up
			if(category_select > 6 + category_offset)
			{
				category_offset = category_select - 6;
			}
			
			//Scroll menu text down
			if(category_select < category_offset)
			{
				category_offset = category_select;
			}
			
			//Go back to character select
			if(input_press(INPUT.B))
			{
				category_select = 0;
				state = dev_menu_state.character_select;
			}
			
			//Proceed to scene select
			if(input_press(INPUT.START) || input_press(INPUT.A))
			{
				state = dev_menu_state.stage_select;
			}
		break;
		
		case dev_menu_state.stage_select:
			//Change the menu selection
			scene_select += input_v_final;
			scene_select = math_wrap(scene_select, 0, array_length(scene_name[category_select + 1]) - 1);
			
			//Scroll menu text up
			if(scene_select > 6 + scene_offset)
			{
				scene_offset = scene_select - 6;
			}
			
			//Scroll menu text down
			if(scene_select < scene_offset)
			{
				scene_offset = scene_select;
			}
			
			//Go back to category select
			if(input_press(INPUT.B))
			{
				scene_select = 0;
				state = dev_menu_state.category_select;
			}
			
			//Enter the scene
			if(input_press(INPUT.START) || input_press(INPUT.A))
			{
				//Destroy the dev menu and activate everything
				instance_destroy();
				instance_activate_all();
				
				//Enable object processing
				global.process_objects = true;
				
				//Set the character id
				global.character = character_select;
				
				//Reset the stage data
				level_reset_data();
				level_reset_bg_visibility();
				
				//Go to the room
				room_goto(scene_room[category_select + 1][scene_select]);
			}
		break;
		
		case dev_menu_state.options:
			//Change the menu selection
			option_select += input_v_final;
			option_select = math_wrap(option_select, 0, option_id - 1);
			
			//Scroll menu text up
			if(option_select > 6 + option_offset)
			{
				option_offset = option_select - 6;
			}
			
			//Scroll menu text down
			if(option_select < option_offset)
			{
				option_offset = option_select;
			}
			
			//Go back to normal state
			if(input_press(INPUT.B))
			{
				//Refresh the window
				game_call_window_resize();
				
				//Reset
				option_select = 0;
				state = dev_menu_state.normal;
			}
			
			//Update the option flags
			if(option_flag[option_select])
			{
				//Get the selected variable
				var val = variable_instance_get(global, option_variable[option_select]);
				
				//If either left or right is pressed, update the flag
				if(input_h_final != 0)
				{
					//Flip the flag
					val = !val;
					
					//Update the variable
					variable_instance_set(global, option_variable[option_select], val);		
				}
			}
			else	//Options that use decimals
			{
				//Get the selected variable
				var val = variable_instance_get(global, option_variable[option_select]);
				
				//Update the variable when either left or right is being pressed
				var result = option_number[option_select] * input_h_final;
				
				//Update the variable
				variable_instance_set(global, option_variable[option_select], clamp(val + result, option_min[option_select], option_max[option_select]));	
			}
		break;
	}