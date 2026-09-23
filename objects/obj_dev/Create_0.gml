/// @description Values
	//Object values:
	object_list = [obj_ring, obj_monitor, obj_spring_vertical, obj_spring_horizontal, obj_spring_diagonal, obj_spikes_vertical, obj_spikes_horizontal, obj_checkpoint, obj_battery_ring, obj_solid_object, obj_signpost, obj_capsule, obj_animal, obj_player];
	object_list_length = array_length(object_list);
	object_list_length_start = object_list_length;
	object_list_metadata = []
	object_select = 0;
	debug = false;
	show_collision = false;
	show_hitbox = false;
	show_player = false;
	show_fps = false;
	show_culling = false;
	
	shell_open = false;
	store_truefps = fps_real;
	alarm[0] = 10;
	caption = window_get_caption();
	teleport_id = 0;
	
	cursor_x = WINDOW_WIDTH / 2;
	cursor_y = WINDOW_HEIGHT / 2;
	debug_use_analog = true;
	
	depth = -1000;

	// The object the mouse is nearest to
	instance_near_mouse = noone;
	
	// The object selected to be used
	instance_selected = noone;
	
	// The list of tiles being detected;
	tiles_detected = [];
	
	// How many there are
	tiles_detected_length = 0;
	
	// Setting dev_messages variable to blank
	for(var i = 0; i < 32; ++i) {
		dev_messages[i] = "";	
	}
	
	// The amount of messages currently on screen
	dev_messages_length = 0;
	
	// For the player menu shader
	graded_surf = surface_create(WINDOW_WIDTH * 2, WINDOW_HEIGHT * 2);
	
	// PLAYER DEBUG
	player_debug_values = ["character","mode","plane","facing","x","y","x_speed", "y_speed","x_dir","y_dir", "ground_speed","ground_angle","visual_angle","control_lock"]
	player_debug_length = array_length(player_debug_values);
	
	// OBJECT DEBUG
	grabbed_data_anim = [0,0,0] // x, y, timer
	curr_submenu = {
		enabled : false,
		x_pos : 0,	
		y_pos : 0,
		x_scale : 0,
		y_scale : 0,
		name : "",									// Name of the object
		instance_keys : [],						// The variables from the object
		selected_instance_var : {},		// A struct of all the variables
		selected_instance_length : 0		// The length of selected variables
		}
	// Where the mouse had clicked(for scaling)
	mouse_clicked_pos_x = 0
	mouse_clicked_pos_y = 0