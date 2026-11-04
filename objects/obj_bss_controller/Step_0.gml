/// @description Blue Spheres update
	// The dev menu can switch characters mid-stage
	if(character != global.character) bss_setup_character();
	if(!global.process_objects) exit;
	
	// The order matters: the intro can start the globe before the state runs,
	// and S3&K jumps after the globe moves while Mania jumps before
	bss_get_input();
	if(!s3k_controls) bss_player_jump();
	bss_player_animate();
	bss_intro_update();
	script_execute(state);
	if(s3k_controls) bss_player_jump();
	bss_cell_events_update();
	bss_props_update();
	bss_banners_update();
	
	// Music speeds up 1.05x per speed-up
	music_set_pitch(BGM, power(1.05, (max(top_speed, 16) - 16) / 4));
