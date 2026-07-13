function fade_init()
{
	fade = {
		reset : true,
		spd : 1,
		timer : 512,
		type : FADE.IN,
		target_room : noone,
		color_type : false,
		buffer : 0,
	}
}

function fade_update()
{
	//Fade to room
	if(fade.target_room != noone && fade.timer == 0 && fade.buffer == 0)
	{
		//Switch the rooms
		room_goto(fade.target_room);
			
		//Reset room fade
		fade.target_room = noone;	
	}
	
	//Reset the flag
	fade.reset = true;
	
	//Add fade timer depending on the type
	fade.timer += (fade.spd * (512 / 100)) * fade.type;
	
	//Limit the fade
	fade.timer = clamp(fade.timer, 0, 512);
	
	if(fade.timer == 0) 
	{
		fade.buffer--
		fade.buffer = clamp(fade.buffer, 0, 512);	
	}
	
	show_debug_message(fade.buffer)
}

function fade_draw()
{
	//Screen values
	var r, g, b;
	
	// Fade color offset
	if(fade.color_type)
	{
		r = fade.timer - 256;
		g = fade.timer - 128;
	    b = fade.timer;
	}
	else
	{
		r = fade.timer - 256;
		g = fade.timer - 128;
	    b = fade.timer;
	}
	
	r = clamp(r, 0, 255);
	g = clamp(g, 0, 255);
	b = clamp(b, 0, 255);
	
	r ^= 0xFF;
    g ^= 0xFF;
	b ^= 0xFF;
	
	//Color the fade
	var color = make_color_rgb(r, g, b);
	
	//Draw the fade
	if(fade.color_type)
		gpu_set_blendmode(bm_add);
	else
		gpu_set_blendmode(bm_subtract);
	
	draw_set_color(color);
	draw_rectangle(CAMERA_VIEW_X, CAMERA_VIEW_Y, CAMERA_VIEW_X + CAMERA_VIEW_W, CAMERA_VIEW_Y + CAMERA_VIEW_H, false);
	draw_set_color(c_white)
	gpu_set_blendmode(bm_normal);
}

function fade_to_room(room_target, fade_speed, fade_color = FADE.BLACK, fade_buffer = 0)
{
	//Get the object
	var fade = obj_global.fade;
	
	//Set room target
	fade.target_room = room_target;
	
	//Set fade speed
	fade.spd = fade_speed;
	fade.buffer = fade_buffer;
	
	//Set to correct fade mode
	fade.type = FADE.OUT;
	
	//Change the fade color
	fade.color_type = fade_color;
}

function fade_to_room_next(fade_speed, fade_color = FADE.BLACK, fade_buffer = 0)
{
	//Get the object
	var fade = obj_global.fade;
	
	//Set room target
	fade.target_room = room_next(room);
	
	//Set fade speed
	fade.spd = fade_speed;
	fade.buffer = fade_buffer;
	
	//Set to correct fade mode
	fade.type = FADE.OUT;
	
	//Change the fade color
	fade.color_type = fade_color;
}

function fade_in_room(fade_speed, fade_color = FADE.BLACK, fade_buffer = 0)
{
	//Get the object
	var fade = obj_global.fade;
	
	//Prevent shit from fucking up lmao
	fade.reset = false;
	
	//Set fade to black
	fade.timer = 0;
	
	//Set fade speed
	fade.spd = fade_speed;
	fade.buffer = fade_buffer;
	
	//Set to correct fade mode
	fade.type = FADE.IN;
	
	//Change the fade color
	fade.color_type = fade_color;
}

function fade_change(fade_mode, fade_speed, fade_color = FADE.BLACK, fade_buffer = 0)
{
	//Get the object
	var fade = obj_global.fade;
	
	//Set fade speed
	fade.spd = fade_speed;
	fade.buffer = fade_buffer;
	
	//Set to correct fade mode
	fade.type = fade_mode;
	
	//Change the fade color
	fade.color_type = fade_color;
}
