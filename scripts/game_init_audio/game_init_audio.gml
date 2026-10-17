function game_init_audio()
{
	game_init_music_list();
	
	// Initilize emitters and buses
	sfx_emitter = audio_emitter_create();
	sfx_bus = audio_bus_create();
	audio_falloff_set_model(audio_falloff_linear_distance);
	audio_emitter_bus(sfx_emitter, sfx_bus);
	
	global.ring_pan = -1
	global.audio_ring_left = noone
	global.audio_ring_right = noone
}