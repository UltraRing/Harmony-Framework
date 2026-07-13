/// @description Script
	var actionPress = input_press(INPUT.A) || input_press(INPUT.B) || input_press(INPUT.C) || input_press(INPUT.START);
	
	//Add timer
	timer++;
	
	//Play music
	if(timer == 48)
	{
		music_reset_fade();	
		music_play(MUSIC.J_GAME_OVER, 0);
	}
	
	//Slide in the thing
	if(timer >= 48)
	{
		offset = max(offset - 12, 0);
	}
	
	//Fade out
	if(timer == 560)
	{
		fade_change(FADE.OUT, 2,FADE.BLACK)
	}
	
	//Do the skip
	if(timer >= 64 && timer < 560)
	{
		if(actionPress)
		{
			music_set_fade(FADE.OUT, 2);
			timer = 560-1;
		}
	}
	
	//Restart
	if(timer == 650)
	{
		//Game over event
		if(type = 0)
		{
			level_reset_data();
			level_reset_bg_visibility();
			game_restart();
		}else // Time over event
		{
			global.stage_timer = 0;
			room_restart();
		}
	}