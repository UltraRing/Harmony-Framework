	/// @description 
	display_set_gui_size(WINDOW_WIDTH * 2, WINDOW_HEIGHT * 2);
	
	
	draw_set_font(global.font_debug);
	
	if(show_player && instance_exists(obj_player))
	{
		if(!surface_exists(graded_surf))graded_surf = surface_create(WINDOW_WIDTH * 2, WINDOW_HEIGHT * 2);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		var gw = display_get_gui_width();
		var gh = display_get_gui_height();
		
		surface_set_target(graded_surf);
		draw_rectangle((gw-256) / 2, 16 / 2, (gw-16) / 2, (gh-16) / 2, false);
		gpu_set_colorwriteenable(1,1,1,0) //dont make the dumb bitch draw over the rest of the screen
		effect_set_color_grading(tex_lut_debug, 32,global.object_timer/6)
		surface_copy(graded_surf, 0, 0, application_surface); //get screen from before
		shader_reset(); //reset before it does anything else
		gpu_set_colorwriteenable(1,1,1,1)
	
		surface_reset_target();
	
		draw_surface_ext(graded_surf, 0, 0, 2, 2, 0, c_white, 1);
		
		draw_state_push();
		var debug_menu_name = "PLAYER DEBUG MENU";
		var is_objplayer = false
		if(instance_exists(instance_selected))
		{
			if(instance_selected.object_index != obj_player)
			{
				is_objplayer = true
			}
		}
		// If we're dealing with an object, set the debug menu name to the name of the object
		if(is_objplayer)
			debug_menu_name = string_replace(string_upper(curr_submenu.name),"OBJ_","")
		var text_offset_x = 4;
		var text_offset_y = 4;
		var shadow_off_x = 2;
		var shadow_off_y = 2;
		draw_set_alpha(1);
		draw_sprite(spr_hud_debug_header,0,(gw-256),16)
		draw_set_colour(c_white);
		if(instance_exists(obj_player)) {
			draw_set_halign(fa_center)
			draw_set_color(c_black);
			draw_text(gw-128-shadow_off_x+text_offset_x,16+shadow_off_y+text_offset_y,debug_menu_name)
			draw_set_colour(c_white);
			draw_text(gw-128+text_offset_x,16+text_offset_y,debug_menu_name)
			draw_set_halign(fa_left)
			
		if(!is_objplayer)
		{
			// The state of the player
			with(obj_player) {
				draw_set_color(c_black);
				draw_text(gw-256-shadow_off_x+text_offset_x,32+shadow_off_y+text_offset_y, "STATE: " + string_upper(string_replace(string(state),"ref script ","")))
				draw_set_colour(c_white);
				draw_text(gw-256+text_offset_x,32+text_offset_y, "STATE: " + string_upper(string_replace(string(state),"ref script ","")))
				draw_set_color(c_black);
				draw_text(gw-256-shadow_off_x+text_offset_x,40+shadow_off_y+text_offset_y, "ANIM_STATE: " + string_upper(string_replace(string(animation_get_sprite(animator, animation_get_current_animation(animator))),"ref sprite ","")))
				draw_set_colour(c_white);
				draw_text(gw-256+text_offset_x,40+text_offset_y, "ANIM_STATE: " + string_upper(string_replace(string(animation_get_sprite(animator, animation_get_current_animation(animator))),"ref sprite ","")))
			}
			
			// Draw other variables of player
			draw_set_color(c_black);
			for(var i = 0; i < player_debug_length; ++i) {
				draw_text(gw-256-shadow_off_x+text_offset_x,48+shadow_off_y+text_offset_y+i*8,string_upper(player_debug_values[i] + ": " + string(variable_instance_get(obj_player,player_debug_values[i]))))
			}
			draw_set_colour(c_white);
			for(var i = 0; i < player_debug_length; ++i) {
				draw_text(gw-256+text_offset_x,48+text_offset_y+i*8,string_upper(player_debug_values[i] + ": " + string(variable_instance_get(obj_player,player_debug_values[i]))))
			}
			
			// Separated the shield debug since it doesn't have the shield name normally
			if(obj_player.shield != -1)
			{
				if(obj_player.shield < array_length(obj_player.shield_list))
				{
					draw_set_colour(c_black);
					draw_text(gw-256-shadow_off_x+text_offset_x,48+shadow_off_y+text_offset_y+8*player_debug_length, "SHIELD: " + string_upper(string_replace(string(obj_player.shield_list[obj_player.shield]),"ref script ","")))
					draw_set_colour(c_white);
					draw_text(gw-256+text_offset_x,48+text_offset_y+8*player_debug_length, "SHIELD: " + string_upper(string_replace(string(obj_player.shield_list[obj_player.shield]),"ref script ","")))
				}
			}
			else { 
				draw_set_color(c_black);
				draw_text(gw-256-shadow_off_x+text_offset_x,48+shadow_off_y+text_offset_y+8*player_debug_length, "SHIELD: " + "NONE")
				draw_set_colour(c_white);
				draw_text(gw-256+text_offset_x,48+text_offset_y+8*player_debug_length, "SHIELD: " + "NONE")
			}
			
			draw_set_halign(fa_center)
			draw_set_color(c_black);
			draw_text(gw-128-shadow_off_x+text_offset_x,64+shadow_off_y+text_offset_y+8*player_debug_length,"DEV MESSAGES")
			draw_set_colour(c_white);
			draw_text(gw-128+text_offset_x,64+text_offset_y+8*player_debug_length,"DEV MESSAGES")
			draw_set_halign(fa_left)
			
			// Draw the dev messages from show_dev_message
			draw_set_color(c_black);
			for(var i = 0; i < array_length(dev_messages); ++i) {
				draw_text(gw-256-shadow_off_x+text_offset_x,80+8*player_debug_length+shadow_off_y+text_offset_y+i*8,dev_messages[i])
			}
			draw_set_colour(c_white);
			for(var i = 0; i < array_length(dev_messages); ++i) {
				draw_text(gw-256+text_offset_x,80+text_offset_y+8*player_debug_length+i*8,dev_messages[i])
			}
			
		}
		else {			
			// Draw enemy variables
			draw_set_color(c_black);
			for(var i = 0; i < curr_submenu.selected_instance_length; ++i) {
				var _key = curr_submenu.instance_keys[i]
				var _values = curr_submenu.selected_instance_var[$ _key]
				draw_text(gw-256+shadow_off_x+text_offset_x,32+shadow_off_y+text_offset_y+i*8,string_upper(_key + ": " + string(_values)))
			}
			draw_set_colour(c_white);
			for(var i = 0; i < curr_submenu.selected_instance_length; ++i) {
				var _key = curr_submenu.instance_keys[i]
				var _values = curr_submenu.selected_instance_var[$ _key]
				draw_text(gw-256+text_offset_x,32+text_offset_y+i*8,string_upper(_key + ": " + string(_values)))
			}
		}
		draw_set_colour(c_black);
		draw_set_alpha(0.5);
		}
		draw_state_pop();
		var hd_w, hd_h;
		hd_w = WINDOW_WIDTH * 2;
		hd_h = WINDOW_HEIGHT * 2;
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		var t = (obj_global.time_end - obj_global.time_start) / 1000.0
		
		draw_text(0, 0, "Total Step Time: " + string_format(t, 2, 4))
		draw_text(0, 8, "Object Culling Pool: " + string(ds_list_size(obj_level.instance_list)))
		if(instance_exists(instance_near_mouse))
		draw_text(0,16,"Hover Target: " + string(object_get_name(instance_near_mouse.object_index)))
	}
	