/// @description Hurt player

	//Get the center of the hitbox
	var center_x = bbox_left + (bbox_right - bbox_left) / 2;
	var col = player_act_solid();
	
	//Hurt the player
	if(col == (sign(image_xscale) == 1 ? COLLISION.LEFT : COLLISION.RIGHT))
	{
		var player = player_find(0)
		if(player.invincible_timer == 0 && player.insta_shield_invincible == 0)
			sound_play(sfx_hurt_spike);
			
		player_hurt(center_x);
	}