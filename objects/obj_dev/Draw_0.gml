/// @description Draw debug

	//Camera variables
	var c, cx, cy;
	c = view_camera[view_current];
	cx = camera_get_view_x(c);
	cy = camera_get_view_y(c);
	
	// temp
	draw_set_valign(fa_top);
	
	//Draw hitboxes
	if(show_hitbox)
	{
		// TODO
	}
	
			
	if(show_player && !debug && instance_exists(obj_player))
	{
		// TODO:
	}
	
	if(show_fps)
	{
		// Make the HUD follow the camera
		draw_set_follow_camera();
		
		//Draw text in rectangle
		draw_set_font(global.font_small);
		draw_set_halign(fa_left);
		draw_text(0, global.window_height-8, "FPS: " + string(fps) + " " + "TRUE FPS:" +string(store_truefps));
		draw_text(0, global.window_height-16, "INSTANCES: " + string(instance_count));
		
		// Stop following
		draw_set_follow_end();
	}
	
	if(instance_exists(obj_level) && show_culling)
	{
		var inst;
		var count = ds_list_size(obj_level.instance_list);
		
		draw_state_push();
		
		draw_set_alpha(0.5);
		for (var i = 0; i < count; ++i)
		{
			// Get the object from the list
			inst = obj_level.instance_list[| i];
			
			if(!instance_exists(inst.inst_id))
				continue;
				
			if(inst.flag & CULL_FLAG.CHECK_ENTITY_POS)
				draw_rectangle_color(floor(inst.inst_id.x + inst.region.left), floor(inst.inst_id.y + inst.region.top), floor(inst.inst_id.x + inst.region.right), floor(inst.inst_id.y + inst.region.bottom), c_maroon, c_maroon, c_maroon, c_maroon, false)
			
			if(inst.flag & CULL_FLAG.CHECK_ENTITY_START)
				draw_rectangle_color(floor(inst.inst_id.xstart + inst.region.left), floor(inst.inst_id.ystart + inst.region.top), floor(inst.inst_id.xstart + inst.region.right), floor(inst.inst_id.ystart + inst.region.bottom), c_teal, c_teal, c_teal, c_teal, false)
		}
		
		draw_state_pop();
	}
	
	//Disable not in debug mode
	if(!debug || !instance_exists(obj_player)) exit;
	
	draw_set_alpha(0.75);
	var sprite = object_get_sprite(object_list[object_select]);
	draw_sprite(sprite, 0, cursor_x + cx, cursor_y + cy);
	draw_set_alpha(1);
	
	// Make the HUD follow the camera
	draw_set_follow_camera();
	
	//Draw info
	draw_set_font(global.font_small);
	draw_set_halign(fa_right);
	draw_text(global.window_width, 0,"PLAYER: " + string(floor(obj_player.x)) + " " + string(floor(obj_player.y)));
	draw_text(global.window_width, 8,"CAMERA: " + string(floor(obj_camera.camera_x)) + " " + string(floor(obj_camera.camera_y)));
	draw_text(global.window_width, 16,"CANVAS: " + string(room_width) + " " + string(room_height));
	
	draw_set_follow_end();
	
	draw_set_halign(fa_center);
	draw_set_font(global.font_small);
	draw_text(cursor_x + cx, cursor_y - 32 + cy, string_upper(object_get_name(object_list[object_select])));