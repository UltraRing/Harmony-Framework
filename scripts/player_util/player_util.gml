function player_reposition_mode(force_mode = -1)
{
	mode = round(ground_angle/90) % 4;
	
	var true_mode = mode;
	
	if(force_mode != -1)
	{
		true_mode = force_mode;	
	}
	
	//Change direction
	x_dir = dsin(90 * true_mode);
	y_dir = dcos(90 * true_mode);
}

function player_hurt(hazard_x = x, hurt_type = K_HURT, player_id = 0)
{
	with(player_find(player_id))
	{
		// Do not even bother.
		if(disable_death)
			exit;
		
		// Hurt the player if not invincible
		if(invincible_timer == 0 && insta_shield_invincible == 0 && !invincible)
		{
			//hurt_position = hazard_x;
			knockout_type = hurt_type;
			
			switch(hurt_type)
			{
				case K_DIE:
					_player_kill();
				break;
				
				case K_STUNNED:
				case K_HURT:	
					//Get the hurt side
					var side = sign(x - hazard_x) ? 1 : -1;
				
					// Knock the player out
					facing = -side;
					x_speed = (2 * side) / (1 + underwater);
					y_speed = -4 / (1 + underwater);
					ground = false;
					invincible_timer = 120;
					state = player_state_knockout;

					// Unrelated to stunned behaviour [ordering of this matters a lot]
					if(hurt_type == K_HURT)
					{
						//Remove the shield when player gets hurt
						if(shield != S_NONE)
						{
							shield = S_NONE;
							play_sound(sfx_hurt);
							exit;
						}
					
						//Commit ring loss when player gets hurt
						if(global.rings == 0 && shield == S_NONE)
						{
							_player_kill();
							exit;	
						}
						
						// Lose the combine ring
						if(shield == S_NONE && combinering != 0)
						{
							//Chaotix combine ring
							var combi = instance_create_depth(x, y, depth-1, obj_combine_ring);
							combi.rings = global.rings;
							combi.x_speed = 1 * facing;
							play_sound(sfx_hurt);
							global.rings = 0;
							combineloss = 1;
							combinering = 0;
							exit;
						}
						
						// Lose all of your rings
						if(shield == S_NONE && !combinering)
						{
							create_ringloss(global.rings);	
							play_sound(sfx_ringloss);
							global.rings = 0;
							exit;
						}
					}
					else
					{
						play_sound(sfx_hurt);
					}
					
				break;
			}
		}
	}
}

function player_find(player_id)
{
	return instance_find(obj_player, player_id);	
}

function player_get_hitbox(player_id)
{
	var player = instance_find(obj_player, player_id);
	return [-player.wall_w, -player.hitbox_h, player.wall_w, player.hitbox_h];
}

function player_act_solid(this_hitbox = -1, player_id = 0)
{
	return instance_act_solid(player_find(player_id), player_get_hitbox(player_id), id, this_hitbox);
}

function player_act_semi_solid(this_hitbox = -1, player_id = 0)
{
	var p = player_find(player_id);
	if(p.debug || !p.collision_allow)
		return 0;
				
	return instance_act_semi_solid(p, player_get_hitbox(player_id), id, this_hitbox);
}

function player_react_solid(result)
{
	// Get values from the struct
	var o = result.object;
	var this = result.this_object;
	var side = result.col_side;
	var colX = result.col_x;
	var colY = result.col_y
	
	// Vertical collision sides
	if(side == C.TOP || side == C.BOTTOM)
	{
		// Position the object
		o.y = colY;	
		
		// Flag player as on object
		if(side == C.TOP && o.mode == 0)
		{
			o.on_object = true;
			
			var isLeft = false;
			var isRight = false;
			
			if(!o.on_terrain)
				o.ground_angle = 0;
			
			// Ledge direction
			if(o.ground && o.x < this.x + result.this_box[BBOX.LEFT])
				isLeft = true;
				
			if(o.ground && o.x > this.x + result.this_box[BBOX.RIGHT])
				isRight = true;
			
			o.ledge = isRight - isLeft;
		}
		
		// Going down
		if(o.y_speed > 0)
		{
			// If player is going down the falls and hits an object, stop the player
			if(o.ground && (o.mode == 1 || o.mode == 3))
			{
				o.ground_speed = 0;	
			}
			
			// Land the player
			if(!o.ground && side = C.TOP)
			{
				// Stop falling
				o.y_speed = 0;
				
				// Transfer speed
				if(!o.ground)
					o.ground_speed = o.x_speed;
				
				o.ground = true;	
				with(o)	
					player_land_callback();
			}
		}

		// Going up
		if(o.y_speed < 0)
		{
			if(!o.ground && side == C.BOTTOM)
				o.y_speed = 0;
			
			// If player is going up the walls, then stop
			if(o.ground && (o.mode == 1 || o.mode == 3))
			{
				o.ground_speed = 0;	
			}
		}

	}
		
	// Horizontal collision sides
	if(side == C.LEFT || side == C.RIGHT)
	{
		// Position the object
		o.x = colX;	
			
		// Stop the object from moving
		var spdVal = o.ground ? "ground_speed" : "x_speed";
		var spd = variable_instance_get(o, spdVal);
			
		if(side == C.LEFT && spd > 0 || side == C.RIGHT && spd < 0)
		{
			variable_instance_set(o, spdVal, 0);	
		}
					
		if(o.ground)
		{	
			// Get the correct pushing animation
			o.pushing = side;
			
			// Detach from ceiling
			if(o.mode == 2)
				o.ground_speed = 0;
		}
	}
}

function player_collide_object(this_hitbox = -1, side = C.MAIN, player_id = 0)
{	
	//Get nearest player object:
	var p = player_find(player_id);
	var pBox = player_get_hitbox(player_id);
	
	//Define hitbox size:
	switch(side)
	{
		//Bottom side of the hitbox:
		case C.BOTTOM: 
		pBox[BBOX.TOP] = 0;
		pBox[BBOX.BOTTOM]++;
		break;
		
		//Top side of the hitbox:
		case C.TOP: 
		pBox[BBOX.BOTTOM] = 0;
		pBox[BBOX.TOP]--;
		break;
		
		//Left side of the hitbox:
		case C.LEFT: 
		pBox[BBOX.RIGHT] = 0;
		pBox[BBOX.LEFT]--;
		break;
		
		//Right side of the hitbox:
		case C.RIGHT:
		pBox[BBOX.LEFT] = 0;
		pBox[BBOX.RIGHT]++;
		break;
	}
	
	var col = instance_collide(p, pBox, id, this_hitbox);
	
	if(p.hitbox_allow)
		return col;
	
}

function player_insta_shield_collide(this_hitbox = -1, player_id = 0)
{
	// Get the player
	var player = player_find(player_id);
	
	// No insta shield
	if(!instance_exists(player.insta_shield_ptr))
		exit;
		
	// Otherwise, collision
	if(player.hitbox_allow)
		return instance_collide(player, [-INSTA_SHIELD_BOX_SIZE, -INSTA_SHIELD_BOX_SIZE, INSTA_SHIELD_BOX_SIZE, INSTA_SHIELD_BOX_SIZE], id, this_hitbox);	
}

// Player internals
function _player_kill()
{
	// No need to kill again
	if(state == player_state_death || state == player_state_drown || disable_death)
		exit;
		
	//Set player to the knockout state
	state = player_state_death;
			
	//Bounce the player out
	y_speed = -7;
	x_speed = 0;
	ground = false;
	
	//Disable camera movement
	camera_set_mode(CAM_NULL);
			
	//Play the hurt sound
	play_sound(sfx_hurt);
}

function _player_draw_after_images()
{
	// Render when these flags are on
	if(!speed_shoes_flag && !super)
		exit;
	
	// Don't render when not moving
	if(x_speed == 0 && y_speed == 0)
		exit;
	
	
	var xpos, ypos, sprite, frame, f, vangle, t_visible, t_sprite, t_frame, t_x, t_y, t_f, t_vangle
	
	for (var i = 3; i > 0; --i) 
	{
		// Flashing
		if(instance_flash(2, i))
			continue;
			
		var gap = i * 3;
		
		xpos = instance_recorder_get_value(recorder, rec_vals.xpos, gap);
		ypos = instance_recorder_get_value(recorder, rec_vals.ypos, gap);
		sprite = instance_recorder_get_value(recorder, rec_vals.sprite, gap);
		frame = instance_recorder_get_value(recorder, rec_vals.frame, gap);
		f = instance_recorder_get_value(recorder, rec_vals.facing, gap);
		vangle = instance_recorder_get_value(recorder, rec_vals.vangle, gap);
		
		t_visible = instance_recorder_get_value(recorder, rec_vals.t_visible, gap);
		t_sprite = instance_recorder_get_value(recorder, rec_vals.t_sprite, gap);
		t_frame = instance_recorder_get_value(recorder, rec_vals.t_frame, gap);
		t_x = instance_recorder_get_value(recorder, rec_vals.t_x, gap);
		t_y = instance_recorder_get_value(recorder, rec_vals.t_y, gap);
		t_f = instance_recorder_get_value(recorder, rec_vals.t_facing, gap);
		t_vangle = instance_recorder_get_value(recorder, rec_vals.t_angle, gap);
		
		// Render Tails' tails
		if(character == CHAR_TAILS && t_visible)
		{
			var px = floor(xpos) + t_x * dcos(t_vangle) + t_y * dsin(t_vangle);
			var py = floor(ypos) + t_y * dcos(t_vangle) - t_x * dsin(t_vangle);
			
			draw_sprite_ext(t_sprite, t_frame, floor(px), floor(py), t_f, 1, t_vangle, c_white, 1);
		}
		
		draw_sprite_ext(sprite, frame, floor(xpos), floor(ypos), f, 1, vangle, c_white, 1);
	}	
}