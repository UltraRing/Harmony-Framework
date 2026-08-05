/// @description Script
	timer++;

	var actionPress = input_press(INPUT.A) || input_press(INPUT.B) || input_press(INPUT.C);

	//Size up the bonuses
	if (timer == 1 && state == 0)
	{
		ring_bonus = rings * 100;
		perfect_bonus = perfect ? 50000 : 0;
		got_all = (result == SS_RESULT.GOT_EMERALD) && game_has_all_emeralds();
	}

	//Play act clear music
	if (timer == 30 && state == 0)
	{
		music_reset_fade();
		music_play(MUSIC.ACT_CLEAR, 0);
	}

	//Move in card stuff
	if (state == 0)
	{
		if (timer >= 24) offset_x[0] = max(offset_x[0] - 12, 0);
		if (timer >= 32) offset_x[1] = max(offset_x[1] - 12, 0);
		if (timer >= 40) offset_x[2] = max(offset_x[2] - 12, 0);
		if (timer >= 48) offset_x[3] = max(offset_x[3] - 12, 0);
		if (timer >= 56) offset_x[4] = max(offset_x[4] - 12, 0);
	}

	//Subtract from the count
	if (timer > 450 && state == 0)
	{
		//Skip the count down
		if (actionPress)
		{
			global.score += ring_bonus + perfect_bonus;
			ring_bonus = 0;
			perfect_bonus = 0;
		}
		else
		{
			//Subtract ring bonus
			if (ring_bonus > 0)
			{
				ring_bonus -= 100;
				global.score += 100;
			}
			
			//Subtract perfect bonus
			if (perfect_bonus > 0)
			{
				perfect_bonus -= 100;
				global.score += 100;
			}
		}

		if (FRAME_TIMER mod 4 == 0 && (ring_bonus > 0 || perfect_bonus > 0))
			sound_play(sfx_scoreadd);

		//No more count down, switch to ending events
		if (ring_bonus == 0 && perfect_bonus == 0)
		{
			sound_play(sfx_scoretally);
			timer = 0;
			if (got_all) super_shown = true;
			state = 1;
		}
		
		//Extra life with score
		if(global.score >= global.score_extralife)
		{
			global.score_extralife += 50000;
			global.life += 1;
			music_play_jingle();
		}
		if(global.score <= global.score_extralife-100000)
		{
			global.score_extralife -= 50000;

		}
	}

	//GOT THEM ALL!: scroll the heading out, slide the super message in
	if (state == 2)
	{
		if (timer == 1) sound_play(sfx_event);
		heading_off -= 16;
		if (timer > 16) super_off = max(super_off - 16, 0);
		if (timer > 8 && !audio_is_playing(sfx_event)) end_wait++;
		if (end_wait >= 60) { state = 1; timer = 80; }
	}

	//Stop executing if extra life jingle is playing
	if (state == 1 && audio_is_playing(j_extra_life) && timer >= 78)
		timer = 78;

	//Ending
	if (state == 1)
	{
		if (timer == 79 && super_shown) { state = 2; timer = 0; }
		if (timer == 80) fade_change(FADE.OUT, 5, FADE_COLOR.BLACK);
		if (timer == 110) room_goto(global.previous_room);
	}
