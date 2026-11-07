// TODO THIS SHIT
#macro MUSIC_CHANNEL_SIZE 4
#macro BGM 0
#macro Jingle MUSIC_CHANNEL_SIZE - 1
	
/// @self								obj_global
/// @description						Function that initializes the music system
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

/// @self								obj_global
/// @description						Function that updates the music system
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

/// @self								obj_global
/// @description						Function that adds music to a list
/// @param {Real|String} music_id		A key where the music will be registered in the map		
/// @param {Asset.GMSound} sound_id		The music sound asset ID
/// @param {Real} [loop_start]			Music's loop start value (in ms | the default is 0.00ms)
/// @param {Real} [loop_end]			Music's loop end value (in ms | the default is 0.00ms, which means it's disabled)
/// @param {Bool} [loop]				Flag for music looping (By default it's on)
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

/// @self								
/// @description						Function that changes the fading mode of a music channel
/// @param {Real} channel				Value for a music channel
/// @param {Real} fade_type				Which fade type is it
/// @param {Real} fade_speed			Speed of the music channel fading
function music_fade_channel(channel, fade_type, fade_speed)
{
	obj_global.music.fade_speed[channel] = fade_speed;
	obj_global.music.fade_type[channel] = fade_type;	
}

/// @self								
/// @description						Function that fades in the target channel and fades out the rest
/// @param {Real} target_channel		Which channel is going to fade in
/// @param {Real} fade_speed			Speed of the music channel fading
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

/// @self								
/// @description						Function that changes the fading mode of a music master gain
/// @param {Real} fade_type				Which fade type is it
/// @param {Real} fade_speed			Speed of the music fading
function music_set_fade(fade_type, fade_speed)
{
	obj_global.music.general_fade_speed = fade_speed;
	obj_global.music.general_fade = fade_type;	
}

/// @self								
/// @description						Function that resets the master fade
function music_reset_fade()
{
	music_set_fade(FADE.IN, 1);
	obj_global.music.general_fade_multiplier = 1;
}

/// @self								
/// @description						Function that plays music on a set channel
/// @param {Real} music_id				Key or ID of a music that will get played from the list
/// @param {Real} [channel]				On which channel music will be played at (The default is the first channel)
function music_play(music_id, channel = 0)
{
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

/// @self								
/// @description						Function that plays music on a set channel and cancels out the other channels
/// @param {Real} music_id				Key or ID of a music that will get played from the list
/// @param {Real} [channel]				On which channel music will be played at (The default is the first channel)
function music_play_priority(music_id, channel = 0)
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

/// @self								
/// @description						Function that pauses a music channel
/// @param {Real} [channel]				Which channel will get paused(The default is the first channel)
function music_pause(channel = 0)
{
	with(obj_global) 
	{
		if (music.playing[channel] != noone && audio_is_playing(music.playing[channel])) 
			audio_pause_sound(music.playing[channel]);
	}
}

/// @self								
/// @description						Function that resumes a music channel
/// @param {Real} [channel]				Which channel will be resumed(The default is the first channel)
function music_resume(channel = 0)
{
	with(obj_global) 
	{
		if (music.playing[channel] != noone && audio_is_paused(music.playing[channel])) 
			audio_resume_sound(music.playing[channel]);
	}
}

/// @self								
/// @description						Function that changes the pitch of a music channel
/// @param {Real} [channel]				The channel that will get affected
function music_set_pitch(channel = 0, pitch = 1)
{
	with(obj_global) if (music.playing[channel] != noone) audio_sound_pitch(music.playing[channel], pitch);
}

/// @self								
/// @description						Function that plays the extra life jingle
function music_play_jingle()
{
	if (global.extra_life_jingle)
	{ 
		sound_play(j_extra_life);
	} 
	else
	{
		sound_play(sfx_extralife);
	}	
}

/// @self								
/// @description						Function that will stop the jingle channel and return to normal channel
/// @param {Bool} fade_music_in			Is the music going to fade back in?
/// @param {Real} [fade_speed]			How fast will music fade back in (The default is 1)
function music_stop_jingle(fade_music_in, fade_speed = 1)
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