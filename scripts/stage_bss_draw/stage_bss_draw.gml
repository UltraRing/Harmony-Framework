// Blue Spheres rendering: the globe, the board projected onto it, and the player

/// @self								obj_bss_controller
/// @description						Advances the ring, sparkle and medal animations and scrolls the background
function bss_props_update()
{
	// S3&K ring and sparkle cycles
	if(++ring_phase_timer >= 8)
	{
		ring_phase_timer = 0;
		ring_phase = (ring_phase + 1) mod 3;
	}
	if(++spark_phase_timer >= 5)
	{
		spark_phase_timer = 0;
		spark_phase = (spark_phase + 1) mod 4;
	}
	
	if(mania_rings)
	{
		ring_spin += 0.25;
		if(ring_spin >= sprite_get_number(spr_bss_ring_mania)) ring_spin -= sprite_get_number(spr_bss_ring_mania);
	}
	
	medal_spin += 0.5;
	if(medal_spin >= sprite_get_number(spr_bss_medal_gold)) medal_spin -= sprite_get_number(spr_bss_medal_gold);
	
	// S3&K bumpers push the player back against move_speed
	if(state == bss_state_move || state == bss_state_jettison || state == bss_state_reward)
		bg_scroll_y -= (bumper_hit ? -move_speed : move_speed) / 4;
	
	if(state == bss_state_exit)
		bg_scroll_x -= 32;
	else
		bg_scroll_x = (angle & 255) * 4;
}

function bss_draw_globe()
{
	// Recolored to the stage's tex_pal_bss row
	effect_set_palette(tex_pal_bss, palette_index);
	
	var _bg_w = sprite_get_width(spr_bss_bg);
	var _bg_h = sprite_get_height(spr_bss_bg);
	draw_sprite_tiled_ext(spr_bss_bg, 0, -(bg_scroll_x mod _bg_w), (bg_scroll_y mod _bg_h) - _bg_h, 1, 1, c_white, 1);
	
	if(globe_hidden)
	{
		// Turn sprite set a or b keeps the checkerboard colors matching the parity
		var _turn_sprite = (checker_parity & 1) ? spr_bss_globe_turn_b : spr_bss_globe_turn_a;
		draw_sprite_ext(_turn_sprite, turn_frame, center_x, BSS_GLOBE_Y, turn_flip ? -1 : 1, 1, 0, c_white, 1);
	}
	else
		draw_sprite(spr_bss_globe_roll, ((checker_parity & 1) * 16 + roll_frame) mod 32, center_x, BSS_GLOBE_Y);
	
	shader_reset();
	
	if(horizon_glow)
	{
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(spr_bss_horizon, 0, center_x, BSS_GLOBE_Y, 1, 1, 0, c_white, 0.5);
		draw_sprite_ext(spr_bss_rimlight, 0, center_x, BSS_GLOBE_Y, 1, 1, 0, c_white, 0.5);
		gpu_set_blendmode(bm_normal);
	}
	
	draw_sprite_ext(spr_bss_player_shadow, 0, center_x, BSS_PLAYER_Y, 1, 1, 0, c_white, 1);
}

/// @self								obj_bss_controller
/// @description						Projects every visible cell onto the globe, far to near
function bss_draw_board() //BSS_Setup_HandleCollectableMovement
{
	var _angle = angle & 255;
	var _cos = cos256(_angle);
	var _sin = sin256(_angle);
	var _quadrant = (_angle >> 6) & 3;
	
	var _turning = ((_angle & 0x3F) != 0);
	var _view_x = _turning ? tables.view_turning_x : tables.view_straight_x;
	var _view_y = _turning ? tables.view_turning_y : tables.view_straight_y;
	
	for (var i = 0; i < array_length(_view_x); i++)
	{
		// Turn the view offset to the facing quadrant
		var _ox, _oy;
		switch(_quadrant)
		{
			case 0: _ox = _view_x[i]; _oy = _view_y[i]; break;
			case 1: _ox = -_view_y[i]; _oy = _view_x[i]; break;
			case 2: _ox = _view_x[i]; _oy = -_view_y[i]; break;
			case 3: _ox = _view_y[i]; _oy = _view_x[i]; break;
		}
		
		var _cell = bss_cell_get(player_x + _ox, player_y + _oy);
		if(_cell == BSS_CELL.NONE) continue;
		
		// Rotate into view space, then find the depth row (0 = nearest, scrolled by the roll)
		var _side = (_ox * _cos + _oy * _sin) >> 4;
		var _row = -(((_oy * _cos - _ox * _sin) >> 4) + roll_frame - 16);
		if(_row < 0 || _row >= 112) continue;
		
		// Smaller further away and toward the screen edges
		var _scale = max(tables.row_scale[_row] - (abs(_side) >> 5), 0);
		
		// Spread sideways, bending down with the globe's curve
		var _spread = tables.row_spread[_row] * _side;
		var _bend = (_spread * _spread) div 65536;
		var _offset = ((_spread <= 0) ? _spread + _bend : _spread - _bend) >> 4;
		var _draw_x = center_x + _offset;
		var _draw_y = tables.row_y[_row] + (_offset * _offset) div tables.row_curve[_row];
		
		// The spheres fly away during the jettison
		if(state == bss_state_jettison) //BSS_Setup_LaunchSpheres
		{
			_draw_x = (((256 + state_timer) * (_draw_x - center_x)) >> 8) + center_x;
			_draw_y -= state_timer * 2;
		}
		
		var _type = bss_cell_type(_cell);
		var _draw = _type.draw;
		if(_draw != undefined) _draw(_type, _draw_x, _draw_y, _scale);
	}
}

// Cell drawers, see stage_bss_cells. _scale goes from 0 (far) to 31 (near), sphere sprites hold one frame per two steps

// Default: the type's sprite, lifted to sit on the globe's surface
function bss_draw_sphere(_type, _x, _y, _scale) //BSS_Collectable_Draw
{
	if(_type.sprite == undefined) return;
	
	var _frame = _scale div 2;
	var _sphere_y = _y - tables.sphere_lift[_frame];
	if(_type.alpha == 1)
		draw_sprite(_type.sprite, _frame, _x, _sphere_y);
	else
		draw_sprite_ext(_type.sprite, _frame, _x, _sphere_y, 1, 1, 0, c_white, _type.alpha);
}

function bss_draw_ring(_type, _x, _y, _scale)
{
	if(mania_rings)
	{
		var _spin = floor(ring_spin) mod sprite_get_number(spr_bss_ring_mania);
		draw_sprite_ext(spr_bss_ring_mania, _spin, _x, _y - (tables.ring_screen_y[_scale] / 65536), tables.ring_scale_x[_scale] / 512, tables.ring_scale_y[_scale] / 512, 0, c_white, 1);
	}
	else
		draw_sprite(spr_bss_ring, ring_phase * 16 + (_scale div 2), _x, _y);
}

function bss_draw_sparkle(_type, _x, _y, _scale)
{
	draw_sprite(spr_bss_ring_sparkle, spark_phase, _x, _y);
}

function bss_draw_medal(_type, _x, _y, _scale)
{
	var _medal_scale = tables.medal_scale[_scale] / 512;
	draw_sprite_ext(_type.sprite, floor(medal_spin) mod sprite_get_number(_type.sprite), _x, _y - (tables.ring_screen_y[_scale] / 65536), _medal_scale, _medal_scale, 0, c_white, 1);
}

// Recolored to the emerald being awarded
function bss_draw_emerald(_type, _x, _y, _scale)
{
	effect_set_palette(tex_pal_bss_chaos_emeralds, emerald_index);
	draw_sprite(_type.sprite, _scale div 2, _x, _y);
	shader_reset();
}

function bss_draw_player() //BSS_Player_Draw
{
	var _y = BSS_PLAYER_Y + ((jump_y >> 1) - (jump_y >> 4)) / 65536;
	draw_animator(animator, center_x, _y, 1, 1, 0, c_white, 1);
	if(has_tail) draw_animator(tail_animator, center_x, _y, 1, 1, 0, c_white, 1);
}
