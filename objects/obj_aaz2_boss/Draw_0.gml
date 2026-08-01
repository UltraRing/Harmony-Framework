	var chainAmount = floor((spike_y - spike_y_target) / 16);
	
	show_debug_message(chainAmount);
	
	for (var i = 0; i < chainAmount + 1; ++i) 
	{
		draw_sprite(spr_aaz2_boss_chain, 0, floor(x), floor((spike_y - 8) - 16 * i));
	}
	
	draw_sprite(spr_aaz2_boss_spike, 0, floor(x), floor(spike_y));
	draw_self_floor();
	
	var realX = (round((x + 16) / 32) * 32) - 16;
	draw_rectangle(realX - 16, CAMERA_VIEW_Y, realX + 16, CAMERA_VIEW_Y + CAMERA_VIEW_H, true)