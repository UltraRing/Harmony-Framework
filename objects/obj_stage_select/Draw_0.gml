	
	effect_surface_deform(WINDOW_WIDTH, WINDOW_HEIGHT, deform_data, FRAME_TIMER, 1)
	
	//Draw zaza background
	draw_sprite(spr_levsel_bg, image_index, 0, 0);
	
	//no more zaza
	shader_reset();
	
	
	//Set the font to use
	draw_set_font(global.text_random);
	
	//Wave text!
		var DevText = string_upper(quotes[quote_index]);
		for(var i = 0; i < string_length(DevText); i++)
		{
			var size;
			size = string_width(string_copy(DevText, 0, i));
			draw_text(floor(((global.window_width/2)-string_width(DevText)/2)+size), floor((global.window_height/2)-96+(8*dsin((current_time/3)+24*i))), string_char_at(DevText , i+1));
		}
			
	//Change the text alingment
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	//Get zone array size
	var zone_arr = array_length(zone_list);
	
	//Draw list
	for(var i = 0; i < zone_arr; ++i) {
		//Do the selection
		if(i == zone_sel)
		{
			effect_set_palette(tex_pal_textselect1, 1);
		}
		var i_offset = i-(zone_sel-min(zone_sel, 8))
		//Draw zones
		if(i_offset >= 0 && i_offset <= 8) {
	    draw_text((global.window_width / 2)-128, ((global.window_height/2) - 64)+14*i_offset, zone_list[i][0]);
		
		//Draw act text
		draw_text((global.window_width / 2)+64-16, ((global.window_height/2) - 64)+14*i_offset, "ACT:");
		}
		//Draw acts
		for(var j = 0; j < array_length( zone_list[i]) - 1; ++j) {
			var act_x_offset = (act_sel-min(act_sel, 8));
			var j_offset = j-act_x_offset
			//Do the selection
			if(i == zone_sel && j_offset == act_sel)
			{
				effect_set_palette(tex_pal_textselect1, 1);
			}else
			{
				shader_reset();
			}
			if(j_offset >= 0 && i_offset >= 0 && i_offset <= 8)
			draw_text((global.window_width / 2)+96+ (12*j_offset)-16-(act_x_offset*8) , ((global.window_height/2) - 64)+14*i_offset, string(j_offset+1));
			shader_reset();
		}
	}
	
	//Draw sound test
	if(zone_sel == zone_arr) effect_set_palette(tex_pal_textselect1, 1);
	draw_text((global.window_width / 2)-128, (global.window_height/2) + 64+24, "SOUND TEST: ");
	draw_text((global.window_width / 2)+ 96-16, (global.window_height/2) +64+24, (sound_sel > 9 ? "" : "0") + string(sound_sel));
	shader_reset();