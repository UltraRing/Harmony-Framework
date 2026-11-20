/// @description Stage start
	// Runs after the room creation code, so the stage settings are in.
	bss_load_playfield();
	bss_read_start_board();
	ring_count = ring_target;
	music_play(stage_music, BGM);
	fade_in_room(3.125, FADE_COLOR.WHITE);
	global.allow_stage_restart = false;
