/// @description Draw water 
	//Camera position
	var cx = camera_get_view_x(view_camera[view_current]);

	//Draw the water
	water_draw(cx, y, room_width, room_height - y);