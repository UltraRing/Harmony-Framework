/// @description Hurt player
	
	//Get the center of the hitbox
	var center_x = floor((obj_player.x + 16)/32) * 32;
	var col = player_act_solid();
	
	//Hurt the player
	if(col == (sign(image_yscale) == 1 ? COLLISION.TOP : COLLISION.BOTTOM))
	{
		var player = player_find(0)
		if(player.invincible_timer == 0 && player.insta_shield_invincible == 0)
			sound_play(sfx_hurt_spike);
		
		player_hurt(center_x);
	}