	if(!has_died)
	{
		var chainAmount = floor((spike_y - spike_y_target) / 16);
	
		for (var i = 0; i < chainAmount + 1; ++i) 
		{
			draw_sprite(spr_aaz2_boss_chain, 0, floor(x), floor((spike_y - 8) - 16 * i));
		}
	
		draw_sprite(spr_aaz2_boss_spike, 0, floor(x), floor(spike_y));
	}
	
	var f = FRAME_TIMER / 6;
	
	// Apply the palette
	effect_set_palette(spr_aaz2_boss_palette, f);
	
	// Draw the whole mobile
	draw_sprite_ext(spr_aaz2_boss_chair, 0, floor(x), floor(y), facing, 1, 0, c_white, 1);
	draw_animator(animator, floor(x) + 10 * facing, floor(y) - 5, facing, 1, 0, c_white, 1);
	
	if((inv_timer > 0 || death_timer > 0) && instance_flash(2) && !has_died)
		effect_set_palette(spr_aaz2_boss_palette_hit, f);
		
	draw_sprite_ext(sprite_index, 0, floor(x), floor(y), facing, 1, 0, c_white, 1);
	shader_reset();