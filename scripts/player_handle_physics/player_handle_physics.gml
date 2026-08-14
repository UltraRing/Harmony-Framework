/// @self					obj_player	
/// @description			Function that handles player's physics attributes
function player_handle_physics()
{
	//Setup physics table for each character
	var physics_table =
	{
		accel : [0.046875, 0.046875, 0.046875],
		deaccel : [0.5,0.5,0.5],
		fric : [0.046875, 0.046875, 0.046875],
		grav : [0.21875, 0.21875, 0.21875],
		top_speed : [6.0, 6.0, 6.0],
		jump_strength : [6.5, 6.5, 6.0],
		jump_release : [4.0, 4.0, 4.0],
		roll_fric : [0.0234375,0.0234375,0.0234375],
		slope_up : [0.078125, 0.078125, 0.078125],
		slope_down : [0.3125, 0.3125, 0.3125]
	};
	
	if (super)
	{
		physics_table.accel = [0.1875, 0.09375, 0.09375]
		physics_table.deaccel = [1,0.75,0.75]
		physics_table.grav = [0.21875, 0.21875, 0.21875]
		physics_table.top_speed = [10.0, 8, 8]
		physics_table.jump_strength = [8, 8, 6.0]	
		
		// Make sure that this is off
		speed_shoes_flag = false;
		speed_shoes = 0;
	}
	
	//Assign the physics value
	x_accel = physics_table.accel[character];
	x_deaccel = physics_table.deaccel[character];
	friction_speed = physics_table.fric[character];
	top_speed = physics_table.top_speed[character];
	jump_strength = physics_table.jump_strength[character];
	jump_release = physics_table.jump_release[character];
	roll_friction = physics_table.roll_fric[character];
	roll_influence_up = physics_table.slope_up[character];
	roll_influence_down = physics_table.slope_down[character];
	
	//For gravity it's different case
	if(state != player_state_tailsfly)
	{
		//Apply the gravity
		y_accel = physics_table.grav[character];
		
		//Underwater gravity
		if(underwater || state == player_state_drown)
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