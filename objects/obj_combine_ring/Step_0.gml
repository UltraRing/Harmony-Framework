     
	var _scale = 1.2 + (dcos(1 * 8) * 0.22)
	image_xscale = _scale
	image_yscale = _scale
	
	var RandomRingSparkle = [spr_ring_sparkle, spr_ring_sparkle, spr_ring_sparkle, spr_ring_sparkle, spr_ring_sparkle, spr_ring_sparkle];
	
	//Add timer
	timer++
	
	//Shatter the big ring
	if(timer > 256)
	{
		create_ringloss(rings);
		play_sound(sfx_dust);
		play_sound(sfx_ringloss);
		obj_player.combineloss = 0;
		instance_destroy();	
	}
	
	//Collect the ring
	if(obj_player.state != player_state_knockout && player_collide_object(C.MAIN))
	{
		global.rings += rings;	
		instance_destroy();
		play_sound(sfx_ring);
		obj_player.combineloss = 0;
		for (var i = 0; i < 4; ++i) {
		    create_effect(x + random_range(-16, 16), y + random_range(-16, 16), spr_ring_sparkle, 0.2);	
		}
	}
	
	//Create effects
	if(FRAME_TIMER mod 8 == 0)
	{
		create_effect(x + random_range(-16, 16), y + random_range(-16, 16), spr_ring_sparkle, 0.2);	
		create_effect(x + random_range(-16, 16), y + random_range(-16, 16), spr_ring_sparkle, 0.2);	
	}
	
	//Add speeds to position
	x += x_speed;
	y += y_speed;
	
	//Gravity
	y_speed += 0.09375;
			
	//Collision detection
	var hc = collision_get_distance(x + 16 * sign(x_speed), y, sign(x_speed) ? CMODE.LWALL : CMODE.RWALL, plane, false);
	var vc = collision_get_distance(x, y + 16 * sign(y_speed), sign(y_speed) ? CMODE.FLOOR : CMODE.CEILING, plane, sign(y_speed));
		
	// Bounce off floor and ceiling
	if(vc < 0)
	{
		y += vc * sign(y_speed);
		y_speed *= -1;
	}
		
	// Bounce off walls
	if(hc < 0)
	{
		x += hc * sign(x_speed);
		x_speed *= -1;
	}

	