	// You can edit these values for your own blue spheres level! obj_bss_controller's Create event explains each one
	with(obj_bss_controller)
	{
		stage_music = MUSIC.BLUE_SPHERES;
		ring_target = 64;
		palette_index = 0;
		speedup_interval = 30 * 60;
		mania_rings = false;
		horizon_glow = false;
		
		// Sonic 3 & Knuckles rules instead of Mania's
		s3k_ring_conversion = false;
		s3k_ring_conversion_fixes = false;
		s3k_bumpers = false;
		s3k_controls = false;
		s3k_ring_counter = false;
	}
