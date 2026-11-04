// Blue Spheres HUD: sphere and ring counters, GET BLUE SPHERES and PERFECT messages

/// @self								obj_bss_controller
/// @description						Fades the stage in, then waits for up (or 180 frames) to start rolling. Runs before the state
function bss_intro_update() //BSS_Message_State_GetBS / BSS_Message_State_GetBSWait
{
	if(intro_phase == 0)
	{
		intro_fade -= 16;
		if(intro_fade <= 0)
		{
			intro_fade = 0;
			intro_phase = 1;
		}
	}
	else if(intro_phase == 1)
	{
		// Up starts early, left and right turn on the spot
		if(top_speed == 0)
		{
			if(hold_up) bss_start_rolling();
			if(cell_progress == 0 && state == bss_state_move)
			{
				if(hold_left) bss_start_turn(-1);
				if(hold_right) bss_start_turn(1);
			}
		}
		
		if(++intro_wait >= 180)
		{
			intro_wait = 0;
			if(top_speed == 0) bss_start_rolling();
			intro_phase = 2;
		}
	}
}

/// @self								obj_bss_controller
/// @description						Slides the messages out. Runs after the state, so PERFECT moves on the frame it appears
function bss_banners_update()
{
	if(intro_phase == 2)
	{
		intro_offset += 16;
		if(intro_offset > 320) intro_phase = 3;
	}
	
	if(perfect_active)
	{
		switch(perfect_phase)
		{
			case 0:
				perfect_offset -= 16;
				if(perfect_offset <= 0)
				{
					perfect_offset = 0;
					perfect_phase = 1;
				}
				break;
			
			case 1:
				if(++perfect_wait >= 180) perfect_phase = 2;
				break;
			
			case 2:
				perfect_offset += 16;
				if(perfect_offset > 320) perfect_active = false;
				break;
		}
	}
}

function bss_show_perfect()
{
	perfect_active = true;
	perfect_phase = 0;
	perfect_offset = 320;
	perfect_wait = 0;
	sound_play(sfx_event);
}

function bss_draw_hud() //BSS_HUD_Draw
{
	draw_set_color(c_white);
	draw_sprite(spr_hud_bss_spheres, 0, center_x - 141, 13);
	draw_sprite(spr_hud_bss_rings, 0, center_x + 64, 13);
	_bss_draw_number(sphere_count, center_x - 88, 17);
	_bss_draw_number(s3k_ring_counter ? rings_collected : ring_count, center_x + 136, 17);
	
	if(intro_phase <= 2)
		_bss_draw_banner(spr_hud_bss_get_blue_spheres, (intro_phase < 2) ? 0 : intro_offset);
	
	if(perfect_active)
		_bss_draw_banner(spr_hud_bss_perfect, perfect_offset);
}

// Three digits, right aligned
function _bss_draw_number(_value, _right_x, _y) //BSS_HUD_DrawNumbers
{
	var _text = string(_value mod 1000);
	_text = string_repeat("0", max(0, 3 - string_length(_text))) + _text;
	draw_set_font(global.bss_number);
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_text(_right_x, _y, _text);
	draw_set_halign(fa_left);
}

// Frame 0 is the left half and frame 1 the right half, each pushed _offset pixels away from the center
function _bss_draw_banner(_sprite, _offset)
{
	var _width = sprite_get_width(_sprite);
	var _height = sprite_get_height(_sprite);
	draw_sprite(_sprite, 0, center_x - _offset - _width, 104 - (_height div 2));
	draw_sprite(_sprite, 1, center_x + _offset, 104 - (_height div 2));
}
