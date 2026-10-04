	//Get input
	var press_x = input_press(INPUT.RIGHT) - input_press(INPUT.LEFT);
	var press_y = input_press(INPUT.DOWN) - input_press(INPUT.UP);
	
	//Get zone array size
	var zone_arr = array_length(zone_list);
	
	//Noises
	if((press_x != 0 || press_y != 0) && !input_disable) sound_play(sfx_beep);
	
	//Select zones
	if(!input_disable) zone_sel += press_y;
	
	//Mod
	zone_sel %= zone_arr + 1;
		
	//Wrap
	if(zone_sel < 0) zone_sel = zone_arr;
		
	//Select acts
	if(zone_sel != zone_arr && zone_sel != -1)
	{
		//Get act array size
		var act_arr = array_length(zone_list[zone_sel]) - 1;
		
		//Select act
		if(!input_disable) act_sel += press_x;
		
		//Mod
		act_sel %= act_arr;
		
		//Wrap
		if(act_sel < 0) act_sel = act_arr - 1;
		
		//Temp
		var a, b;
		a = min(zone_sel, zone_arr);
		b = min(act_sel, act_arr - 1);
		
		//Enter the gexus
		if((input_press(INPUT.START) || input_press(INPUT.A)) && !input_disable)
		{
			var set_room = zone_list[zone_sel][act_sel+1]
			fade_to_room(set_room, 3);
			music_set_fade(FADE.OUT, 2);
			input_disable = true;
		}
	}
	
	//Sound test stuff
	if(zone_sel == zone_arr)
	{	
		var size = array_length(sound_arr);
		if(!input_disable) sound_sel += press_x;
		
		//Mod
		sound_sel %= size;
		
		//Wrap
		if(sound_sel < 0) sound_sel = size-1;
		
		//Play the sound
		if((input_press(INPUT.START) || input_press(INPUT.A)) && !input_disable)
		{
			music_play(sound_arr[sound_sel], 0);	
		}
	}