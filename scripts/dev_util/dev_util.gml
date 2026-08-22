/// @self								obj_dev_menu
/// @description						Function used for adding a character entry to the dev menu
/// @param {String} character_name		Name of the character
function dev_menu_add_character(character_name)
{
	char_name[character_id] = character_name;
	character_id++;
}

/// @self								obj_dev_menu
/// @description						Function used for adding a category to the dev menu
/// @param {String} name				Name of the category
function dev_menu_add_category(name)
{
	scene_id = 0;
	category_name[category_id] = name;
	category_id++;
}

/// @self								obj_dev_menu
/// @description						Function used for adding a room entry to the dev menu
/// @param {String} name				Name of the room
/// @param {Asset.GMRoom} room_id		The room asset
function dev_menu_add_entry(name, room_id)
{
	scene_name[category_id][scene_id] = name;
	scene_room[category_id][scene_id] = room_id;
	scene_id++;
}

/// @self								obj_dev_menu
/// @description						Function used for adding an option entry (Only for global values)
/// @param {String} name				Name of the option
/// @param {String} variable			Name of the global variable
/// @param {Real} minimum				Minimum value
/// @param {Real} maximum				Maximum value
/// @param {Real} number				The amount of steps to change the option
function dev_menu_add_option_number(name, variable, minimum, maxium, number = 1.0)
{
	option_name[option_id] = name;
	option_variable[option_id] = variable;
	option_number[option_id] = number
	option_min[option_id] = minimum;
	option_max[option_id] = maxium;
	option_flag[option_id] = false;
	option_id++;
}

/// @self								obj_dev_menu
/// @description						Function used for adding an option entry (Flag options | Only for global values)
/// @param {String} name				Name of the option
/// @param {String} variable			Name of the global variable
function dev_menu_add_option_flag(name, variable)
{
	option_name[option_id] = name;
	option_variable[option_id] = variable;
	option_flag[option_id] = true;
	option_id++;
}

/// @self								obj_dev_menu
/// @description						Function used for showing dev messages in-game
/// @param {Real} variable			Variable data
/// @param {Real} dev_id			Specific row to change(-1 for automatic | Max 31)
function show_dev_message(variable, dev_id = -1) {
	if(dev_id == -1) { 
		array_push(obj_dev.dev_messages, string(variable));
		obj_dev.dev_messages_length = max(obj_dev.dev_messages_length+1, 32);
	}
	else{
		obj_dev.dev_messages[dev_id] = variable;
	}
}