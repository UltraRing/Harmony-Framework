/// @description Inherited drawing

	// You can show and hide elements based on certain factors - here is an example:
	// THIS NEEDS TO BE ABOVE INHERITED EVENT!
	/*
	if(condition == true) {
		background.bg_layers[0].visibility = false;
	}
	else {
		background.bg_layers[0].visibility = true;
	}
	*/

	// Inherit the parent event
	event_inherited();

	//Water scale
	with (background.bg_layers[water_layer])
    {
    	if(instance_exists(obj_water))
        {
            var a = floor(camera_get_view_y(view_camera[view_current])*factor_y + offset_y); //"3" is the index of the water's parallax
            bg_scale = floor(obj_water.y - a) * (1 / 96); //"96" is the water parallax sprite's height
            bg_scale = clamp(bg_scale, -1, 1);
        }
    }