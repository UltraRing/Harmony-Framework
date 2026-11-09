	/// @description Draw the pause

	draw_set_follow_camera();
	
	//Draw background
	draw_set_alpha(background_rect_alpha);
	draw_rectangle(0, 0, CAMERA_VIEW_W, background_rect_y, false);
	draw_set_alpha(1);
	
	// Get the bar size
	var barWidth = sprite_get_width(spr_hud_pause_bar);
	var barHeight = sprite_get_height(spr_hud_pause_bar);
	
	// Draw the black bar below
	draw_set_colour(c_black);
	
	// Just draw the fill
	draw_rectangle(pause_bar_x + barWidth, 0, CAMERA_VIEW_W, CAMERA_VIEW_H, false);
	
	draw_rectangle(0, CAMERA_VIEW_H - 49 + black_bar_y, black_bar_x, CAMERA_VIEW_H - 25 + black_bar_y, false);
	draw_set_colour(c_white);
	
	for (var i = 0; i < CAMERA_VIEW_H / barHeight; ++i) 
		draw_sprite(spr_hud_pause_bar, 0, pause_bar_x, barHeight * i);
	
	draw_set_alpha(pause_alpha);
	
	draw_set_font(global.font_text);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	var optionSize = array_length(options_array);
	
	for (var i = 0; i < optionSize; ++i) 
	{
		if(state != PAUSE_STATE.CONFIRM || state == PAUSE_STATE.CONFIRM && selection != i)
		{
			if(!global.allow_stage_restart && options_array[i] == "RESTART") 
				draw_set_alpha(pause_alpha / 2);
			draw_text(pause_elements_x + 46, 48 * (i + 1) - 5, options_array[i]);
			draw_set_alpha(pause_alpha);
		}
	}
		
	if(state == PAUSE_STATE.UPDATE)
	{
		var sprites_final_x = pause_bar_x + 46;
		if(highlight_x > sprites_final_x)
		{
			var sprites_speed_x = sprites_final_x;
			sprites_speed_x -= highlight_x;
			highlight_x += (sprites_speed_x >> 3);
		}
		else
			highlight_x = sprites_final_x;
	}
		
	// Draw the highlight
	draw_sprite(spr_hud_pause_highlight_option, 0, highlight_x, 48 * (selection + 1));
	
	// Set it early
	if(state >= PAUSE_STATE.CONFIRM)
		draw_set_alpha(1);
		
	// Draw the player
	draw_animator(animator, pause_elements_x + 46, 48 * (selection + 1));
	
	// Draw the pause text
	draw_sprite(spr_hud_pause_text, 0, pause_text_x, CAMERA_VIEW_H - 38 + black_bar_y);
	
	// Fully reset the fade
	draw_set_alpha(1);
	
	if(state == PAUSE_STATE.CONFIRM && instance_flash(3, 0, timer) || state == PAUSE_STATE.TRANSITION_UPDATE)
	{
		draw_text(pause_elements_x + 46, 48 * (selection + 1) - 5, options_array[selection]);
	}
	
	draw_set_follow_end();