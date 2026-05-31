/// @description Draw water 
    //Camera position
        var cx, cy, sw, sh;
        cx = camera_get_view_x(view_camera[view_current])-64;
        cy = camera_get_view_y(view_camera[view_current])
        sw = global.window_width;
        sh = global.window_height;
	
	//Set x position to the left side of the screen
        if (!is_pool) x = cx;
        
    //Draw basic rectangle with blendmode
        draw_set_color($5b301e);
        gpu_set_blendmode(bm_subtract);
        
        if (!is_pool) //Water Horizon ----------------------------------------------------
        {
            draw_rectangle(cx, max(pos_y+1, cy), cx+sw+64, max(pos_y+1, cy)+sh, false);
        }
        else //Water Pool ----------------------------------------------------------------
        {
            draw_rectangle(bbox_left, pos_y, bbox_right, bbox_bottom, false);
        }
        
        gpu_set_blendmode(bm_normal);
        draw_set_color(c_white);
	
	//IMPORTANT NOTE!!
	//Enable this code if you wanna use shaders for color replacing instead of blend modes
	//You can either use palette_swap or set_color_grading
	
	/*
	//Draw whole ass water
	if(!surface_exists(surf)) surf = surface_create(global.window_width, global.window_height);
	
	//Draw shit in this
	surface_set_target(surf);
	
	//Draw tint surface
	gpu_set_blendenable(false);
	surface_copy(surf, 0, 0, application_surface);
	set_color_grading(yourlut, 17);

	//Done
	surface_reset_target();

	//Draw surface
	draw_surface_part(surf, 0,y-cy,426,cy,cx+64, y);
	shader_reset();
	gpu_set_blendenable(true);
	*/
    
	//Drawing the water
        if (!is_pool) //Water Horizon --------------------------------------------------------------------------
        {
            draw_sprite_ext(spr_water, FRAME_TIMER * anim_speed, 0, pos_y, room_width/spr_width, 1, 0, c_white, 1);
        } 
        else //Water Pool --------------------------------------------------------------------------------------
        {              
            draw_sprite_ext(spr_water, FRAME_TIMER * anim_speed, x, pos_y, sprite_width/spr_width, 1, 0, c_white, 1);
        }
        
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
