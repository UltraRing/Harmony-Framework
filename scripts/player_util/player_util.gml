/// @self						
/// @description							That changes player's collision mode
/// @param {Real} [force_mode]				Parameter that changes the collision mode (The default is -1 which means it's going to get rotated by the ground angle)
function player_mode(force_mode = -1)
{
	// Change the ground mode
	mode = round(ground_angle / 90) % 4;
	
	// Force the ground rotation mode if it's set
	if(force_mode != -1)
		mode = force_mode;
	
	// Change direction
	x_dir = dsin(90 * mode);
	y_dir = dcos(90 * mode);
}

/// @self						
/// @description						Function that is used to either hurt or kill the player
/// @param {Real} [hazard_x]			The location of the hazard (The default is instance's x position)
/// @param {Real} [hurt_type]			In what kind of way is the player getting hurt (The default is normal hurt)
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
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
						if(shield != SHIELD.NONE)
						{
							shield = SHIELD.NONE;
							sound_play(sfx_hurt);
							exit;
						}
					
						//Commit ring loss when player gets hurt
						if(global.rings == 0 && shield == SHIELD.NONE)
						{
							_player_kill();
							exit;	
						}
						
						// Lose the combine ring
						if(shield == SHIELD.NONE && combinering != 0)
						{
							//Chaotix combine ring
							var combi = instance_create_depth(x, y, depth-1, obj_combine_ring);
							combi.rings = global.rings;
							combi.x_speed = 1 * facing;
							sound_play(sfx_hurt);
							global.rings = 0;
							combineloss = 1;
							combinering = 0;
							exit;
						}
						
						// Lose all of your rings
						if(shield == SHIELD.NONE && !combinering)
						{
							instance_create_ringloss(global.rings);	
							sound_play(sfx_ringloss);
							global.rings = 0;
							exit;
						}
					}
					else
					{
						sound_play(sfx_hurt);
					}
					
				break;
			}
		}
	}
}

/// @self						
/// @description						Function that returns the instance ID of the player object
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
/// @return {Id.Instance}
function player_find(player_id = 0)
{
	return instance_find(obj_player, player_id);	
}

/// @self						
/// @description						Function that returns the player's hitbox size
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
/// @return {Array}
function player_get_hitbox(player_id)
{
	var player = instance_find(obj_player, player_id);
	return [-player.wall_w, -player.hitbox_h, player.wall_w, player.hitbox_h];
}

/// @self						
/// @description						Function that makes an instance solid for the player object
/// @param {Array|Struct} [this_hitbox]	The hitbox size of the current object (The default is unset, it will get baked in)
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
/// @return {Real}
function player_act_solid(this_hitbox = -1, player_id = 0)
{
	return instance_act_solid(player_find(player_id), player_get_hitbox(player_id), id, this_hitbox);
}

/// @self						
/// @description						Function that makes an instance semi solid for the player object
/// @param {Array|Struct} [this_hitbox]	The hitbox size of the current object (The default is unset, it will get baked in)
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
/// @return {bool}
function player_act_semi_solid(this_hitbox = -1, player_id = 0)
{
	var p = player_find(player_id);
	if(p.debug || !p.collision_allow)
		return 0;
				
	return instance_act_semi_solid(p, player_get_hitbox(player_id), id, this_hitbox);
}

/// @self						
/// @description						Function that checks if the player is colliding with the current instance
/// @param {Array|Struct} [this_hitbox]	The hitbox size of the current object (The default is unset, it will get baked in)
/// @param {Real} [side]				On which side is the player colliding with (The default is the main hitbox)
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
/// @return {bool}
function player_collide_object(this_hitbox = -1, side = COLLISION.MAIN, player_id = 0)
{	
	//Get nearest player object:
	var p = player_find(player_id);
	var pBox = player_get_hitbox(player_id);
	
	//Define hitbox size:
	switch(side)
	{
		//Bottom side of the hitbox:
		case COLLISION.BOTTOM: 
		pBox[BBOX.TOP] = 0;
		pBox[BBOX.BOTTOM]++;
		break;
		
		//Top side of the hitbox:
		case COLLISION.TOP: 
		pBox[BBOX.BOTTOM] = 0;
		pBox[BBOX.TOP]--;
		break;
		
		//Left side of the hitbox:
		case COLLISION.LEFT: 
		pBox[BBOX.RIGHT] = 0;
		pBox[BBOX.LEFT]--;
		break;
		
		//Right side of the hitbox:
		case COLLISION.RIGHT:
		pBox[BBOX.LEFT] = 0;
		pBox[BBOX.RIGHT]++;
		break;
	}
	
	var col = instance_collide(p, pBox, id, this_hitbox);
	
	if(p.hitbox_allow)
		return col;
	
}

/// @self						
/// @description						Function that checks if the insta-shield is colliding with the current instance
/// @param {Array|Struct} [this_hitbox]	The hitbox size of the current object (The default is unset, it will get baked in)
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
/// @return {bool}
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

/// @self						
/// @description						Function sets a shield to the target player object, along with resetting the shield state
/// @param {Real} shield_id				Which shield is getting set
/// @param {Real} [player_id]			Which player object is being used (The default is the first player instance)
function player_set_shield(shield_id, player_id = 0)
{
	// Mandatory shield state reset
	with(player_find(player_id))
	{
		with(shield_obj)
		{
			image_angle = 0;
			image_xscale = 1;
			image_yscale = 1;
			
			animator_reset(animator);
		}
		
		shield = shield_id;
	}
}

// ===========================================================================================================
// Internal utility functions
// ===========================================================================================================

/// @self								obj_player
/// @description						An internal function for killing the player
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
	sound_play(sfx_hurt);
}

/// @self								obj_player
/// @description						An internal function for rendering player's after image effects, this is done to keep the draw event cleaner
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

/// @self
/// @description						An internal function for player's reaction to the solid object
/// @param {Struct} result				The result struct that was made by the solid function
function _player_react_solid(result)
{
	// Get values from the struct
	var o = result.object;
	var this = result.this_object;
	var side = result.col_side;
	var colX = result.col_x;
	var colY = result.col_y
	
	// Vertical collision sides
	if(side == COLLISION.TOP || side == COLLISION.BOTTOM)
	{
		// Position the object
		o.y = colY;	
		
		// Flag player as on object
		if(side == COLLISION.TOP && o.mode == 0)
		{
			o.on_object = true;
			o.on_object_count++;
			
			if(!o.on_terrain)
				o.ground_angle = 0;
			
			// Ledge direction
			if(o.ground && o.x < this.x + result.this_box[BBOX.LEFT])
				o.ledge = -1;
				
			if(o.ground && o.x > this.x + result.this_box[BBOX.RIGHT])
				o.ledge = 1;
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
			if(!o.ground && side = COLLISION.TOP)
			{
				// Stop falling
				o.y_speed = 0;
				
				// Transfer speed
				if(!o.ground)
					o.ground_speed = o.x_speed;
				
				o.ground = true;	
				with(o)	
					_player_land_callback();
			}
		}

		// Going up
		if(o.y_speed < 0)
		{
			if(!o.ground && side == COLLISION.BOTTOM)
				o.y_speed = 0;
			
			// If player is going up the walls, then stop
			if(o.ground && (o.mode == 1 || o.mode == 3))
			{
				o.ground_speed = 0;	
			}
		}

	}
		
	// Horizontal collision sides
	if(side == COLLISION.LEFT || side == COLLISION.RIGHT)
	{
		// Position the object
		o.x = colX;	
		clamp_storex = colX;
		
		// Stop the object from moving
		var spdVal = o.ground ? "ground_speed" : "x_speed";
		var spd = variable_instance_get(o, spdVal);
			
		if(side == COLLISION.LEFT && spd > 0 || side == COLLISION.RIGHT && spd < 0)
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

/// @self								obj_player	
/// @description						An internal function that gets called every time the player lands
function _player_land_callback()
{
	// Reset the badnik chain
	obj_level.badnik_chain = 0;
	
	// Stop rolling when landing
	if(state == player_state_roll && !force_roll)
	{
		state = player_state_normal;	
	}
}

/// @self								obj_player	
/// @description						An internal function that updates the player hitbox
/// @param {Bool} reposition			Should the player object get repositioned depending on the ground orentation if the hitbox size changes
function _player_hitbox(reposition = false)
{
	//Get previous hitbox height
	var old_hitbox_h = hitbox_h;
	
	//Reset camera offset if player is not playing rolling animation
	if(!animation_is_playing(animator, ANIM.ROLL)) 
	{
		obj_camera.roll_offset = 0;
	}
	
	//Original hitbox values
	hitbox_w = hitbox_normal[global.character][0];
	hitbox_h = hitbox_normal[global.character][1];
	
	//Roll hitboxes
	if(animation_is_playing(animator, ANIM.ROLL) || animation_is_playing(animator, ANIM.DROPDASH) || state == player_state_jump)
	{
		//Change the camera offset for rolling
		if(ground)
		{
			obj_camera.roll_offset = camera_rolling_offset[global.character];
		}
		
		//Change the hitbox for rolling animation
		hitbox_w = hitbox_rolling[global.character][0];
		hitbox_h = hitbox_rolling[global.character][1];
	}
	
	//Knuckles specific hitboxes
	if(state == player_state_glide || state == player_state_knuxslide)
	{
		hitbox_h = 10;
	}
	
	//Change floor position when jumping or when on ground
	if(reposition)
	{
		x += (old_hitbox_h - hitbox_h) * x_dir;
		y += (old_hitbox_h - hitbox_h) * y_dir;
	}
	
	//Crouch hitbox offset
	if(animation_is_playing(animator, ANIM.LOOKDOWN))
	{
		hitbox_top_offset = -hitbox_normal[global.character][1];
	}
}