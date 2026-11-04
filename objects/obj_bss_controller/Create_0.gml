/// @description Blue Spheres controller
	// Stage settings, override them in the room creation code
	stage_music = MUSIC.BLUE_SPHERES;		// Background music
	ring_target = 64;						// Rings needed for the PERFECT bonus
	palette_index = 0;						// tex_pal_bss row that recolors the stage
	speedup_interval = 30 * 60;				// Frames between each speed-up
	mania_rings = false;					// Mania's scaled spinning rings instead of S3&K's
	horizon_glow = false;					// Mania's additive horizon and rim light
	
	// S3&K rules, Mania's are used otherwise
	s3k_ring_conversion = false;			// Rings spread to every blue sphere touching the loop's inside, diagonals too
	s3k_ring_conversion_fixes = false;		// Without its bugs: rings never start outside the loop, and loops across the board's edges count
	s3k_bumpers = false;					// Bounce off the nearest bumper either way, roll away backwards until up
	s3k_controls = false;					// Mid-air turns wait for landing, jumps wait for turns and come after moving
	s3k_ring_counter = false;				// The HUD counts rings collected instead of rings left
	
	// Board, read from the "Playfield" tile layer on room start
	board_width = BSS_MIN_SIZE;
	board_height = BSS_MIN_SIZE;
	board = [];								// board[x][y], cell values
	cell_types = [];						// Cell value to type, see stage_bss_cells
	cell_events = [];						// See bss_add_event
	sphere_count = 0;						// Spheres left to collect
	pink_count = 0;
	ring_count = 0;							// Rings left for the PERFECT bonus
	rings_collected = 0;
	
	// Ring conversion
	chain_marks = [];
	ring_marks = [];
	last_sphere_x = 0;
	last_sphere_y = 0;
	chain_closed = false;
	
	// Globe movement
	state = bss_state_move;
	state_timer = 0;
	player_x = 0;							// Cell under the player
	player_y = 0;
	angle = 0;								// Facing, 0x00 up, 0x40 right, 0x80 down, 0xC0 left
	cell_progress = 0;						// 0-255 progress across the current cell
	move_speed = 0;
	acceleration = 0;
	top_speed = 0;							// Rises by 4 every speedup_interval, up to 32
	speedup_timer = 0;
	queued_turn = 0;						// Turn waiting for the next cell edge, -1 left, 1 right
	turn_dir = 0;
	bumped_back = false;					// Rolling backwards off a bumper until up is held
	disable_bumpers = false;
	bumper_hit = false;						// S3&K bumpers: pushed back against move_speed to a cell center
	bumper_x = 0;
	bumper_y = 0;
	teleport_wait = 0;
	teleport_flash = 0;
	
	// Globe visuals
	center_x = WINDOW_WIDTH div 2;
	checker_parity = 0;						// Flips every cell, picks the checkerboard colors
	roll_frame = 0;
	globe_hidden = false;					// The turn animation replaces the globe
	turn_frame = 0;
	turn_flip = 0;
	bg_scroll_x = 0;
	bg_scroll_y = 0;
	
	// Results
	exit_timer = 0;
	reward_is_emerald = false;
	emerald_index = 0;
	stage_failed = false;
	
	// Player
	on_ground = true;
	jump_speed = 0;
	jump_y = 0;								// 16.16 fixed point, negative is up
	jump_queued = false;
	walk_timer = 0;
	roll_timer = 0;
	input_disable = false;					// Flag used for disabling player input
	hold_up = false;
	hold_left = false;
	hold_right = false;
	press_action = false;
	character = -1;							// Character the animators were built for, see bss_setup_character
	animator = undefined;
	tail_animator = undefined;
	has_tail = false;
	
	// GET BLUE SPHERES message
	intro_phase = 0;						// 0 fade in, 1 wait, 2 slide out, 3 gone
	intro_fade = 512;
	intro_wait = 0;
	intro_offset = 0;
	
	// PERFECT message
	perfect_active = false;
	perfect_phase = 0;						// 0 slide in, 1 hold, 2 slide out
	perfect_offset = 320;
	perfect_wait = 0;
	
	// Prop animations
	ring_phase = 0;
	ring_phase_timer = 0;
	spark_phase = 0;
	spark_phase_timer = 0;
	ring_spin = 0;
	medal_spin = 0;
	
	// Done here so the room creation code can override cell types
	bss_init();
	bss_cells_init();
	bss_setup_character();
