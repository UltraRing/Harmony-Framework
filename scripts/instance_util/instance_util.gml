function instance_act_solid(o, hitbox_other = noone, this = id, this_hitbox = noone)
{	
	// Temps
	var sideH = 0;
	var sideV = 0;
	var colX = o.x;
	var colY = o.y;
	
	// Make hitboxes
	var thisHitbox = _instance_evaluate_hitbox(this, this_hitbox);
	var otherHitbox = _instance_evaluate_hitbox(o, hitbox_other);
	
	// Orientate hitboxes depending on scale
	thisHitbox = _instance_orient_hitbox(this, thisHitbox);
	otherHitbox = _instance_orient_hitbox(o, otherHitbox);
	
	// Horizontal collision
	if(this.y + thisHitbox[BBOX.TOP] < o.y + otherHitbox[BBOX.BOTTOM] && this.y + thisHitbox[BBOX.BOTTOM] > o.y + otherHitbox[BBOX.TOP])
	{
		var cenX = this.x + (thisHitbox[BBOX.RIGHT] + thisHitbox[BBOX.LEFT]) * 0.5;
		if(o.x <= cenX)
		{
			if(o.x + otherHitbox[BBOX.RIGHT] + 1 >= this.x + thisHitbox[BBOX.LEFT])
			{
				sideH = C.LEFT;
				colX = this.x + (thisHitbox[BBOX.LEFT] - otherHitbox[BBOX.RIGHT]) - 1;
			}
		} 
		else if(o.x + otherHitbox[BBOX.LEFT] <= this.x + thisHitbox[BBOX.RIGHT] + 1)
		{
			sideH = C.RIGHT;
			colX = this.x + (thisHitbox[BBOX.RIGHT] - otherHitbox[BBOX.LEFT]) + 1;
		}
	}
	
	// Vertical collision
	var cenY = this.y + (thisHitbox[BBOX.TOP] + thisHitbox[BBOX.BOTTOM]) * 0.5;
	if(this.x + thisHitbox[BBOX.LEFT] < o.x + otherHitbox[BBOX.RIGHT] && this.x + thisHitbox[BBOX.RIGHT] > o.x + otherHitbox[BBOX.LEFT])
	{
		if(o.y < cenY)
		{
			if(o.y + otherHitbox[BBOX.BOTTOM] + 1 >= this.y + thisHitbox[BBOX.TOP])
			{
				sideV = C.TOP;	
				colY = this.y + (thisHitbox[BBOX.TOP] - otherHitbox[BBOX.BOTTOM]) - 1;
			}
		} 
		else if(o.y + otherHitbox[BBOX.TOP] <= this.y + thisHitbox[BBOX.BOTTOM])
		{
			sideV = C.BOTTOM;	
			colY = this.y + (thisHitbox[BBOX.BOTTOM] - otherHitbox[BBOX.TOP]);
		}
	}
	
	// Temps
	var side = 0;
	var deltaX = colX - o.x;
	var deltaY = colY - o.y;
	 
	// Get the correct collision side
	if((deltaX * deltaX >= deltaY * deltaY && (sideV || !sideH)) || (!sideH && sideV))
	{
		side = sideV;	
	}
	else
	{
		side = sideH;	
	}
	
	// Build the result struct
	var r = {
		object : o,
		this_object : this,
		this_box : thisHitbox,
		col_side : side,
		col_x : colX,
		col_y : colY
	}
	
	// Check if this is a player object
	var isPlayer = o.object_index == obj_player;
	
	if(side != 0)
	{
		// If the other object is the player, then execute player's reaction to solid object
		if(isPlayer)
		{
			if(o.debug || !o.collision_allow)
				return 0;
		
			player_react_solid(r);
		}
		else
			_instance_react_solid(r);
	}
	
	return side;
}

function instance_act_semi_solid(o, hitbox_other = noone, this = id, this_hitbox = noone)
{	
	// Make hitboxes
	var thisHitbox = _instance_evaluate_hitbox(this, this_hitbox);
	var otherHitbox = _instance_evaluate_hitbox(o, hitbox_other);
	
	// Orientate hitboxes depending on scale
	thisHitbox = _instance_orient_hitbox(this, thisHitbox);
	otherHitbox = _instance_orient_hitbox(o, otherHitbox);
	
	var otherEdge = o.y + otherHitbox[BBOX.BOTTOM];
	var otherEdgePrev = (o.y - o.y_speed) + otherHitbox[BBOX.BOTTOM];
	
	var platformTop = this.y + thisHitbox[BBOX.TOP] - 1;
	var platformBottom = this.y + thisHitbox[BBOX.TOP] + 4;
	
	var isColliding = (this.x + thisHitbox[BBOX.LEFT] < o.x + otherHitbox[BBOX.RIGHT]) &&
		(this.x + thisHitbox[BBOX.RIGHT] > o.x + otherHitbox[BBOX.LEFT]) &&
		o.y_speed >= 0 && otherEdge >= platformTop - 1 && otherEdgePrev <= platformBottom;
		
	if(isColliding)
	{
		o.y = platformTop - otherHitbox[BBOX.BOTTOM];
		
		// Check if this is a player object
		var isPlayer = o.object_index == obj_player;
		
		if(isPlayer)
		{
			// Flag player as on object
			o.on_object = true;
			
			// Make sure the ground is flat
			o.ground_angle = 0;
			
			// Ledge direction
			if(o.ground && o.x < this.x + thisHitbox[BBOX.LEFT])
				o.ledge = -1;
				
			if(o.ground && o.x > this.x + thisHitbox[BBOX.RIGHT])
				o.ledge = 1;
		
			// Going down
			if(o.y_speed > 0)
			{
				// Land the player
				if(!o.ground)
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
		}
		
		return true;
	}
}

function instance_collide(o, hitbox_other = noone, this = id, this_hitbox = noone)
{
	// Make hitboxes
	var thisHitbox = _instance_evaluate_hitbox(this, this_hitbox);
	var otherHitbox = _instance_evaluate_hitbox(o, hitbox_other);
	
	// Orientate hitboxes depending on scale
	thisHitbox = _instance_orient_hitbox(this, thisHitbox);
	otherHitbox = _instance_orient_hitbox(o, otherHitbox);
	
	if(!instance_exists(this))
	{
		return false;	
	}
	
	// Horizontal collision
	if(rectangle_in_rectangle(this.x + thisHitbox[BBOX.LEFT], this.y + thisHitbox[BBOX.TOP], this.x + thisHitbox[BBOX.RIGHT] - 1, this.y + thisHitbox[BBOX.BOTTOM] - 1,
		o.x + otherHitbox[BBOX.LEFT], o.y + otherHitbox[BBOX.TOP], o.x + otherHitbox[BBOX.RIGHT] - 1, o.y + otherHitbox[BBOX.BOTTOM]) - 1)
		return true;
}

function instance_position_hitbox(px, py, hitbox = noone, this = id)
{
	// Do not do anything if the object doesn't exist
	if(!instance_exists(this))
		return noone;
	
	// Make a hitbox
	var b = _instance_evaluate_hitbox(this, hitbox);
	
	// Get the difference between the current position and a new position
	var diffX = px - this.x;
	var diffY = py - this.y;
	
	// Offset the hitbox by the difference
	b[BBOX.LEFT] += diffX;
	b[BBOX.RIGHT] += diffX;
	b[BBOX.TOP] += diffY;
	b[BBOX.BOTTOM] += diffY;
	
	// All done
	return b;
}

function instance_register_culling(culling_region = noone, on_culling = noone, flags = CULL_FLAG.CHECK_ENTITY_POS)
{
	var c = {left : -32, right : 32, top : -32, bottom : 32}
	
	if(is_array(culling_region))
	{
		c.left = culling_region[BBOX.LEFT];	
		c.right = culling_region[BBOX.RIGHT];	
		c.top = culling_region[BBOX.TOP];	
		c.bottom = culling_region[BBOX.BOTTOM];	
	}
	else if(culling_region)
	{
		c = culling_region;	
	}
	
	// Make a default struct
	culling_struct =
	{
		inst_id : id,
		region : c,
		type : CULL_TYPE.DEACTIVATE,
		cull_flag : false,
		culled : on_culling,
		flag : flags
	}
	
	// Add the object to the list
	ds_list_add(obj_level.instance_list, culling_struct);	
}

function instance_flash(interval, offset = 0, timer = FRAME_TIMER)
{
	if((timer + offset) mod (interval * 2) < interval)
		return true;
}

function instance_recorder_init(size = 60) constructor
{
	timer = 0;
	value_id = 0;
	record_size = size;
	instance_list = [];
	variable_list = [];
	update_list = [[]];
}

function instance_recorder_add(recorder, variable_name, inst_id = id)
{
	// Store the old ID
	var oldID = recorder.value_id;
	
	// Store the data
	recorder.variable_list[oldID] = variable_name;
	recorder.instance_list[oldID] = inst_id;
	
	// Increment the ID
	recorder.value_id++;
	
	// Return it
	return oldID;
}

function instance_recorder_update(recorder)
{
	// Get the recording list
	var s = array_length(recorder.variable_list);
	
	// Update the timer
	recorder.timer++;
	
	// Update all of the values
	for (var i = 0; i < s; ++i) 
	{
		//if(variable_instance_get(recorder.instance_list[i], recorder.variable_list))
		recorder.update_list[i][recorder.timer mod recorder.record_size] = variable_instance_get(recorder.instance_list[i], recorder.variable_list[i]);
	}
}

function instance_recorder_get_value(recorder, value_id, offset)
{
	return recorder.update_list[value_id][(max(recorder.timer - offset, 0) mod recorder.record_size)];
}

function instance_create_bullet(sprite, animation_speed, x, y, obj_depth, x_speed, y_speed, grav = 0.2)
{
	//Create bullet object
	var bullet = instance_create_depth(x, y, obj_depth, obj_bullet);
	
	//Change its properties
	bullet.sprite_index = sprite;
	bullet.x_speed = x_speed;
	bullet.y_speed = y_speed;
	bullet.grav = grav;
	
	//Play animation
	with(bullet)
		animation_play_no_list(animator, sprite, animation_speed);
	
	//Return the bullet's ID
	return bullet;
}

// ===========================================================================================================
// Utilities internal functions
// ===========================================================================================================
function _instance_react_solid(result)
{
	// Get values from the struct
	var o = result.object;
	var side = result.col_side;
	var colX = result.col_x;
	var colY = result.col_y
	
	// Vertical collision sides
	if(side == C.TOP || side == C.BOTTOM)
	{
		// Position the object
		o.y = colY;	
		
		// Stop object's vertical movement if it exists
		if(variable_instance_exists(o, "y_speed"))
		{
			if(side == C.TOP && o.y_speed > 0 || side == C.BOTTOM && o.y_speed < 0)
				o.y_speed = 0;
		}
	}
	
	// Horizontal collision sides
	if(side == C.LEFT || side == C.RIGHT)
	{
		// Position the object
		o.x = colX;	
			
		// Stop object's horizontal movement if it exists
		if(variable_instance_exists(o, "y_speed"))
		{
			if(side == C.LEFT && o.x_speed > 0 || side == C.RIGHT && o.x_speed < 0)
				o.x_speed = 0;
		}
	}
}

function _instance_orient_hitbox(this, hitbox) 
{
	var dstBox
	
	if(!instance_exists(this))
	{
		dstBox[BBOX.LEFT] = hitbox[BBOX.LEFT];
		dstBox[BBOX.RIGHT] = hitbox[BBOX.RIGHT];
		dstBox[BBOX.TOP] = hitbox[BBOX.TOP];
		dstBox[BBOX.BOTTOM] = hitbox[BBOX.BOTTOM];
		return dstBox;
	}
	
	dstBox[BBOX.LEFT] = hitbox[BBOX.LEFT] * this.image_xscale;
	dstBox[BBOX.RIGHT] = hitbox[BBOX.RIGHT] * this.image_xscale;
	dstBox[BBOX.TOP] = hitbox[BBOX.TOP] * this.image_yscale;
	dstBox[BBOX.BOTTOM] = hitbox[BBOX.BOTTOM] * this.image_yscale;

	if (dstBox[BBOX.LEFT] > dstBox[BBOX.RIGHT]) 
	{
		var s = dstBox[BBOX.LEFT]
		dstBox[BBOX.LEFT] = dstBox[BBOX.RIGHT];
		dstBox[BBOX.RIGHT] = s;
	}
	
	if (dstBox[BBOX.TOP] > dstBox[BBOX.BOTTOM]) 
	{
		var s = dstBox[BBOX.TOP]
		dstBox[BBOX.TOP] = dstBox[BBOX.BOTTOM];
		dstBox[BBOX.BOTTOM] = s;
	}
	
	return dstBox;
}

function _instance_make_hitbox(inst)
{
	var newBox;
	
	// Fallback
	if(!instance_exists(inst))
	{
		newBox[BBOX.LEFT] = 0;
		newBox[BBOX.RIGHT] = 0;
		newBox[BBOX.TOP] = 0;
		newBox[BBOX.BOTTOM] = 0;
		return newBox;
	}
	
	var s = inst.sprite_index;
	
	if(inst.mask_index)
		s = mask_index;
	
	newBox[BBOX.LEFT] = sprite_get_bbox_left(s) - sprite_get_xoffset(s);
	newBox[BBOX.RIGHT] = sprite_get_bbox_right(s) - sprite_get_xoffset(s) + 1;
	newBox[BBOX.TOP] = sprite_get_bbox_top(s) - sprite_get_yoffset(s);
	newBox[BBOX.BOTTOM] = sprite_get_bbox_bottom(s) - sprite_get_yoffset(s) + 1;
	
	return newBox;
}

function _instance_evaluate_hitbox(this, hitbox)
{
	var newBox;
	
	// Check if hitbox is a valid array
	if(is_array(hitbox))
	{
		newBox = hitbox;
	}
	else if(is_struct(hitbox))
	{
		// If it's not an array, check if it's a struct
		newBox[BBOX.LEFT] = hitbox.left;
		newBox[BBOX.RIGHT] = hitbox.right;
		newBox[BBOX.TOP] = hitbox.top;
		newBox[BBOX.BOTTOM] = hitbox.bottom;

	}
	else
	{
		// If it's not a struct either, build a new hitbox
		newBox = _instance_make_hitbox(this);
	}	
	
	return newBox;
}