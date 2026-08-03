// Should be moved
#macro GAMEPAD_AXIS_DEADZONE 0.5

enum INPUT
{
	UP,
	DOWN,
	LEFT,
	RIGHT,
	A,
	B,
	C,
	START
}

/// @self									obj_global
/// @description							Function used for initializing the input system
function input_init()
{
	input_data_hold = [];
	input_data_press = [];
	input_data_release = [];
	
	input_data_keyboard = [];
	input_data_controller = [];
	input_data_controller_axis = [[]];
	
	input_controller_id = 0;
	using_controller = false;
}

/// @self									obj_global
/// @description							Function used for updating the input system
function input_update()
{
	var size = array_length(input_data_keyboard);
	
	for (var i = 0; i < size; ++i) 
	{
		// Get the previous input data
		var prev_input = input_data_hold[i];
		
		// Get the axis flip flag and set it's conditions
		var axisFlip = input_data_controller_axis[i][1];
		var axisCondition = axisFlip ? (gamepad_axis_value(input_controller_id, input_data_controller_axis[i][0]) < -GAMEPAD_AXIS_DEADZONE) : (gamepad_axis_value(input_controller_id, input_data_controller_axis[i][0]) > GAMEPAD_AXIS_DEADZONE);
		
		// Is the input coming keyboard?
		var isKeyboard = keyboard_check(input_data_keyboard[i]);
		
		// Is the input coming from the controller
		var isController = axisCondition ||  gamepad_button_check(input_controller_id, input_data_controller[i]);
		
		// Decide if gamepad is currently being used or not
		if(isKeyboard)
			using_controller = false;
		else if(isController)
			using_controller = true;
		
		// Update the input data
	    input_data_hold[i] = isKeyboard || isController;
		
		// Get the difference of current and previous input state
		var input_state = input_data_hold[i] - prev_input;
		
		// Press and release inputs
		input_data_press[i] = input_state > 0;
		input_data_release[i] = input_state < 0;

	}
}

/// @self									obj_global
/// @description							Function used for adding a new input action
/// @param {Real} input_id					The input ID that is going to get assigned to
/// @param {String|Real} keyboard_action	The keyboard key that is going to be used for the action
/// @param {Real} controller_action			The controller key that is going to be used for the action
/// @param {Array} [controller_axis]		The controller's analog action (Optional) [0: Axis direction, 1: Is negative]
function input_add_action(input_id, keyboard_action, controller_action, controller_axis = [noone, false])
{
	// Convert it
	if(is_string(keyboard_action))
		keyboard_action = ord(keyboard_action);
	
	input_data_keyboard[input_id] = keyboard_action;
	input_data_controller[input_id] = controller_action;
	input_data_controller_axis[input_id][0] = controller_axis[0];
	input_data_controller_axis[input_id][1] = controller_axis[1];		// If axis should be flipped
	
	// Make sure this array index exists
	input_data_hold[input_id] = false;
	input_data_press[input_id] = false;
	input_data_release[input_id] = false;
}

/// @self									
/// @description							Function that returns if the input key is being held
/// @param {Real} input_id					The input ID that is currently being held
/// @returns {Bool}
function input_hold(input_id)
{
	return obj_global.input_data_hold[input_id];	
}

/// @self									
/// @description							Function that returns if the input key is being pressed
/// @param {Real} input_id					The input ID that is currently being pressed
/// @returns {Bool}
function input_press(input_id)
{
	return obj_global.input_data_press[input_id];	
}

/// @self									
/// @description							Function that returns if the input key is being released
/// @param {Real} input_id					The input ID that is currently being released
/// @returns {Bool}
function input_release(input_id)
{
	return obj_global.input_data_release[input_id];	
}
