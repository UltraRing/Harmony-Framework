    global.pal_surf = surface_create(global.window_width, global.window_height);
	
	//Visual functions
	function aaz2_water_dist_start(){
		if(!instance_exists(obj_water)) exit;
		var c = view_camera[0];
        
	    if (!surface_exists(global.pal_surf)) 
		{
	        global.pal_surf = surface_create(global.window_width, global.window_height);
	    }
        
	    surface_set_target(global.pal_surf);
          
	    camera_apply(c);
	    draw_clear_alpha(c_white, 0);
	}

	function aaz2_water_dist_end(){
		if(!instance_exists(obj_water)) exit;
		
		var c = view_camera[0];
	    var cx = camera_get_view_x(c);
	    var cy = camera_get_view_y(c);
		
	    surface_reset_target();
	    
		//Shader shit
		var distort_data = [1, 1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -2, -2, -3, -3, -3, -3, -2, -2, -1, -1,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        
        with (obj_water) {
            surface_deform(WINDOW_WIDTH,WINDOW_HEIGHT, distort_data, cy + FRAME_TIMER / 3);
            if (!is_pool)
            {
                draw_surface_part(global.pal_surf, -8, pos_y-cy, WINDOW_WIDTH + 32, cy, cx-8, pos_y);
                shader_reset();
                
                draw_surface_part(global.pal_surf, 0, 0, WINDOW_WIDTH + 32, pos_y-cy, cx, cy); 
            }
            else
            {
                draw_surface_part(global.pal_surf, x-8, pos_y, sprite_width, sprite_height, x, pos_y);
                shader_reset();
                
                draw_surface_part(global.pal_surf, x, pos_y, sprite_width, sprite_height, x, pos_y); 
            }
        }
	}
	