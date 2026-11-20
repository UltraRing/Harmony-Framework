// Blue Spheres states, run through script_execute(state) like the player's, and the changes between them

function bss_state_move() //BSS_Setup_State_GlobeMoveZ
{
	globe_hidden = false;
	bss_speedup_update();
	
	var _speed = s3k_bumpers ? _bss_roll_speed_s3k() : _bss_roll_speed();
	if(_speed == undefined) return;
	
	// Turns wait for the next cell edge
	if(on_ground || _bss_turn_held_s3k())
	{
		if(cell_progress > 0 && cell_progress < 256)
		{
			if(hold_left) queued_turn = -1;
			if(hold_right) queued_turn = 1;
		}
	}
	
	cell_progress += _speed;
	if(on_ground)
		bss_touch_cells();
	else if(!_bss_turn_held_s3k())
		queued_turn = 0;
	
	// Touching a cell may have left this state
	if(state == bss_state_move)
	{
		var _can_turn = !_bss_turn_held_s3k();
		var _turn = _can_turn ? queued_turn : 0;
		
		if(_speed > 0)
		{
			// Rolled into the next cell
			if(cell_progress >= 256)
			{
				if(_turn == 0)
					cell_progress -= 256;
				else
				{
					cell_progress = 0;
					bss_start_turn(_turn);
				}
				if(_can_turn) queued_turn = 0;
				bss_advance(1);
			}
		}
		else if(cell_progress < 0)
		{
			// Bounced back into the previous cell
			if(_turn == 0)
			{
				cell_progress += 256;
				bss_advance(-1);
			}
			else
			{
				cell_progress = 0;
				bss_start_turn(_turn);
			}
			if(_can_turn) queued_turn = 0;
		}
	}
	
	roll_frame = (cell_progress >> 4) & 15;
}

// How far the globe rolls this frame: backwards off a bumper until up is held, otherwise speeding up to top speed
function _bss_roll_speed()
{
	if(bumped_back)
	{
		if(!disable_bumpers && hold_up) bumped_back = false;
	}
	else if(move_speed < top_speed)
		move_speed += acceleration;
	return move_speed;
}

// _bss_roll_speed under S3&K bumpers. Their push back rolls against move_speed without changing it.
// Returns undefined on the frame it ends, which skips the rest of the move
function _bss_roll_speed_s3k()
{
	if(bumper_hit)
	{
		// Back on a cell center other than the bumper's, the player rolls away backwards at full speed
		var _ahead = _bss_ahead_is_nearest_s3k();
		var _near_x = _ahead ? bss_ahead_x(1) : player_x;
		var _near_y = _ahead ? bss_ahead_y(1) : player_y;
		if(_bss_on_center_s3k() && (_near_x != bumper_x || _near_y != bumper_y))
		{
			bumper_hit = false;
			move_speed = (move_speed >= 0) ? -top_speed : top_speed;
			return undefined;
		}
		
		// Hit while stopped, it lets go without rolling this frame, and the player rolls back from the next
		if(move_speed == 0)
		{
			bumper_hit = false;
			bumped_back = false;
			move_speed = -top_speed;
			return 0;
		}
		return -move_speed;
	}
	
	// Up resumes running at any time, until then rolling backwards keeps speeding up
	if(hold_up) bumped_back = false;
	if(bumped_back && move_speed < 0)
		move_speed = max(move_speed - acceleration, -top_speed);
	else if(move_speed < top_speed)
		move_speed += acceleration;
	return move_speed;
}

// S3&K holds turns pressed in the air until the first cell edge after landing, Mania drops them
function _bss_turn_held_s3k()
{
	return s3k_controls && !on_ground;
}

function bss_state_turn() //BSS_Setup_State_GlobeTurnLeft / BSS_Setup_State_GlobeTurnRight
{
	bss_speedup_update();
	
	// 16 frames of 4 make a quarter turn
	angle = (angle + turn_dir * 4) & 255;
	
	if(state_timer == 15)
	{
		globe_hidden = false;
		state_timer = 0;
		if(turn_dir < 0) checker_parity ^= 1;
		state = (teleport_wait == 0) ? bss_state_move : bss_state_teleport_out;
	}
	else
	{
		// The pre-rendered turn animation replaces the globe
		globe_hidden = true;
		if(turn_dir > 0 && state_timer == 0) checker_parity ^= 1;
		turn_frame = tables.turn_frames[state_timer];
		turn_flip = (turn_dir < 0) ? tables.turn_flip_left[state_timer] : tables.turn_flip_right[state_timer];
		state_timer++;
		if(teleport_wait > 1) teleport_wait--;
	}
}

function bss_state_teleport_in() //BSS_Setup_State_StartGlobeTeleport
{
	teleport_flash += 8;
	if(teleport_flash != 320) return;
	
	animation_play(animator, BSS_ANIM.STAND);
	
	// Warp to another pink sphere
	if(pink_count > 1)
	{
		var _picks = [];
		for (var gy = 0; gy < board_height; gy++)
		{
			for (var gx = 0; gx < board_width; gx++)
			{
				if(bss_cell_kind(board[gx][gy]) == BSS_CELL.PINK && (gx != player_x || gy != player_y))
					array_push(_picks, [gx, gy]);
			}
		}
		
		if(array_length(_picks) > 0)
		{
			var _pick = _picks[irandom(array_length(_picks) - 1)];
			player_x = _pick[0];
			player_y = _pick[1];
		}
	}
	
	// Face a random open direction, 1 cell away first, then 2
	var _dir = irandom(3);
	var _open = _bss_open_direction(_dir, 1);
	if(_open == -1) _open = _bss_open_direction(_dir, 2);
	if(_open != -1) _dir = _open;
	angle = (_dir << 6) & 255;
	
	bss_add_event(player_x, player_y, bss_event_pink);
	board[player_x][player_y] = BSS_CELL.PINK_STOOD;
	
	teleport_wait = 100;
	state = bss_state_teleport_out;
	fade_change(FADE.IN, 6, FADE_COLOR.WHITE);
}

// First direction (0 up, 1 right, 2 down, 3 left) from _dir, clockwise, that isn't blocked _dist cells away. -1 if none
function _bss_open_direction(_dir, _dist)
{
	static _dir_x = [0, 1, 0, -1];
	static _dir_y = [-1, 0, 1, 0];
	
	repeat(4)
	{
		var _cell = bss_cell_get(player_x + _dir_x[_dir] * _dist, player_y + _dir_y[_dir] * _dist);
		if(!bss_cell_type(_cell).blocks_teleport) return _dir;
		_dir = (_dir + 1) & 3;
	}
	return -1;
}

function bss_state_teleport_out() //BSS_Setup_State_FinishGlobeTeleport
{
	// Once the flash is gone the player can pick a direction
	if(teleport_flash <= 0)
	{
		if(hold_up) teleport_wait = 1;
		else if(hold_left) bss_start_turn(-1);
		else if(hold_right) bss_start_turn(1);
	}
	else
		teleport_flash -= 8;
	
	if(--teleport_wait == 0)
	{
		state = bss_state_move;
		if(on_ground) animation_play(animator, BSS_ANIM.WALK);
	}
}

function bss_state_jettison() //BSS_Setup_State_GlobeJettison
{
	globe_hidden = false;
	cell_progress += move_speed;
	bss_wrap_progress();
	
	// The spheres fly off for 128 frames, then the reward is placed
	if(++state_timer == 128)
	{
		state_timer = 0;
		top_speed = 8;
		move_speed = 8;
		bss_place_reward();
		input_disable = true;
		state = bss_state_reward;
		
		if(reward_is_emerald) global.emeralds[emerald_index] = true;
	}
}

function bss_state_reward() //BSS_Setup_State_GlobeEmerald
{
	cell_progress += move_speed;
	if(++state_timer == 120)
		sound_play(j_chaos_emerald);
	
	bss_touch_cells();
	bss_wrap_progress();
}

function bss_state_exit() //BSS_Setup_State_GlobeExit
{
	top_speed = 0;
	input_disable = true;
	
	// Spin out, showing the turn animation between globe frames
	if(state_timer > 0) angle = (angle - 8) & 255;
	
	if(state_timer & 15)
	{
		globe_hidden = true;
		turn_frame = tables.turn_frames[(state_timer & 15) - 1];
		turn_flip = tables.turn_flip_left[(state_timer & 15) - 1];
	}
	else if(state_timer > 0)
	{
		checker_parity ^= 1;
		globe_hidden = false;
	}
	
	state_timer += 2;
	
	// The clear screen follows an emerald or a red sphere, a medal goes straight back
	var _show_clear = reward_is_emerald || stage_failed;
	fade_change(FADE.OUT, 3, _show_clear ? FADE_COLOR.WHITE : FADE_COLOR.BLACK);
	exit_timer++;
	
	if(exit_timer >= 90 && obj_global.fade.timer == 0)
	{
		if(_show_clear)
		{
			game_special_stage_finish(reward_is_emerald ? SS_RESULT.GOT_EMERALD : SS_RESULT.FAILED, rings_collected, reward_is_emerald && (ring_count <= 0));
			instance_destroy();
		}
		else
			room_goto(global.previous_room);
	}
}

// The stage speeds up every speedup_interval frames
function bss_speedup_update()
{
	if(top_speed < 32 && ++speedup_timer >= speedup_interval)
	{
		speedup_timer = 0;
		top_speed += 4;
	}
}

function bss_start_rolling()
{
	top_speed = 16;
	move_speed = 16;
	acceleration = 2;
	if(on_ground) animation_play(animator, BSS_ANIM.WALK);
}

/// @self								obj_bss_controller
/// @description						Starts a quarter turn
/// @param {Real} _dir					-1 left, 1 right
function bss_start_turn(_dir)
{
	state = bss_state_turn;
	state_timer = 0;
	turn_dir = _dir;
}

/// @self								obj_bss_controller
/// @description						Flashes white and teleports the player to another pink sphere
function bss_start_teleport()
{
	state = bss_state_teleport_in;
	state_timer = 0;
	cell_progress = 0;
	teleport_flash = 0;
	sound_play(sfx_teleport);
	fade_change(FADE.OUT, 6, FADE_COLOR.WHITE);
}

/// @self								obj_bss_controller
/// @description						Takes a collected required cell off sphere_count, flying the board off if it was the last one
/// @returns {Bool}						The stage was cleared
function bss_collect_required()
{
	sphere_count--;
	return bss_check_cleared();
}

/// @self								obj_bss_controller
/// @description						Flies the board off once sphere_count reaches 0
/// @returns {Bool}						The stage was cleared
function bss_check_cleared()
{
	if(sphere_count > 0) return false;
	
	sphere_count = 0;
	state = bss_state_jettison;
	state_timer = 0;
	sound_play(sfx_ss_jettison);
	music_set_fade(FADE.OUT, 1);
	return true;
}

/// @self								obj_bss_controller
/// @description						Spins out of the stage
/// @param {Bool} _failed				Touched a red sphere, rather than reaching the reward
function bss_end_stage(_failed)
{
	state = bss_state_exit;
	state_timer = 0;
	cell_progress = 0;
	sound_play(sfx_ss_exit);
	
	if(_failed)
	{
		stage_failed = true;
		music_set_fade(FADE.OUT, 1);
	}
}

/// @self								obj_bss_controller
/// @description						Places the reward 8 cells ahead on an emptied board
function bss_place_reward() //BSS_Setup_SetupFinishSequence
{
	for (var gx = 0; gx < board_width; gx++)
		for (var gy = 0; gy < board_height; gy++) board[gx][gy] = BSS_CELL.NONE;
	
	var _reward_x = bss_ahead_x(8);
	var _reward_y = bss_ahead_y(8);
	
	// The next Chaos Emerald, or a medal once all of them are collected
	emerald_index = game_emerald_count();
	reward_is_emerald = (emerald_index < array_length(global.emeralds));
	
	if(reward_is_emerald)
		board[_reward_x][_reward_y] = BSS_CELL.EMERALD_CHAOS;
	else
		board[_reward_x][_reward_y] = (ring_count > 0) ? BSS_CELL.MEDAL_SILVER : BSS_CELL.MEDAL_GOLD;
}
