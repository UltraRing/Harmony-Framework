/// @description Values
	timer = 0;
	state = 0;

	//Results
	result = SS_RESULT.FAILED;
	got_all = false;
	perfect = false;
	rings = 0;

	ring_bonus = 0;
	perfect_bonus = 0;

	//Staggered slide-in offsets: heading, emerald row, ring, perfect, total
	for (var i = 0; i <= 4; i++)
		offset_x[i] = global.window_width;
	
	offset_x[1] = 0;

	//GOT THEM ALL!/SUPER reveal
	super_shown = false;
	heading_off = 0;
	super_off = global.window_width;
	end_wait = 0;

	//Take the white screen over
	obj_global.fade.timer = 512;
	obj_global.fade.type  = FADE.IN;
	obj_global.fade.target_room = noone;
