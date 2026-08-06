/// @description Surface resize
	//Screen resizing
	camera_set_view_size(view_camera[view_current], global.window_width, global.window_height);

	//Resize the surface:
	surface_resize(application_surface, global.window_width, global.window_height);
	
	// Reset the fade system if needed
	if(fade.reset)
		fade_init();
	