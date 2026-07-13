function player_inv_speed(){
	if(obj_global.music.play_data[Jingle] == "j_super" && !super) 
	{
		stop_jingle(true, 1);	
	}
	
	if(!super) 
	{
		//Subtract values
		speed_shoes = max(speed_shoes - 1, 0);
		insta_shield_invincible = max(insta_shield_invincible - 1, 0);
		if(state != player_state_knockout)
			invincible_timer = max(invincible_timer - 1, 0);
		
		//Adjust flags
		speed_shoes_flag = (speed_shoes > 0);
		if(invincible_timer == 0 && invincible) 
			invincible = false;
	
		//Stop jingles
		if(obj_global.music.play_data[Jingle] = "j_speedshoe" && speed_shoes = 0)
		{
			stop_jingle(true, 1);
		}
	
		if(obj_global.music.play_data[Jingle] = "j_invincible" && !invincible)
		{
			stop_jingle(true, 1);
		}
		
		//Invincible sparkles
		if(invincible)
		{
			if(!instance_number(obj_invincible_sparkles))
			{
				var a = instance_create_depth(x, y, depth-10, obj_invincible_sparkles);
				a.player = id;
			}
		}
		
		//return to normal color smoothly if lost super
		if (super_color > 0){
			if (FRAME_TIMER mod 4 == 0){
				super_color--
			}
		}
	} else {
		//reset stats
		speed_shoes = 0
		invincible_timer = 1
		invincible = true
		
		//super form behavior
		if (obj_global.music.play_data[Jingle] != "j_super" && transform_timer < 25) 
		{
			music_play(MUSIC.SUPER, Jingle);	
		}
		
		if(instance_exists(obj_invincible_sparkles))
			instance_destroy(obj_invincible_sparkles)
		
		//palette cycle
		if (super_color > 0){
			if (FRAME_TIMER mod 6 == 0){
				super_color++	
			}
			if (super_color >= SUPER_PALETTE_SIZE) {
				super_color = SUPER_PALETTE_LOOP
			}
		}
		
		//start palette cycle
		if (animation_is_playing(animator, ANIM.TRANSFORM) && animation_has_finished(animator)) {
			if (super_color == 0) {
				super_color++	
			}
		}
		
		//particle effects
		if (transform_timer < 25) {
			if (abs(ground_speed) >= 6) {
				if (FRAME_TIMER mod 15 == 0){
					create_effect(x,y,spr_super_sparkle_2,0.25,depth)	
				}
			}
		
			if (FRAME_TIMER mod 10 == 0){
				create_effect(x + random_range(-16,16),y + random_range(-16,16),spr_super_sparkle_1,0.5,depth -1,0,-1)	
			}
		}
		
		
		if (transform_timer == 0 && FRAME_TIMER mod 60 == 0){
			global.rings--
			
			if (global.rings <= 0){
				super = false
				speed_shoes = 0
				invincible_timer = 0
				invincible = false
				super_color = SUPER_PALETTE_LOOP
				char_animation_list();
				animator_reset(animator);	
			}
		}
		//exit conditions
		if (obj_level.disable_timer || knockout_type = K_DIE || knockout_type = K_DROWN) {
			super = false
			speed_shoes = 0
			invincible_timer = 0
			invincible = false
			super_color = SUPER_PALETTE_LOOP
			char_animation_list();
			animator_reset(animator);	
		}
	}
}

