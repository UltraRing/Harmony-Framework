function player_handle_physics()
{
	//Setup physics table for each character
	var physics_table = char_get_physics_table();
	
	if (super)
	{
		// Make sure that this is off
		speed_shoes_flag = false;
		speed_shoes = 0;
	}
	
	//Assign the physics value
	x_accel = physics_table.accel[super];
	x_deaccel = physics_table.deaccel[super];
	friction_speed = physics_table.fric[super];
	top_speed = physics_table.top_speed[super];
	jump_strength = physics_table.jump_strength[super];
	jump_release = physics_table.jump_release[super];
	roll_friction = physics_table.roll_fric[super];
	roll_influence_up = physics_table.slope_up[super];
	roll_influence_down = physics_table.slope_down[super];
	
	//For gravity it's different case
	if(state != player_state_tailsfly)
	{
		//Apply the gravity
		y_accel = physics_table.grav[super];
		
		//Underwater gravity
		if(underwater)
		{
			y_accel = 0.0625;	
		}
	}
	
	//Multiplier for speed shoes
	if(speed_shoes_flag) 
	{
        top_speed *= 2.0;
        x_accel *= 2.0;
    }
	
	//Underwater multiplier
    if(underwater) 
	{
        top_speed *= 0.5;
        x_accel *= 0.5;
		x_deaccel *= 0.5;
		roll_friction *= 0.5;
        friction_speed *= 0.5;
		jump_release *= 0.5;
		jump_strength *= 0.5;
    }
}