// Blue Spheres player: character, input, jumping and animation. The player never moves on screen, the globe does

/// @self								obj_bss_controller
/// @description						Builds the player and tail animators for the current character, see bss_config_characters
function bss_setup_character()
{
	character = global.character;
	var _characters = bss_config_characters();
	var _character = _characters[(global.character < array_length(_characters)) ? global.character : CHAR_SONIC];
	
	// Keep the current pose when rebuilding over an existing animator
	var _rebuild = (animator != undefined);
	var _animation = _rebuild ? animation_get_current_animation(animator) : BSS_ANIM.STAND;
	var _frame = _rebuild ? animation_get_frame(animator) : 0;
	if(_animation < 0) _animation = BSS_ANIM.STAND;
	
	animator = new animator_create();
	animation_add(BSS_ANIM.STAND,  _character.stand, 0, 0, false);
	animation_add(BSS_ANIM.WALK,   _character.walk,  0, 0, true);
	animation_add(BSS_ANIM.JUMP,   _character.roll,  0, 0, true);
	animation_add(BSS_ANIM.SPRING, _character.roll,  0, 0, true);
	animation_play(animator, _animation);
	animation_set_frame(animator, _frame);
	
	has_tail = (_character.tail != noone);
	if(has_tail)
	{
		animation_add(BSS_ANIM.TAIL, _character.tail, 0, 0, true);
		tail_animator = new animator_create();
		animation_play(tail_animator, BSS_ANIM.TAIL);
	}
}

function bss_get_input() //BSS_Player_Input_P1
{
	hold_up = !input_disable && input_hold(INPUT.UP);
	hold_left = !input_disable && input_hold(INPUT.LEFT);
	hold_right = !input_disable && input_hold(INPUT.RIGHT);
	press_action = !input_disable && (input_press(INPUT.A) || input_press(INPUT.B) || input_press(INPUT.C));
	
	if(hold_left && hold_right)
	{
		hold_left = false;
		hold_right = false;
	}
}

/// @self								obj_bss_controller
/// @description						Jumping, gravity and landing. Runs before the state in Mania, after it in S3&K (s3k_controls)
function bss_player_jump() //BSS_Player_Update
{
	if(on_ground)
	{
		var _jump = s3k_controls ? _bss_jump_ready_s3k() : press_action;
		if(!_jump) return;
		
		jump_speed = BSS_JUMP_SPEED;
		on_ground = false;
		animation_play(animator, BSS_ANIM.JUMP);
		roll_timer = 0;
		sound_play(sfx_jump);
		
		// S3&K drops a queued turn when jumping, and starts falling on the same frame
		if(!s3k_controls) return;
		queued_turn = 0;
	}
	
	// Gravity scales with the stage speed
	jump_y += jump_speed;
	jump_speed += ((top_speed == 0) ? 16 : top_speed) << 12;
	
	// Landed
	if(jump_y >= 0)
	{
		jump_y = 0;
		on_ground = true;
		if(animation_get_current_animation(animator) == BSS_ANIM.SPRING) move_speed = move_speed >> 1;
		acceleration = 2;
		animation_play(animator, (top_speed != 0) ? BSS_ANIM.WALK : BSS_ANIM.STAND);
	}
}

// S3&K holds a jump pressed mid-turn until the turn ends, and doesn't jump once every sphere is collected
function _bss_jump_ready_s3k()
{
	if(press_action && sphere_count > 0) jump_queued = true;
	if(!jump_queued || (angle & 0x3F) != 0) return false;
	
	jump_queued = false;
	return true;
}

function bss_player_animate()
{
	// Walking steps a frame every 32 units rolled, backwards when the globe rolls back
	var _animation = animation_get_current_animation(animator);
	if(_animation == BSS_ANIM.WALK)
	{
		walk_timer += abs(move_speed);
		if(walk_timer > 31)
		{
			walk_timer &= 31;
			var _frames = animation_get_frame_count(animator);
			var _frame = animation_get_frame(animator);
			if(move_speed <= 0)
			{
				if(--_frame < 0) _frame = _frames - 1;
			}
			else if(++_frame > _frames - 1) _frame = 0;
			animation_set_frame(animator, _frame);
		}
	}
	else if(_animation == BSS_ANIM.JUMP || _animation == BSS_ANIM.SPRING)
	{
		// A frame every 32 units at the stage's top speed, so a new pose every 4 frames at the start and every 2 at full speed
		roll_timer += max(abs(top_speed), 16);
		animation_set_frame(animator, ((roll_timer - 1) div 32) mod animation_get_frame_count(animator));
	}
	
	if(has_tail)
	{
		animation_set_speed(tail_animator, (abs(top_speed) + 30) / 192);
		animator_update(tail_animator);
	}
}
