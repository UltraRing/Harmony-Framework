/// @description Draw debug

	//Camera variables
	var c, cx, cy;
	c = view_camera[view_current];
	cx = camera_get_view_x(c);
	cy = camera_get_view_y(c);
	
	// temp
	draw_set_valign(fa_top);
	
	//Draw hitboxes
	if(show_hitbox && instance_exists(obj_level))
	{
		// Draw objects in the level object
		var obj_size = ds_list_size(obj_level.instance_list);
		draw_set_alpha(0.5);
		for(var i = 0; i < obj_size; ++i) {
			var curr_object = obj_level.instance_list[| i].inst_id;
			if(instance_exists(curr_object)) {
				with(curr_object) {
					// if the instance isn't on screen, why do anything with it?
					if(!instance_origin_on_screen(128,128,x,y)) i++;
					else {
						// Sets the color depending on the plane
						if(variable_instance_exists(self, "plane")) {
							switch(plane) {
								case PLANE.A:
									draw_set_colour(c_red)
								break;
								case PLANE.B:
									draw_set_colour(c_blue)
								break;
								default:
									draw_set_colour(c_white);
								break;
							}
						}
						else draw_set_colour(c_white)
				
						// Draws the rectangle for the object
						draw_rectangle(floor(bbox_left),floor(bbox_top),floor(bbox_right),floor(bbox_bottom),false);
				
						// Draws the point for the middle of the sprite
						draw_sprite(spr_point,0,floor(x),floor(y))
					}
				}
			}
		}
		// draw ALL objects
		var all_instances = instance_number(all);
		for(var i = 0; i < all_instances; ++i) {
			var curr_object = instance_id_get(i);
			if(instance_exists(curr_object)) {
				with(curr_object) {
					// if the instance isn't on screen, why do anything with it?
					if(!instance_origin_on_screen(32,32,x,y) || object_index == obj_player) i++
					else {
						// Sets the color depending on the plane
						if(variable_instance_exists(self, "plane")) {
							switch(plane) {
								case PLANE.A:
									draw_set_colour(c_red)
								break;
								case PLANE.B:
									draw_set_colour(c_blue)
								break;
								default:
									draw_set_colour(c_white);
								break;
							}
						}
						else draw_set_colour(c_white)
				
						// Draws the rectangle for the object
						draw_rectangle(floor(bbox_left),floor(bbox_top),floor(bbox_right),floor(bbox_bottom),true);
						
						draw_set_colour(c_white)
						// Draws the point for the middle of the sprite
						draw_sprite(spr_point,0,floor(x),floor(y))
					}
				}
			}
		}
		
		draw_set_colour(c_white)
		tiles_detected_length = array_length(tiles_detected);
		// Draws the tiles
		for(var i = 0; i < tiles_detected_length; ++i) {
			if(tiles_detected[i][0]*16 > cx+global.window_width && tiles_detected[i][0]*16 < cx && tiles_detected[i][1]*16 > cy+global.window_width && tiles_detected[i][1]*16 < cy) i++;
			draw_set_alpha(0.1)
			draw_rectangle_colour(floor(tiles_detected[i][0]*16),floor(tiles_detected[i][1]*16),floor(tiles_detected[i][0]*16+16),floor(tiles_detected[i][1]*16+16),#FF0000,#AAAA00,#00AAAA,#0000FF,false)
			draw_set_alpha(0.05)
			draw_rectangle_colour(floor(tiles_detected[i][0]*16),floor(tiles_detected[i][1]*16),floor(tiles_detected[i][0]*16+16),floor(tiles_detected[i][1]*16+16),#0000FF,#00AAAA,#AAAA00,#FF0000,true)
			draw_set_alpha(1);
		}
		// Resets the tiles for the next frame
		tiles_detected = [];
		tiles_detected_length = 0;
	}
	
			
	if(show_player && !debug && instance_exists(obj_player))
    {
        draw_set_font(global.font_small);
		
        //Draw hitbox
        draw_set_color(c_red);
        draw_set_alpha(0.7);
        draw_rectangle(floor(obj_player.x)-obj_player.wall_w - obj_player.hitbox_left_offset, floor(obj_player.y)-obj_player.hitbox_h - obj_player.hitbox_top_offset, floor(obj_player.x)+obj_player.wall_w + obj_player.hitbox_right_offset, floor(obj_player.y)+obj_player.hitbox_h + obj_player.hitbox_bottom_offset, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        
		// draw hitbox 
        draw_set_color(c_purple);
        draw_set_alpha(0.7);
        draw_rectangle(floor(obj_player.x)-obj_player.hitbox_w - obj_player.hitbox_left_offset, floor(obj_player.y)-obj_player.hitbox_h - obj_player.hitbox_top_offset, floor(obj_player.x)+obj_player.hitbox_w + obj_player.hitbox_right_offset, floor(obj_player.y)+obj_player.hitbox_h + obj_player.hitbox_bottom_offset, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
		
        //Draw main sensors
        with(obj_player)
        {
			// Draw Lines
            draw_set_color(#ff38ff);
            draw_col_line_wall(-wall_h, -wall_w)
            draw_set_color(#ff5454);
            draw_col_line_wall(-wall_h, wall_w)
			if(y_speed >= 0 || ground) {
	            draw_set_color(#38ffa2);
	            draw_col_line(-hitbox_w+1, hitbox_h);
	            draw_set_color(#00f000);
	            draw_col_line(hitbox_w, hitbox_h);
			}
            draw_set_color(c_white);
            draw_col_line(0, hitbox_h);
			if(y_speed <= 0 && !ground) {
	            draw_set_color(#00aeef);
	            draw_col_line(-hitbox_w+1, -hitbox_h);
	            draw_set_color(#fff238);
	            draw_col_line(hitbox_w, -hitbox_h);
			}
            draw_set_color(c_white);
            
			// Draw Points
            draw_col_point_wall(-wall_h, -wall_w-1)
            draw_col_point_wall(-wall_h, wall_w)
			if(y_speed >= 0 || ground) {
	            draw_col_point(-hitbox_w+1, hitbox_h);
	            draw_col_point(hitbox_w, hitbox_h);
			}
            draw_col_point(0, hitbox_h);
			if(y_speed <= 0 && !ground) {
	            draw_col_point(-hitbox_w+1, -hitbox_h-1);
	            draw_col_point(hitbox_w, -hitbox_h-1);
			}
            draw_sprite(spr_point,0,floor(x)-1,floor(y))
        }
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
	
	// Draw the debug cursor
	if(!debug && show_player) {
		
		draw_state_push();
		draw_set_font(global.font_debug)
		if(instance_near_mouse != noone) {
			var circle_size = 16+2*sin(FRAME_TIMER/8)
			with(instance_near_mouse) {
				draw_circle(x,y,circle_size,true)
				draw_sprite(spr_point,0,x,y);
				for(var i = 0; i < 4; ++i) {
					draw_line(x+(circle_size-2)*dcos(i*90+8*(FRAME_TIMER/4)), y+(circle_size)*dsin(i*90+8*(FRAME_TIMER/4)),x+(circle_size+2)*dcos(i*90+8*(FRAME_TIMER/4)), y+(circle_size+2)*dsin(i*90+8*(FRAME_TIMER/4)))
				}
			}
		}
		if(grabbed_data_anim[2] > 0) {
			grabbed_data_anim[1]--
			if(grabbed_data_anim[2]%8 > 4) {
				draw_set_halign(fa_center);
				draw_text(grabbed_data_anim[0], grabbed_data_anim[1], "GRABBED OBJECT");
				draw_set_halign(fa_left);
			}
		}
		grabbed_data_anim[2] = max(grabbed_data_anim[2]-1, 0)
		
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
	
	//Draw text in rectangle
	draw_set_font(global.font_small);
	draw_set_halign(fa_left);
	draw_text(0, 0, string_upper(window_get_caption()) +" "+ string(GM_version));
	draw_text(0, 8, "BUILD DATE: " + date_date_string(GM_build_date));
	draw_text(0, 16, "BUILD TIME: " + date_time_string(GM_build_date));
	
	//Draw info
	draw_set_halign(fa_right);
	draw_text(global.window_width, 0,"PLAYER: " + string(floor(obj_player.x)) + " " + string(floor(obj_player.y)));
	draw_text(global.window_width, 8,"CAMERA: " + string(floor(obj_camera.camera_x)) + " " + string(floor(obj_camera.camera_y)));
	draw_text(global.window_width, 16,"CANVAS: " + string(room_width) + " " + string(room_height));
	
	draw_set_follow_end();
	
	draw_set_halign(fa_center);
	draw_set_font(global.font_small);
	draw_text(cursor_x + cx, cursor_y - 32 + cy, string_upper(object_get_name(object_list[object_select])+(object_select >= object_list_length_start ? " (METADATA)" : "")));
		
	if(mouse_check_button(mb_left) && keyboard_check(vk_lshift))
	draw_rectangle(mouse_clicked_pos_x,mouse_clicked_pos_y,mouse_x,mouse_y,true);