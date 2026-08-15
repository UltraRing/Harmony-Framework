/// @description Dev menu
	game_set_speed(60, gamespeed_fps);
	
	if(keyboard_check_pressed(vk_escape) && !instance_exists(obj_dev_menu) && !obj_shell.isOpen)
	{
		instance_create_depth(0, 0, -99999, obj_dev_menu)
	}
	
	//Destroy just in case
	if(!global.dev_mode) 
		instance_destroy();
	
	//Go to level select
	if(keyboard_check_pressed(ord("M")) && !obj_shell.isOpen)
	{
		fade_to_room(rm_stage_select, 4);
		music_set_fade(FADE.OUT, 5);
	}
	
	//Toggle debug mode
	if(keyboard_check_pressed(vk_f5) && instance_exists(obj_shell)) obj_shell.isOpen = !obj_shell.isOpen;
	
	if(!obj_shell.isOpen)
	{
		// Enter debug state
		if(keyboard_check_pressed(vk_tab)) debug = !debug;
		// Toggle HUD render visibility
		if(keyboard_check_pressed(ord("B")) && instance_exists(obj_hud)) obj_hud.render = !obj_hud.render;
		// Toggle title card visibility
		if(keyboard_check_pressed(ord("T"))) global.title_card = !global.title_card;
		// Toggle collision visibility
		if(keyboard_check_pressed(vk_f9)) show_collision = !show_collision;
		// Toggle hitbox and tile collision visibility
		if(keyboard_check_pressed(vk_f8)) show_hitbox = !show_hitbox;
		// Toggle FPS visibility
		if(keyboard_check_pressed(vk_f3)) show_fps = !show_fps;
		// Toggle mute music
		if(keyboard_check_pressed(ord("N"))) global.bgm_volume = (global.bgm_volume + 1) mod 2;
		// Toggle entity debug menu
		if(keyboard_check_pressed(vk_f7)) show_player = !show_player;
		// Toggle culling visibility
		if(keyboard_check_pressed(vk_f12)) show_culling = !show_culling;
		// Change window size
		if(keyboard_check_pressed(vk_f4)) 
		{
			//Change the value and modulate it
			global.window_size = math_wrap(global.window_size + 1, 1, global.window_size_limit);
			game_call_window_resize();
		}
		
		// Restart level
		if(keyboard_check_pressed(vk_f2)) 
		{
			fade_to_room(room, 5);
			music_set_fade(FADE.OUT, 5);
		}
		
		// Restart game
		if(keyboard_check_pressed(vk_f1)) game_restart();
		
		// Change the player *note : if you have more than 3 characters, change the mod 3 to mod (number of characters)
		if(keyboard_check_pressed(vk_f10))
		{
			global.character = (global.character + 1) mod 3;
			with(obj_player)
			{
				player_animation_list();
				animator_reset(animator);

			}
			with(obj_bss_controller) bss_setup_character();
		}
		
		// Slow the game down
		if(keyboard_check(vk_f6)) game_set_speed(5, gamespeed_fps);
		// Speed the game up
		if(keyboard_check(vk_backspace)) game_set_speed(240, gamespeed_fps);
	
		//Stop if player doesn't exist
		if(!instance_exists(obj_player)) exit;
	
		// Clear the act
		if(keyboard_check_pressed(ord("V")) && !instance_exists(obj_act_clear)){
			instance_create_layer(0, 0, "Utilities", obj_act_clear)
			obj_level.act_transition = false;
		}
		
		//Add rings
		if(keyboard_check(ord("1")))
		{
			global.rings++;
			sound_play(sfx_ring);
		}
		
		//Give the player extra life
		if(keyboard_check_pressed(ord("2")))
		{
			global.life++;
			music_play_jingle();
		}
		
		//Change shields
		if(keyboard_check_pressed(ord("3")))
		{
			obj_player.shield++;
			
			if(obj_player.shield >= array_length(obj_player.shield_list))
			{
				obj_player.shield = -1;
			}
		}
		
		//Give the player invincibility
		if(keyboard_check_pressed(ord("4")))
		{
			obj_player.invincible = true;
			obj_player.invincible_timer = 1200;
		}
		
		//Give the player speed shoes
		if(keyboard_check_pressed(ord("5")))
		{
			obj_player.speed_shoes_flag = true;
			obj_player.speed_shoes = 1200;
		}
		
		//Combine Rings
		if(keyboard_check_pressed(ord("6")))
		{
			obj_player.combinering = 1;
			sound_play(sfx_combinering);
		}
		
		//Hurt the player
		if(keyboard_check_pressed(ord("7")))
		{
			player_hurt(obj_player.x + obj_player.facing);
		}
		
		//Kill the player
		if(keyboard_check_pressed(ord("8")))
		{
			player_hurt(0, K_DIE);
		}
		
		//Toggle teleport
		if(keyboard_check_pressed(vk_space) && instance_exists(obj_debug_teleport))
		{
			var t = instance_find(obj_debug_teleport, teleport_id);
		
			obj_player.x = t.x;
			obj_player.y = t.y;
			obj_camera.camera_x = t.x;
			obj_camera.camera_y = t.y;
			
			obj_camera.target_x = obj_camera.camera_x;
			obj_camera.target_y = obj_camera.camera_y - 16;
			obj_camera.target_right = room_width;
			obj_camera.target_top = 0;
			obj_camera.target_bottom = room_height;
			obj_camera.limit_right = room_width;
			obj_camera.limit_top = 0;
			obj_camera.limit_bottom = room_height;
			
			teleport_id++;
			teleport_id %= instance_number(obj_debug_teleport);
		}
	}
	//Stop if player doesn't exist
	if(!instance_exists(obj_player)) exit;
		
	//Change player debug flag
	obj_player.debug = debug;
	
	// Object grabber
	
	// Copies data from object nearest to the mouse
	instance_near_mouse = instance_nearest(mouse_x,mouse_y,all)
	var instance_mouse_ind = noone
	
	// Check if the instance near the mouse is actually near the mouse
	if !(abs(instance_near_mouse.x - mouse_x) < 32 && abs(instance_near_mouse.y - mouse_y) < 32) instance_near_mouse = noone;
	else instance_mouse_ind = instance_near_mouse.object_index
	
	// If the submenu is enabled, disable it when right-clicking
	if(mouse_check_button_pressed(mb_right) && curr_submenu.enabled) curr_submenu.enabled = false;
	// If we're not in debug mode, but we are in show player, and there's something near the mouse, do the following.
	if(!debug && instance_mouse_ind != noone && show_player) {
		// Begin copying object
		if(mouse_check_button_pressed(mb_left)) {
			// Checks to make sure that the object is not part of the debug list
			if(!array_contains(object_list,instance_near_mouse) && instance_mouse_ind != obj_effect && instance_mouse_ind != obj_dust_effect && instance_mouse_ind != obj_monitor_icon && instance_mouse_ind != obj_debris && instance_mouse_ind != obj_player) {
				// Play grabbed sound
				sound_play(sfx_warp_ring)
				
				// Pushes the object into the array, THIS is the actual object being added
				array_push(object_list,instance_mouse_ind)
				
				// Grabs meta data for object
				var meta_data = variable_instance_get_names(instance_near_mouse)
				object_list_metadata[object_list_length] = {};
				for(var i = 0; i < array_length(meta_data); ++i) {
					object_list_metadata[object_list_length][$ meta_data[i]] = variable_instance_get(instance_near_mouse, meta_data[i]);
				}
				object_list_metadata[object_list_length].image_xscale = instance_near_mouse.image_xscale;
				object_list_metadata[object_list_length].image_yscale = instance_near_mouse.image_yscale;
				object_list_metadata[object_list_length].image_angle = instance_near_mouse.image_angle;
				object_list_metadata[object_list_length].sprite_index = instance_near_mouse.sprite_index;
				object_list_length++;
				grabbed_data_anim = [instance_near_mouse.x,instance_near_mouse.y,60]
			}
			// if it doesn't work out, play this sound
			else sound_play(sfx_boss_hit)
		}
				// If right clicking, 
				if(mouse_check_button_pressed(mb_right)) {
					instance_selected = instance_near_mouse;
					curr_submenu.enabled = true;
					curr_submenu.name = object_get_name(instance_selected.object_index)
					curr_submenu.instance_keys = variable_instance_get_names(instance_selected)
					curr_submenu.selected_instance_length = variable_instance_names_count(instance_selected)
				}
	}
		// If the object menu is enabled, update the variables within the menu
		if(curr_submenu.enabled) {
			if(instance_exists(instance_selected)) {
				for(var i = 0; i < curr_submenu.selected_instance_length; ++i) {
					curr_submenu.selected_instance_var[$ curr_submenu.instance_keys[i]] = variable_instance_get(instance_selected,curr_submenu.instance_keys[i])
				}
			}
			else curr_submenu.enabled = false;
		}
	
	//Disable not in debug mode
	if(!debug) exit;
	
	var c, cx, cy;
	c = view_camera[view_current];
	cx = camera_get_view_x(c);
	cy = camera_get_view_y(c);
	
	// Set variables for scale
	var temp_x_scale = 0;
	var temp_y_scale = 0;
	if(mouse_check_button_pressed(mb_left)) {
		mouse_clicked_pos_x = mouse_x
		mouse_clicked_pos_y = mouse_y
	}
	if(keyboard_check(vk_lshift)) {
		// Change scale
		temp_x_scale = abs(mouse_clicked_pos_x - mouse_x)
		temp_y_scale = abs(mouse_clicked_pos_y - mouse_y)
		//Move cursor
		cursor_x = min(mouse_x,mouse_clicked_pos_x) - cx;
		cursor_y = min(mouse_y,mouse_clicked_pos_y) - cy;
	}
	else {
		//Move cursor
		cursor_x = mouse_x - cx;
		cursor_y = mouse_y - cy;
	}
	
	//The scroll!
	if(mouse_wheel_up()) object_select += 1;
	if(mouse_wheel_down()) object_select -= 1;
	
	//Repeat
	if(object_select < 0) object_select = array_length(object_list) - 1;
	if(object_select > array_length(object_list) - 1) object_select = 0;
	
	//Spawn the object
	if((mouse_check_button_pressed(mb_left) && !keyboard_check(vk_lshift)) || (mouse_check_button_released(mb_left) && keyboard_check(vk_lshift)))
	{
		var spawn_vars = object_list_metadata[object_select]
		if(abs(temp_x_scale) > 0)
		spawn_vars.image_xscale = temp_x_scale;
		if(abs(temp_y_scale) > 0)
		spawn_vars.image_yscale = temp_y_scale;
		var obj = instance_create_layer(cursor_x + cx, cursor_y + cy, "Objects", object_list[object_select],spawn_vars);
		if(object_list[object_select] == obj_capsule)
		{
			obj_level.act_transition = false;	
		}
	}
	
	//Object loop
	for(var i = 0; i < array_length(object_list); i++)
	{
		var mouse_overlap = instance_position(cursor_x + cx, cursor_y + cy, object_list[i])

		if(mouse_overlap && (mouse_check_button_pressed(mb_right)))
		{
			instance_destroy(mouse_overlap);
		}
	}