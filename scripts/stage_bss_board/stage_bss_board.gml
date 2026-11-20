// Blue Spheres board: cell access, movement across cells, touching cells and cell events

/// @self								obj_bss_controller
/// @description						Creates an empty board_width x board_height board
function bss_board_create()
{
	var _board = array_create(board_width);
	for (var gx = 0; gx < board_width; gx++)
		_board[gx] = array_create(board_height, BSS_CELL.NONE);
	return _board;
}

// The board wraps around like a globe
function bss_wrap_x(_x)
{
	return ((_x mod board_width) + board_width) mod board_width;
}

function bss_wrap_y(_y)
{
	return ((_y mod board_height) + board_height) mod board_height;
}

/// @self								obj_bss_controller
/// @description						Returns the cell at (_x, _y), wrapped around the board
/// @param {Real} _x					Cell x
/// @param {Real} _y					Cell y
/// @returns {Real}
function bss_cell_get(_x, _y)
{
	return board[bss_wrap_x(_x)][bss_wrap_y(_y)];
}

/// @self								obj_bss_controller
/// @description						Changes the cell at (_x, _y), wrapped around the board
/// @param {Real} _x					Cell x
/// @param {Real} _y					Cell y
/// @param {Real} _cell					New cell value
function bss_cell_set(_x, _y, _cell)
{
	board[bss_wrap_x(_x)][bss_wrap_y(_y)] = _cell;
}

/// @self								obj_bss_controller
/// @description						Returns the x of the cell _dist cells in front of the player, negative is behind
/// @param {Real} _dist					Cells ahead
/// @returns {Real}
function bss_ahead_x(_dist)
{
	return bss_wrap_x(player_x + _dist * (sin256(angle) >> 8));
}

/// @self								obj_bss_controller
/// @description						Returns the y of the cell _dist cells in front of the player, negative is behind
/// @param {Real} _dist					Cells ahead
/// @returns {Real}
function bss_ahead_y(_dist)
{
	return bss_wrap_y(player_y - _dist * (cos256(angle) >> 8));
}

/// @self								obj_bss_controller
/// @description						Moves the player one cell forward (1) or back (-1)
/// @param {Real} _dir					1 or -1
function bss_advance(_dir)
{
	checker_parity ^= 1;
	player_x = bss_ahead_x(_dir);
	player_y = bss_ahead_y(_dir);
}

/// @self								obj_bss_controller
/// @description						Moves across cell edges while the globe can't turn
function bss_wrap_progress()
{
	if(move_speed <= 0 && cell_progress < 0)
	{
		cell_progress += 256;
		bss_advance(-1);
	}
	else if(cell_progress >= 256)
	{
		cell_progress -= 256;
		bss_advance(1);
	}
	roll_frame = (cell_progress >> 4) & 15;
}

// S3&K's check for being on a cell center: within 32 units of it, on the side its axis counts up toward
function _bss_on_center_s3k()
{
	var _sub = (angle == 0x40 || angle == 0x80) ? cell_progress : 256 - cell_progress;
	return ((_sub & 255) & 0xE0) == 0;
}

// S3&K rounds the position to the nearest cell. Exactly halfway goes to the side its axis counts up toward
function _bss_ahead_is_nearest_s3k()
{
	return (angle == 0x40 || angle == 0x80) ? (cell_progress >= 128) : (cell_progress > 128);
}

/// @self								obj_bss_controller
/// @description						Runs the touch function of the cell under the player, then of the cell ahead
function bss_touch_cells() //BSS_Setup_HandleSteppedObjects
{
	if(cell_progress < 32 || cell_progress > 224) disable_bumpers = false;
	
	_bss_touch(player_x, player_y, false);
	_bss_touch(bss_ahead_x(1), bss_ahead_y(1), true);
}

function _bss_touch(_x, _y, _ahead)
{
	var _touch = bss_cell_type(board[_x][_y]).touch;
	if(_touch != undefined) _touch(_x, _y, _ahead);
}

/// @self								obj_bss_controller
/// @description						Runs a function every frame for a cell until it returns true
/// @param {Real} _x					Cell x
/// @param {Real} _y					Cell y
/// @param {Function} _update			function(event), the event holds gx, gy, timer and phase
function bss_add_event(_x, _y, _update)
{
	array_push(cell_events, { gx : _x, gy : _y, timer : 0, phase : 0, update : _update });
}

function bss_cell_events_update() //BSS_Collected_Update
{
	for (var i = array_length(cell_events) - 1; i >= 0; i--)
	{
		var _event = cell_events[i];
		var _update = _event.update;
		if(_update(_event)) array_delete(cell_events, i, 1);
	}
}
