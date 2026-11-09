/// @description Script
	// Physics
	y += y_speed;
	y_speed += 0.2;
	landed = false;

	// Bounce physics
	if(collision_get_distance(x, y + 8) < 0)
	{
		bounce = true;
		y_speed = -4;
	}
	
	// Start adding timer after ring bounced
	if(bounce) timer++;
	
	// Turn into dust
	if(timer == 36)
	{
		sound_play(sfx_dust);
		effect_create_dust(0);
	}