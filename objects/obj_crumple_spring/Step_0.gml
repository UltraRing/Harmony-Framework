/// @description Script
	var c = noone;
	
	if(collision_flag)
		c = player_act_semi_solid();
	
	
	
	//Update the animator
	if (!crumple) {
		animator_update(animator);
	
		//Hit from the bottom
		if(c && obj_player.y_speed >= 0 && collision_flag)
		{
			//Spring code
			animator.animation_finished = false;
			triggered = true;
			sound_play(sfx_spring);
			
			//Player stuff
			var player = instance_nearest(x, y, obj_player)
			with(player)
			{
				animation_play(animator, ANIM.SPRING);
				state = player_state_spring;
				y_speed = -other.spring_power;
				ground = false;
			}
		}
		
		//Stop the animation
		if(!triggered) 
		{
			animation_set_frame(animator, 0);
		}
	
		//Reset the trigger
		if(animation_has_finished(animator) && triggered && !crumple) 
		{
			triggered = false;
			crumple = true
			sound_play(sfx_break)
		}
	}
	
	if (crumple) {
		if (!instance_on_screen()){
			collision_flag = false	
			visible = false
			fall_speed = 0
		}
		y += fall_speed
		fall_speed += 0.21
	}
	