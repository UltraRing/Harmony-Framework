/// @description Draw Special End Card

	// Make the HUD follow the camera
	draw_set_follow_camera();

	var cx = global.window_width / 2;

	//White backdrop
	draw_set_color(c_white);
	draw_rectangle(0, 0, global.window_width, global.window_height, false);

	//Draw the end card text
	var hy = 64;
	if (got_all && super_shown)
	{
		//NOW CHARACTER CAN BE SUPER
		draw_sprite(spr_hud_ssclear_got_them_all, 0, cx + heading_off, hy);
		draw_sprite(spr_hud_ssclear_now_character, global.character, cx + super_off, hy - 9);
		draw_sprite(spr_hud_ssclear_character_super, global.character, cx + super_off, hy + 9);
	}
	else if (got_all)
		draw_sprite(spr_hud_ssclear_got_them_all, 0, cx + offset_x[0], hy);
	else if (result == SS_RESULT.GOT_EMERALD)
	{
		//CHARACTER GOT A CHAOS EMERALD
		draw_sprite(spr_hud_actclear_character, global.character, cx + offset_x[0], hy - 9);
		draw_sprite(spr_hud_ssclear_a_chaos_emerald, 0, cx + offset_x[0], hy + 9);
	}
	else
		draw_sprite(spr_hud_ssclear_chaos_emeralds, 0, cx + offset_x[0], hy);

	//Draw collected emeralds
	if (FRAME_TIMER mod 2 == 0)
	{
		var _n  = game_emerald_count();
		var _sp = 24;
		var _sx = cx - (_n - 1) * _sp / 2 + offset_x[1];
		var _k  = 0;
		for (var i = 0; i < array_length(global.emeralds); i++)
		{
			if (!global.emeralds[i]) continue;
			effect_set_palette(tex_pal_ssclear_emeralds, i); //each emerald keeps its own colour row
			draw_sprite(spr_hud_ssclear_emerald, 0, _sx + _k * _sp, 96);
			_k++;
		}
		shader_reset();
	}

	//Draw numbers
	draw_set_font(global.hud_number);

	//Ring bonus
	draw_sprite(spr_hud_actclear_ring_bonus, 0, cx - 98 + offset_x[2], 128);
	draw_set_halign(fa_right);
	draw_text(cx + 82 + offset_x[2], 128, string(ring_bonus));

	//Perfect bonus
	if (perfect)
	{
		draw_sprite(spr_hud_actclear_perfect_bonus, 0, cx - 98 + offset_x[3], 148);
		draw_text(cx + 82 + offset_x[3], 148, string(perfect_bonus));
	}

	//Total score
	draw_sprite(spr_hud_actclear_total_bonus, 0, cx - 98 + offset_x[4], 172);
	draw_text(cx + 82 + offset_x[4], 172, string(global.score));
	draw_set_halign(fa_left);

	draw_set_color(c_white);
	draw_set_follow_end();
