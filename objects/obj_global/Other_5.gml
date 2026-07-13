/// @description Clear and reset
	// Reset music values
	audio_stop_all();
	
	//Reset everything
	for (var i = 0; i < MUSIC_CHANNEL_SIZE; ++i) 
	{
		music.playing[i] = noone;
		music.play_data[i] = "";
		music.fade_multiplier[i] = 1;
		music.fade_speed[i] = 1;
		music.fade_type[i] = FADE.IN;
		music.loop_start[i] = 0.00;
		music.loop_end[i] = 0.00;
	}
	
	//Values for general fade
	music.general_fade = FADE.IN;
	music.general_fade_speed = 1;
	music.general_fade_multiplier = 1;