/// @description BSS update

//Keep the special stage view fixed to the window
if (view_camera[0] >= 0) {
	view_enabled = true;
	camera_set_view_size(view_camera[0], WINDOW_WIDTH, WINDOW_HEIGHT);
	camera_set_view_pos(view_camera[0], 0, 0);
}
if (!global.process_objects) exit;

//Input
var kU = input_active && input_hold(INPUT.UP);
var kL = input_active && input_hold(INPUT.LEFT);
var kR = input_active && input_hold(INPUT.RIGHT);
var kJump = input_active && (input_press(INPUT.A) || input_press(INPUT.B) || input_press(INPUT.C));
if (kL && kR) { kL = false; kR = false; }

// BSS_Player_Update
if (on_ground)
{
	if (kJump)
	{
		velocity_y = -1048576; //-TO_FIXED(16)
		on_ground = false;
		animation_play(animator, BSS_ANIM.JUMP);
		roll_timer = 0;
		sound_play(sfx_jump);
	}
}
else
{
	gravity_strength += velocity_y;

	//Gravity scales with the stage speed
	var sp = (speedup_level == 0) ? 16 : speedup_level;
	velocity_y += sp << 12;
	if (gravity_strength >= 0)
	{
		gravity_strength = 0;
		on_ground = true;
		if (animation_get_current_animation(animator) == BSS_ANIM.SPRING) globe_speed = (globe_speed >> 1);
		globe_speed_inc = 2;
		animation_play(animator, (speedup_level != 0) ? BSS_ANIM.WALK : BSS_ANIM.STAND);
	}
}

//Drive the current animation
var cur_anim = animation_get_current_animation(animator);
if (cur_anim == BSS_ANIM.WALK)
{
	walk_timer += abs(globe_speed);
	if (walk_timer > 31)
	{
		walk_timer &= 31;
		var wn = animation_get_frame_count(animator);
		var wf = animation_get_frame(animator);
		if (globe_speed <= 0) {
			if (--wf < 0) wf = wn - 1;
		}
		else {
			if (++wf > wn - 1) wf = 0;
		}
		animation_set_frame(animator, wf);
	}
}
else if (cur_anim >= BSS_ANIM.JUMP)
{
	roll_timer += max(abs(speedup_level) / 2, 16);
	if (roll_timer >= 16)
	{
		roll_timer -= 16;
		var rn = animation_get_frame_count(animator);
		animation_set_frame(animator, (animation_get_frame(animator) + 1) mod rn);
	}
}

//Tails' tail
if (has_tail)
{
	animation_set_speed(tail_animator, (abs(speedup_level) + 30) / 192);
	animator_update(tail_animator);
}

// BSS_Message GETSPHERES
if (msg_phase == 0)
{
	msg_fade_timer -= 16;
	if (msg_fade_timer <= 0) { msg_fade_timer = 0; msg_phase = 1; }
}
else if (msg_phase == 1)
{
	if (speedup_level == 0)
	{
		if (kU)
		{
			speedup_level   = 16;
			globe_speed     = 16;
			globe_speed_inc = 2;
			if (on_ground) animation_play(animator, BSS_ANIM.WALK);
		}
		if (globe_timer == 0 && state == BSS_STATE.MOVE)
		{
			if (kL) { state = BSS_STATE.TURNL; spin_timer = 0; }
			if (kR) { state = BSS_STATE.TURNR; spin_timer = 0; }
		}
	}

	//Timer, then start the movement!
	if (++msg_wait_timer >= 180)
	{
		msg_wait_timer = 0;
		if (speedup_level == 0)
		{
			speedup_level   = 16;
			globe_speed     = 16;
			globe_speed_inc = 2;
			if (on_ground) animation_play(animator, BSS_ANIM.WALK);
		}
		msg_phase = 2;
	}
}

// BSS_Setup state machine
switch (state)
{
	case BSS_STATE.MOVE: //BSS_Setup_State_GlobeMoveZ
		globe_hidden = false;

		//Stage speeds up every 30 seconds
		if (speedup_level < 32 && ++speedup_timer >= speedup_interval)
		{
			speedup_timer = 0;
			speedup_level += 4;
		}

		if (player_was_bumped) {
			if (!disable_bumpers && kU) player_was_bumped = false;
		}
		else if (globe_speed < speedup_level) {
			globe_speed += globe_speed_inc;
		}

		if (on_ground)
		{
			if (globe_timer > 0 && globe_timer < 256)
			{
				//Queue a turn for the next cell edge
				if (kL) spin_state = 1;
				if (kR) spin_state = 2;
			}
			globe_timer += globe_speed;
			bss_stepped_objects(); //may change state
		}
		else
		{
			globe_timer += globe_speed;
			spin_state = 0;
		}

		if (state == BSS_STATE.MOVE)
		{
			if (globe_speed > 0)
			{
				//Crossed into the next cell
				if (globe_timer >= 256)
				{
					switch (spin_state)
					{
						case 0: globe_timer -= 256; break;
						case 1: state = BSS_STATE.TURNL; globe_timer = 0; spin_timer = 0; break;
						case 2: state = BSS_STATE.TURNR; globe_timer = 0; spin_timer = 0; break;
					}
					palette_page ^= 1;
					spin_state = 0;
					player_x = bss_wrap_x(player_x + (sin256(angle) >> 8));
					player_y = bss_wrap_y(player_y - (cos256(angle) >> 8));
				}
			}
			//Bounced back into the previous cell
			else if (globe_timer < 0)
			{
				switch (spin_state)
				{
					case 0:
						globe_timer += 256;
						palette_page ^= 1;
						player_x = bss_wrap_x(player_x - (sin256(angle) >> 8));
						player_y = bss_wrap_y(player_y + (cos256(angle) >> 8));
						break;
					case 1: state = BSS_STATE.TURNL; globe_timer = 0; spin_timer = 0; break;
					case 2: state = BSS_STATE.TURNR; globe_timer = 0; spin_timer = 0; break;
				}
				spin_state = 0;
			}
		}

		palette_line = (globe_timer >> 4) & 15; //roll frame from the sub-cell position
		break;

	case BSS_STATE.TURNL: //BSS_Setup_State_GlobeTurnLeft
		if (speedup_level < 32 && ++speedup_timer >= speedup_interval)
		{
			speedup_timer = 0;
			speedup_level += 4;
		}
		angle = (angle - 4) & 255; //16 frames of 4 = a quarter turn

		if (spin_timer == 15)
		{
			globe_hidden = false;
			spin_timer = 0;
			palette_page ^= 1;
			state = (timer_100 == 0) ? BSS_STATE.MOVE : BSS_STATE.TELE_OUT;
		}
		else
		{
			globe_hidden = true;
			turn_frame = global.bss.globeFrameTable[spin_timer];
			turn_flip  = global.bss.globeDirTableL[spin_timer];
			spin_timer++;
			if (timer_100 > 1) timer_100--;
		}
		break;

	case BSS_STATE.TURNR: //BSS_Setup_State_GlobeTurnRight
		if (speedup_level < 32 && ++speedup_timer >= speedup_interval)
		{
			speedup_timer = 0;
			speedup_level += 4;
		}
		angle = (angle + 4) & 255;

		if (spin_timer == 15)
		{
			globe_hidden = false;
			spin_timer = 0;
			state = (timer_100 == 0) ? BSS_STATE.MOVE : BSS_STATE.TELE_OUT;
		}
		else
		{
			globe_hidden = true;
			if (spin_timer == 0) palette_page ^= 1;
			turn_frame = global.bss.globeFrameTable[spin_timer];
			turn_flip  = global.bss.globeDirTableR[spin_timer];
			spin_timer++;
			if (timer_100 > 1) timer_100--;
		}
		break;

	case BSS_STATE.TELE_IN: //BSS_Setup_State_StartGlobeTeleport
		tele_timer += 8;
		if (tele_timer == 320)
		{
			animation_play(animator, BSS_ANIM.STAND);

			//pick another pink sphere
			if (pink_count > 1)
			{
				var picks = [];
				for (var gy = 0; gy < BSS_H; gy++)
				{
					for (var gx = 0; gx < BSS_W; gx++)
					{
						if ((global.bss.pf[gy + (BSS_H * gx)] & 0x7F) == BSS_CELL.PINK && (gx != player_x || gy != player_y))
							array_push(picks, [gx, gy]);
					}
				}
				if (array_length(picks) > 0)
				{
					var pk = picks[irandom(array_length(picks) - 1)];
					player_x = pk[0];
					player_y = pk[1];
				}
			}

			//pick a valid exit direction, distance 1 then distance 2
			var dir = irandom(3);
			var found_dir = false;
			for (var i = 0; i < 4; i++)
			{
				var tx = player_x;
				var ty = player_y;
				switch (dir) {
					case 0: ty = bss_wrap_y(ty - 1); break;
					case 1: tx = bss_wrap_x(tx + 1); break;
					case 2: ty = bss_wrap_y(ty + 1); break;
					case 3: tx = bss_wrap_x(tx - 1); break;
				}
				var tile = global.bss.pf[ty + (BSS_H * tx)];
				if (tile < BSS_CELL.RED || (tile > BSS_CELL.BUMPER && tile != BSS_CELL.PINK)) { found_dir = true; break; }
				dir = (dir + 1) & 3;
			}
			if (!found_dir)
			{
				for (var i = 0; i < 4; i++)
				{
					var tx = player_x;
					var ty = player_y;
					switch (dir) {
						case 0: ty = bss_wrap_y(ty - 2); break;
						case 1: tx = bss_wrap_x(tx + 2); break;
						case 2: ty = bss_wrap_y(ty + 2); break;
						case 3: tx = bss_wrap_x(tx - 2); break;
					}
					var tile = global.bss.pf[ty + (BSS_H * tx)];
					if (tile < BSS_CELL.RED || (tile > BSS_CELL.BUMPER && tile != BSS_CELL.PINK)) { found_dir = true; break; }
					dir = (dir + 1) & 3;
				}
			}

			angle = (dir << 6) & 255;

			array_push(collected, { ce : BSS_COLLECT.PINK, cx : player_x, cy : player_y, t : 0 });
			global.bss.pf[player_y + (BSS_H * player_x)] = BSS_CELL.PINK_STOOD;

			timer_100 = 100;
			state = BSS_STATE.TELE_OUT;
			fade_change(FADE.IN, 6, FADE_COLOR.WHITE); //fade the white flash back out
		}
		break;

	case BSS_STATE.TELE_OUT: //BSS_Setup_State_FinishGlobeTeleport
		if (tele_timer <= 0)
		{
			if (kU) timer_100 = 1;
			else if (kL) { state = BSS_STATE.TURNL; spin_timer = 0; }
			else if (kR) { state = BSS_STATE.TURNR; spin_timer = 0; }
		}
		else {
			tele_timer -= 8;
		}

		timer_100--;
		if (timer_100 == 0)
		{
			state = BSS_STATE.MOVE;
			if (on_ground) animation_play(animator, BSS_ANIM.WALK);
		}
		break;

	case BSS_STATE.JETTISON: //BSS_Setup_State_GlobeJettison
		globe_hidden = false;
		globe_timer += globe_speed;
		if (globe_speed <= 0 && globe_timer < 0)
		{
			palette_page ^= 1;
			globe_timer += 256;
			player_x = bss_wrap_x(player_x - (sin256(angle) >> 8));
			player_y = bss_wrap_y(player_y + (cos256(angle) >> 8));
		}
		else if (globe_timer >= 256)
		{
			palette_page ^= 1;
			globe_timer -= 256;
			player_x = bss_wrap_x(player_x + (sin256(angle) >> 8));
			player_y = bss_wrap_y(player_y - (cos256(angle) >> 8));
		}
		palette_line = (globe_timer >> 4) & 15; //roll frame from the sub-cell position

		//Board flies off for 128 frames, then the reward is placed
		if (++spin_timer == 128)
		{
			spin_timer = 0;
			speedup_level = 8;
			globe_speed = 8;
			bss_setup_finish();
			input_active = false;
			state = BSS_STATE.EMERALD;
			
			//Award the Chaos Emerald!
			if (reward_is_emerald) global.emeralds[emerald_index] = true;
		}
		break;

	case BSS_STATE.EMERALD: //BSS_Setup_State_GlobeEmerald
		globe_timer += globe_speed;
		spin_timer++;
		if (spin_timer == 120)
			sound_play(reward_is_emerald ? j_chaos_emerald : sfx_shard_collect);
		bss_stepped_objects();

		if (globe_speed <= 0 && globe_timer < 0)
		{
			palette_page ^= 1;
			globe_timer += 256;
			player_x = bss_wrap_x(player_x - (sin256(angle) >> 8));
			player_y = bss_wrap_y(player_y + (cos256(angle) >> 8));
		}
		else if (globe_timer >= 256)
		{
			palette_page ^= 1;
			globe_timer -= 256;
			player_x = bss_wrap_x(player_x + (sin256(angle) >> 8));
			player_y = bss_wrap_y(player_y - (cos256(angle) >> 8));
		}
		palette_line = (globe_timer >> 4) & 15; //roll frame from the sub-cell position
		break;

	case BSS_STATE.EXIT: //BSS_Setup_State_GlobeExit
		speedup_level = 0;
		input_active = false;

		if (spin_timer > 0) angle = (angle - 8) & 255;

		if (spin_timer & 15)
		{
			globe_hidden = true;
			var tt = spin_timer & 15;
			turn_frame = global.bss.globeFrameTable[tt - 1];
			turn_flip  = global.bss.globeDirTableL[tt - 1];
		}
		else if (spin_timer > 0)
		{
			palette_page ^= 1;
			globe_hidden = false;
		}

		spin_timer += 2;

		//The clear plays after an emerald or a red-sphere bail-out. A medal just leaves
		var _show_clear = reward_is_emerald || stage_failed;

		//Fade out while spinning
		fade_change(FADE.OUT, 3, _show_clear ? FADE_COLOR.WHITE : FADE_COLOR.BLACK);
		exit_timer++;

		if (exit_timer >= 90 && obj_global.fade.timer == 0)
		{
			if (_show_clear)
			{
				//Create special stage clear object
				var _clear = instance_create_depth(0, 0, 0, obj_special_stage_clear);
				
				//Result status
				_clear.result = reward_is_emerald ? SS_RESULT.GOT_EMERALD : SS_RESULT.FAILED;
				
				//Ring bonus
				_clear.rings = rings_collected;
				
				//Perfect bonus
				_clear.perfect = reward_is_emerald && (ring_count <= 0);
				
				//Bye!
				instance_destroy();
			}
			else
			{
				room_goto(global.previous_room);
			}
		}
		break;
}

// BSS_Collected updates
bss_update_collected();

//Uncomment this for Mania's ring animation!
/*
ring_spin += 0.25;
if (ring_spin >= sprite_get_number(spr_bss_ring_mania)) ring_spin -= sprite_get_number(spr_bss_ring_mania);
*/

// S3&K ring animation
if (++ring_spin_timer >= 8)
{
	ring_spin_timer = 0;
	global.bss.ring_phase = (global.bss.ring_phase + 1) mod 3;
}
if (++spark_spin_timer >= 5)
{
	spark_spin_timer = 0;
	global.bss.spark_phase = (global.bss.spark_phase + 1) mod 4;
}

//medal spinning
medal_spin += 0.5;
if (medal_spin >= sprite_get_number(spr_bss_medal_gold)) medal_spin -= sprite_get_number(spr_bss_medal_gold);

//background scroll
if (state == BSS_STATE.MOVE || state == BSS_STATE.JETTISON || state == BSS_STATE.EMERALD)
	bg_scroll_y -= globe_speed / 4;
if (state == BSS_STATE.EXIT) bg_scroll_x -= 32;
else bg_scroll_x = (angle & 255) * 4;

//GET BLUE SPHERES message scolling
if (msg_phase == 2)
{
	intro_offset += 16;
	if (intro_offset > 320) msg_phase = 3;
}

//PERFECT message
if (perfect_active)
{
	switch (perfect_phase)
	{
		case 0: perfect_offset -= 16; if (perfect_offset <= 0) { perfect_offset = 0; perfect_phase = 1; } break;
		case 1: if (++perfect_wait >= 180) perfect_phase = 2; break;
		case 2: perfect_offset += 16; if (perfect_offset > 320) perfect_active = false; break;
	}
}

//music speeds up 1.05x per speedup interval
music_set_pitch(BGM, power(1.05, (max(speedup_level, 16) - 16) / 4));
