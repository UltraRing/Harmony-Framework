function player_state_jump(){
	//Reset when grounded
	if(ground) 
	{
		state = player_state_normal;
		exit;
	}
	
	//Change flags
	attacking = true;
	
	//Limit the jump when key is released
	if(!hold_action && y_speed < -jump_release && jump_flag)
	{
		jump_flag = false;
		y_speed = -jump_release;
	}

	//Change animation
	animation_play(animator, ANIM.ROLL);
	
	//Change animation speed
	if(character != CHAR_TAILS)
	{
		animation_set_duration(animator, jump_anim_speed);
	}	
	
	//execute shield ability
	if(press_action && character == CHAR_SONIC)
	{
		if(instance_exists(par_shield)) 
		{
			with(par_shield) 
			{
				if(use_allow && shield_state == 0) 
				{
					script_execute(jump) 
				}
			}
		}
		
		// Create insta shield
		if(global.use_insta_shield && !insta_shield_used && (shield == S_NONE || shield == S_NORMAL))
		{
			insta_shield_invincible = 16;
			insta_shield_used = true;
			
			insta_shield_ptr = instance_create_depth(x, y, depth - 10, obj_insta_shield);
			insta_shield_ptr.player = id;
		
			play_sound(sfx_insta_shield);
		}
	}
	
	//super transformation
	var superButton = input_press(global.super_button) && !input_disable;
	if (!super && allow_super && global.rings >= 50 && game_has_all_emeralds() && superButton && y_speed > -jump_release)
	{
		state = player_state_transform
		x_speed = 0;
		y_speed = 0;
		exit;
	}
	
	
	
	if(global.use_dropdash) 
	{
		//Add dropdash timer
		if(character == CHAR_SONIC)
		{
			if(press_action && dropdash_timer < 1 || hold_action && dropdash_timer != 0)
			{
				dropdash_timer++;
			}
		}
		
		//Trigger the dropdash state
		if(dropdash_timer >= 8 && state != player_state_dropdash)
		{
			play_sound(sfx_dropdash);
			state = player_state_dropdash;
			exit;
		}
	
	}
	
	//Trigger fly
	if(press_action && character == CHAR_TAILS)
	{
		tails_timer = 480;
		y_accel = 0.03125;
		state = player_state_tailsfly;
		exit;
	}
	
	//Trigger the glide
	if(character == CHAR_KNUX && press_action && y_speed > -jump_release)
	{
		control_lock = 4;
		glide_speed = 4;
		knuckles_angle = 90 * facing;
		y_speed = max(y_speed, 0.5);
		state = player_state_glide;
		facing = facing;
		animation_play(animator, ANIM.KNUXGLIDE);
		exit;
	}
	
	//Trigger rolling
	player_check_roll();
}

function player_check_jump()
{
	if(press_action && ground && !touching_ceiling && !force_roll)
	{
		//Change animation
		animation_play(animator, ANIM.ROLL);
		
		//Jump off the terrain
		y_speed -= jump_strength * dcos(ground_angle);	
		x_speed -= jump_strength * dsin(ground_angle);
			
		//Trigger the jump flag
		jump_flag = true;
			
		//Detach player off the ground and change state
		ground = false;
		state = player_state_jump
		dropdash_timer = 0;
		idle_timer = 0;
		//Change jump animation duration
		jump_anim_speed = floor(max(0, 4-abs(ground_speed)));
			
		//Reset angle and floor mode
		ground_angle = 0;
		player_reposition_mode(CMODE.FLOOR);
			
		//Play the sound
		play_sound(sfx_jump);
		return true;
	}
}