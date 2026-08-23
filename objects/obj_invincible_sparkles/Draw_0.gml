/// @description Draw
	var array_loop, frames, px, py, table, angle;

	// Draw sparkles
	for (var i = 0; i < 8; ++i) 
	{
		// True angle
		angle = (45 * i) + angle_offset;
		
		// Position sparkles
		px = instance_recorder_get_value(player.recorder, player.rec_vals.xpos, 3 * (i % 4)) + 16 * dsin(angle);
		py = instance_recorder_get_value(player.recorder, player.rec_vals.ypos, 3 * (i % 4)) + 16 * dcos(angle);
		
		// Get the table and frame data
		table = frame_table[i % 4];
		frames = table[FRAME_TIMER mod array_length(table)];
		
		// Offset the frames for the other half
		if(i >= 4)
			frames = table[(FRAME_TIMER + 5) mod array_length(table)];
		
		// Draw sparkles
		draw_sprite(spr_effect_inv_sparkle, frames, floor(px), floor(py));
	}