function player_state_dropdash(){
	
	//Animate dropdash
	animation_play(animator, ANIM.DROPDASH);
	
	//Make it attack
	attacking = true;
	
	//Go back to jump when not holding the button
	if(!hold_action)
	{
		dropdash_timer = -1;
		state = player_state_jump;
	}
	
	//Land the dropdash
	if(ground)
	{
		//Dropdash speeds
		var dashspeed = 8.0;
        var maxspeed = 12.0;
		if (super) {
			dashspeed = 12.0;
			maxspeed = 13.0;	
		}
		
		if (facing == -1) {
            if(x_speed <= 0.0)
                ground_speed = max(-maxspeed, -dashspeed + (ground_speed / 4.0));
            else if (ground_angle != 0)
                ground_speed = -dashspeed + (ground_speed / 2.0);
            else
                ground_speed = -dashspeed;
        }
        else{
            if (x_speed >= 0.0)
                ground_speed = min(maxspeed, dashspeed + (ground_speed / 4.0));
            else if (ground_angle != 0)
                ground_speed = dashspeed + (ground_speed / 2.0);
            else
                ground_speed = dashspeed;
        }
		
		//Roll state
		state = player_state_roll;
		dropdash_timer = 0;
		if(audio_is_playing(sfx_dropdash)) audio_stop_sound(sfx_dropdash);
		if (!super){
			sound_play(sfx_release);
		} else {
			sound_play(sfx_peelout_release);	
		}
		
		//Camera lag
		obj_camera.h_lag = 8;
		
		//Create effect
		if(global.chaotix_dust_effect)
		{
			for (var i = 0; i < 8; ++i) 
			{
			     instance_create_particle(x - hitbox_w * facing, y + hitbox_h, spr_effect_dust, 0.4, depth-1, (2.5 * facing) * dcos(random_range(180, 270)), 2.5 * dsin(random_range(180, 270)));
			}
		}
		else
		{
			var o = instance_create_particle(floor(x) - hitbox_w * facing, floor(y) + hitbox_h, spr_effects_dropdash_dust, 0.4, depth-1);
			o.image_xscale = facing;
		}
	}
	
}