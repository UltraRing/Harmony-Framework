#macro MUSIC_CHANNEL_SIZE 4

function music_init()
{
	music = 
	{
		playing : noone,
		play_data : noone,
		fade_multiplier : noone,
		fade_speed : noone,
		fade_type : noone,
		loop_start : noone,
		loop_end : noone,
		general_fade : FADE.IN,
		general_fade_speed : 1,
		general_fade_multiplier : 1
	}
	
	music.playing = array_create(MUSIC_CHANNEL_SIZE, noone);
	music.play_data = array_create(MUSIC_CHANNEL_SIZE, "");
	music.fade_multiplier = array_create(MUSIC_CHANNEL_SIZE, 1);
	music.fade_speed = array_create(MUSIC_CHANNEL_SIZE, 1);
	music.fade_type = array_create(MUSIC_CHANNEL_SIZE, 1);
	music.loop_start = array_create(MUSIC_CHANNEL_SIZE, 0.00);
	music.loop_end = array_create(MUSIC_CHANNEL_SIZE, 0.00);
}

function music_update()
{
	//Fade events for general fade
	var volume = music.general_fade_speed / 100;
	music.general_fade_multiplier += volume * music.general_fade;
	
	//Clamp the general fade
	music.general_fade_multiplier = clamp(music.general_fade_multiplier, 0, 1);
	
	//Apply fade and background volume to the extra life jingle
	audio_sound_gain(j_extra_life, global.bgm_volume, 0);	
	
	for(var i = 0; i < MUSIC_CHANNEL_SIZE; i++)
	{
		if(music.playing[i] != noone && audio_is_playing(music.playing[i]))
		{	
			//Set volume to the fade and background volume
			audio_sound_gain(music.playing[i], global.bgm_volume * music.fade_multiplier[i] * music.general_fade_multiplier, 0)
			
			// Music looping
			audio_sound_loop_start(music.playing[i], music.loop_start[i]);
		
			if(music.loop_end[i] > 0)
				audio_sound_loop_end(music.playing[i], music.loop_end[i]);
			
			//Offset the fade
			volume = music.fade_speed[i] / 100;
			music.fade_multiplier[i] += volume * music.fade_type[i];
		
			//Clamp fade offset
			music.fade_multiplier[i] = clamp(music.fade_multiplier[i], 0, 1);
			
			//Resume the channels
			if(!instance_exists(obj_pause)) 
			{
				audio_resume_sound(music.playing[i]);
			}
		
			//Pause BGM when jingle is playing
			if(music.playing[Jingle] != noone)
				audio_pause_sound(music.playing[BGM]);
				
			if(instance_exists(obj_player))
			{
				//Drowning jingle
				if(audio_is_playing(j_drowning) || obj_player.air > 20*60)
				{
					if(music.playing[i] != noone && i != MUSIC_CHANNEL_SIZE)
					{
						audio_pause_sound(music.playing[i]);
					}
				
					if(music.playing[Jingle] != noone)
					{
						audio_sound_gain(music.playing[Jingle], 0, 0);
					}
			
					audio_sound_gain(j_drowning, global.bgm_volume, 0);
				}
	
				//Handle extra life jingle
				if(audio_is_playing(j_extra_life))
				{
					if(music.playing[i] != noone && i != MUSIC_CHANNEL_SIZE)
					{
						audio_pause_sound(music.playing[i]);
					}
				
					if(music.playing[Jingle] != noone)
					{
						audio_sound_gain(music.playing[Jingle], 0, 0);
					}
			
					audio_sound_gain(j_drowning, 0, 0);
				
					music.general_fade_multiplier = 0;
					music.general_fade_speed = 2;
				}
			}
		}	
	}
}

function music_add(music_id, sound_id, loop_start = 0.00, loop_end = 0.00, loop = true)
{
	if !ds_map_exists(global.music_map, music_id)
	{
		ds_map_add(global.music_map, music_id, array_create(4))	
		global.music_map[? music_id][0] = sound_id
		global.music_map[? music_id][1] = loop_start
		global.music_map[? music_id][2] = loop_end
		global.music_map[? music_id][3] = loop
	} 
}

function music_fade_channel(channel, fade_type, fade_speed)
{
	obj_global.music.fade_speed[channel] = fade_speed;
	obj_global.music.fade_type[channel] = fade_type;	
}

function music_cross_fade(target_channel, fade_speed)
{
	for (var i = 0; i < MUSIC_CHANNEL_SIZE; ++i) 
	{
		if(target_channel != i)
		{
			obj_global.music.fade_speed[target_channel] = fade_speed;
			obj_global.music.fade_type[i] = FADE.OUT;
		}
	}
	
	obj_global.music.fade_speed[target_channel] = fade_speed;
	obj_global.music.fade_type[target_channel] = FADE.IN;	
}

function music_set_fade(fade_type, fade_speed)
{
	obj_global.music.general_fade_speed = fade_speed;
	obj_global.music.general_fade = fade_type;	
}

function music_reset_fade()
{
	music_set_fade(FADE.IN, 1);
	obj_global.music.general_fade_multiplier = 1;
}

function music_play(music_id, channel = 0)
{
	//Music macros
	#macro BGM 0
	#macro Jingle MUSIC_CHANNEL_SIZE - 1
	
	//Get the sound object
	with(obj_global)
	{
		//Stop everything before BGM plays.
		audio_stop_sound(music.playing[channel]);
		
		//Stop jingle
		audio_stop_sound(music.playing[Jingle]);
		
		//Restore jingle channel value
		music.playing[Jingle] = noone;
		
		//Set the loop points
		music.loop_start[channel] = global.music_map[? music_id][1];
		music.loop_end[channel] = global.music_map[? music_id][2];
		
		// Channel volume
		var vol = global.bgm_volume * music.fade_multiplier[channel] * music.general_fade_multiplier;
		
		//Play the sound
		music.play_data[channel] = audio_get_name(global.music_map[? music_id][0]);
		music.playing[channel] = audio_play_sound(global.music_map[? music_id][0], 0, global.music_map[? music_id][3], vol);
	}
}

function music_play_priority(music_id, channel)
{
	for (var i = 0; i < MUSIC_CHANNEL_SIZE; ++i) 
	{
		if(channel != i)
		{
			obj_global.music.fade_multiplier[i] = 0;	
			obj_global.music.fade_type[i] = FADE.OUT;
		}
	}
	
	music_play(music_id, channel);
}

function music_pause(channel = 0)
{
	with(obj_global) if (music.playing[channel] != noone) audio_pause_sound(music.playing[channel]);
}

function music_resume(channel = 0)
{
	with(obj_global) if (music.playing[channel] != noone) audio_resume_sound(music.playing[channel]);
}

function music_set_pitch(channel = 0, pitch = 1)
{
	with(obj_global) if (music.playing[channel] != noone) audio_sound_pitch(music.playing[channel], pitch);
}

function music_play_jingle()
{
	if (global.extra_life_jingle)
	{ 
		play_sound(j_extra_life)
	} 
	else
	{
		play_sound(sfx_extralife)
	}	
}

function stop_jingle(fade_music_in, fade_speed = 1)
{
	with(obj_global)
	{
		if(music.playing[Jingle] && music.general_fade_multiplier == 1)
		{
			//Fade into BGM (optional)
			if(fade_music_in = true)
			{
				music.general_fade = FADE.IN;
				music.general_fade_speed = fade_speed;
				music.general_fade_multiplier = 0;
			}
	
			//Stop the jingle here
			audio_stop_sound(music.playing[Jingle]);
			music.playing[Jingle] = noone;
			music.play_data[Jingle] = "";
		}
	}
}