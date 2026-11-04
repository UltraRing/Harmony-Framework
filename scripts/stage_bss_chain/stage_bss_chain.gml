// Blue Spheres ring conversion: collecting a blue sphere can close a loop of red spheres (collected blues).
// Every blue sphere inside that loop, and the loop itself, turns into rings.
// Mania's rules are first, S3&K's (s3k_ring_conversion) are at the bottom

/// @self								obj_bss_controller
/// @description						Checks the last collected sphere for a closed loop and converts it
/// @returns {Real}						How many blue spheres were enclosed
function bss_chain_convert() //BSS_Setup_ProcessChain
{
	for (var gx = 0; gx < board_width; gx++)
	{
		for (var gy = 0; gy < board_height; gy++)
		{
			chain_marks[gx][gy] = false;
			ring_marks[gx][gy] = false;
		}
	}
	
	// The new sphere counts as red so the walks can loop back to it
	board[last_sphere_x][last_sphere_y] = BSS_CELL.RED;
	ring_marks[last_sphere_x][last_sphere_y] = true;
	
	chain_closed = false;
	_bss_chain_walk(last_sphere_x, last_sphere_y, 0, -1);
	_bss_chain_walk(last_sphere_x, last_sphere_y, 0, 1);
	_bss_chain_walk(last_sphere_x, last_sphere_y, -1, 0);
	_bss_chain_walk(last_sphere_x, last_sphere_y, 1, 0);
	
	board[last_sphere_x][last_sphere_y] = BSS_CELL.BLUE;
	if(!chain_closed) return 0;
	
	// Count the blue spheres the loop encloses, row by row (enclosed ones get marked as they're found)
	var _enclosed = 0;
	for (var gy = 0; gy < board_height; gy++)
	{
		for (var gx = 0; gx < board_width; gx++)
		{
			if(bss_cell_kind(board[gx][gy]) == BSS_CELL.BLUE && _bss_chain_encloses(gx, gy)) _enclosed++;
		}
	}
	
	if(_enclosed <= 0)
	{
		chain_closed = false;
		return 0;
	}
	
	// Unmark loop cells with no blue sphere next to them
	for (var gx = 0; gx < board_width; gx++)
	{
		for (var gy = 0; gy < board_height; gy++)
		{
			if(ring_marks[gx][gy] && !_bss_near_blue(gx, gy)) ring_marks[gx][gy] = false;
		}
	}
	
	for (var gx = 0; gx < board_width; gx++)
	{
		for (var gy = 0; gy < board_height; gy++)
		{
			if(ring_marks[gx][gy]) board[gx][gy] = BSS_CELL.RING;
		}
	}
	
	sound_play(sfx_ringloss);
	return _enclosed;
}

/// @self								obj_bss_controller
/// @description						Follows red spheres in one direction, branching sideways (clockwise first) along the way
function _bss_chain_walk(_x, _y, _dx, _dy) //BSS_Setup_ScanSphereChain_Up/Down/Left/Right
{
	if(chain_closed) return true;
	
	var _tail = 0;
	while(true)
	{
		_x = bss_wrap_x(_x + _dx);
		_y = bss_wrap_y(_y + _dy);
		if(bss_cell_kind(board[_x][_y]) != BSS_CELL.RED || chain_marks[_x][_y] || !_bss_near_blue(_x, _y)) break;
		
		chain_marks[_x][_y] = true;
		ring_marks[_x][_y] = true;
		
		// Back at the collected sphere, the loop is closed
		if(_x == last_sphere_x && _y == last_sphere_y)
		{
			chain_closed = true;
			return true;
		}
		
		var _branched = false;
		if(bss_cell_kind(bss_cell_get(_x - _dy, _y + _dx)) == BSS_CELL.RED) _branched = _bss_chain_walk(_x, _y, -_dy, _dx) || _branched;
		if(bss_cell_kind(bss_cell_get(_x + _dy, _y - _dx)) == BSS_CELL.RED) _branched = _bss_chain_walk(_x, _y, _dy, -_dx) || _branched;
		_tail = _branched ? 0 : _tail + 1;
		
		if(chain_closed) return true;
	}
	
	// Dead end, unmark the stretch that never branched
	repeat(_tail)
	{
		_x = bss_wrap_x(_x - _dx);
		_y = bss_wrap_y(_y - _dy);
		ring_marks[_x][_y] = false;
	}
	return false;
}

// A blue sphere is enclosed when all four directions reach the loop before empty floor or a red sphere
function _bss_chain_encloses(_x, _y)
{
	if(!_bss_chain_ray(_x, _y, 0, -1, board_height)) return false;
	if(!_bss_chain_ray(_x, _y, 0, 1, board_height)) return false;
	if(!_bss_chain_ray(_x, _y, -1, 0, board_width)) return false;
	if(!_bss_chain_ray(_x, _y, 1, 0, board_width)) return false;
	
	ring_marks[_x][_y] = true;
	return true;
}

function _bss_chain_ray(_x, _y, _dx, _dy, _length)
{
	repeat(_length)
	{
		_x = bss_wrap_x(_x + _dx);
		_y = bss_wrap_y(_y + _dy);
		if(ring_marks[_x][_y]) return true;
		
		var _cell = bss_cell_kind(board[_x][_y]);
		if(_cell == BSS_CELL.NONE || _cell == BSS_CELL.RED) return false;
	}
	return true;
}

// Any blue sphere in the 8 surrounding cells
function _bss_near_blue(_x, _y)
{
	for (var _ox = -1; _ox <= 1; _ox++)
	{
		for (var _oy = -1; _oy <= 1; _oy++)
		{
			if((_ox != 0 || _oy != 0) && bss_cell_kind(bss_cell_get(_x + _ox, _y + _oy)) == BSS_CELL.BLUE) return true;
		}
	}
	return false;
}

// S3&K's rules. The Mega Drive read the board as one row-major strip: a step past the right edge lands on the next row,
// and the row/column counts stop at the board's ends, which are padded with empty floor. Both quirks are kept, and so is
// its pick of the blue sphere inside a loop, which can land outside it. s3k_ring_conversion_fixes fixes all three.
// Cells are addressed as one number here, x + y * board_width

/// @self								obj_bss_controller
/// @description						Checks the sphere just collected at (_x, _y) for a loop of red spheres and converts it
/// @param {Real} _x					Cell x
/// @param {Real} _y					Cell y
/// @returns {Real}						How many blue spheres became rings
function bss_chain_convert_s3k(_x, _y)
{
	static _around = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
	
	var _converted = _bss_find_seeds_s3k(_x + _y * board_width);
	var _count = array_length(_converted);
	if(_count == 0) return 0;
	
	// Spread through every blue sphere touching a converted one, diagonals included
	for (var i = 0; i < array_length(_converted); i++)
	{
		for (var k = 0; k < 8; k++)
		{
			var _pos = _bss_move_s3k(_converted[i], _around[k][0], _around[k][1]);
			if(bss_cell_kind(_bss_get_s3k(_pos)) == BSS_CELL.BLUE)
			{
				_bss_set_s3k(_pos, BSS_CELL.RING);
				array_push(_converted, _pos);
				_count++;
			}
		}
	}
	
	// Then every red sphere touching them
	for (var i = 0; i < array_length(_converted); i++)
	{
		for (var k = 0; k < 8; k++)
		{
			var _pos = _bss_move_s3k(_converted[i], _around[k][0], _around[k][1]);
			if(_bss_is_red_s3k(_bss_get_s3k(_pos))) _bss_set_s3k(_pos, BSS_CELL.RING);
		}
	}
	
	sound_play(sfx_ringloss);
	return _count;
}

// Walks unvisited red spheres from the collected one (trying left, straight and right at each) looking for a way back.
// Each time it gets back, the blue sphere just inside the loop becomes a ring. Returns those cells
function _bss_find_seeds_s3k(_start)
{
	static _around = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
	static _dirs = [[-1, 0], [0, -1], [1, 0], [0, 1], [-1, 0], [0, -1]];
	var _seeds = [];
	
	// Needs another blue sphere next to it. Ones still being collected turn red right away
	var _blues = 0;
	for (var k = 0; k < 8; k++)
	{
		var _pos = _bss_move_s3k(_start, _around[k][0], _around[k][1]);
		if(_bss_get_s3k(_pos) == BSS_CELL.BLUE_STOOD) _bss_set_s3k(_pos, BSS_CELL.RED);
		else if(bss_cell_kind(_bss_get_s3k(_pos)) == BSS_CELL.BLUE) _blues++;
	}
	if(_blues == 0) return _seeds;
	
	// And at least three filled cells in a row through it, both ways
	if(_bss_line_s3k(_start, 1, 0) < 4 || _bss_line_s3k(_start, 0, 1) < 4) return _seeds;
	
	var _stack = [];
	var _limit = 0;
	var _dir = 3;
	var _pos = _start;
	
	while(true)
	{
		var _next = _bss_move_s3k(_pos, _dirs[_dir][0], _dirs[_dir][1]);
		
		if(_next == _start)
		{
			if(_bss_marked_s3k(_start)) _bss_seed_inside_s3k(_pos, _stack, _seeds);
		}
		else if(_bss_is_red_s3k(_bss_get_s3k(_next)) && !_bss_marked_s3k(_next))
		{
			// Skips turning straight back beside the cell before last, so 2x2 squares don't count
			var _accepted = true;
			if(array_length(_stack) >= 2) _accepted = !_bss_touching_s3k(_next, _stack[array_length(_stack) - 2].pos);
			
			if(_accepted)
			{
				_bss_mark_s3k(_pos, true);
				array_push(_stack, { limit : _limit, dir : _dir, pos : _pos });
				_pos = _next;
				_limit = (_dir - 1) & 3;
				_dir = _limit + 2;
				continue;
			}
		}
		
		// Next direction, backing up the path when this cell has none left
		_dir--;
		while(_dir < _limit)
		{
			if(array_length(_stack) == 0) return _seeds;
			
			var _top = array_pop(_stack);
			_limit = _top.limit;
			_dir = _top.dir;
			_pos = _top.pos;
			_bss_mark_s3k(_pos, false);
			_dir--;
		}
	}
}

// Turns the blue sphere just inside a loop into a ring. _pos is the last red sphere before getting back to the start
function _bss_seed_inside_s3k(_pos, _stack, _seeds)
{
	var _path = [];
	for (var i = 0; i < array_length(_stack); i++) array_push(_path, _stack[i].pos);
	array_push(_path, _pos);
	
	var _inside = s3k_ring_conversion_fixes ? _bss_inside_turning_s3k(_path) : _bss_inside_corner_s3k(_path);
	if(bss_cell_kind(_bss_get_line_s3k(_inside)) == BSS_CELL.BLUE)
	{
		_bss_set_s3k(_inside, BSS_CELL.RING);
		array_push(_seeds, _inside);
	}
}

// The original's pick, from the path's first step, first turn and the step back into the start. Not wrapped
function _bss_inside_corner_s3k(_path)
{
	var _start = _path[0];
	var _first = _path[1] - _start;
	var _turn = _first;
	for (var i = 1; i < array_length(_path) - 1; i++)
	{
		if(_path[i + 1] - _path[i] != _first)
		{
			_turn = _path[i + 1] - _path[i];
			break;
		}
	}
	
	// The corner beside the start, or the diagonal one when the path comes back from another side
	var _inside = _start + _turn;
	var _into = _start - _path[array_length(_path) - 1];
	if(_into != _turn && _into != _first) _inside += _first;
	return _inside;
}

// Fixed: the cell beside the start on the side the loop turns toward, diagonal when the start is a corner turning that way.
// -1 when the loop goes around the globe, which encloses nothing
function _bss_inside_turning_s3k(_path)
{
	var _count = array_length(_path);
	var _steps = array_create(_count);
	for (var i = 0; i < _count; i++) _steps[i] = _bss_step_s3k(_path[(i + _count - 1) mod _count], _path[i]);
	
	var _turning = 0;
	for (var i = 0; i < _count; i++) _turning += _bss_turn_s3k(_steps[(i + _count - 1) mod _count], _steps[i]);
	if(_turning == 0) return -1;
	
	// Inwards is to the right of the path when it turns right overall
	var _side = sign(_turning);
	var _in = _steps[0];
	var _out = _steps[1];
	var _dx = -_in[1] * _side;
	var _dy = _in[0] * _side;
	if(_bss_turn_s3k(_in, _out) == _side)
	{
		_dx -= _out[1] * _side;
		_dy += _out[0] * _side;
	}
	return _bss_move_s3k(_path[0], _dx, _dy);
}

// Filled cells in a row through _start, up to 16 each way. The start counts twice, like the original
function _bss_line_s3k(_start, _dx, _dy)
{
	var _count = 0;
	for (var _way = -1; _way <= 1; _way += 2)
	{
		var _pos = _start;
		repeat(16)
		{
			_count++;
			_pos = s3k_ring_conversion_fixes ? _bss_move_s3k(_pos, _dx * _way, _dy * _way) : _pos + (_dx + _dy * board_width) * _way;
			if(_bss_get_line_s3k(_pos) == BSS_CELL.NONE) break;
		}
	}
	return _count;
}

// Only spheres that are already red, not ones still being collected
function _bss_is_red_s3k(_cell)
{
	return bss_cell_kind(_cell) == BSS_CELL.RED && _cell != BSS_CELL.BLUE_STOOD;
}

// The cell _dx, _dy away. The original adds to the cell's number, so past the right edge is the next row
function _bss_move_s3k(_pos, _dx, _dy)
{
	if(!s3k_ring_conversion_fixes)
	{
		var _size = board_width * board_height;
		return (((_pos + _dx + _dy * board_width) mod _size) + _size) mod _size;
	}
	return bss_wrap_x((_pos mod board_width) + _dx) + bss_wrap_y((_pos div board_width) + _dy) * board_width;
}

// The step from a cell to its neighbor _to, as [dx, dy]
function _bss_step_s3k(_from, _to)
{
	return [bss_wrap_x((_to mod board_width) - (_from mod board_width) + 1) - 1, bss_wrap_y((_to div board_width) - (_from div board_width) + 1) - 1];
}

// 1 when step _b turns right from step _a, -1 when it turns left, 0 when it doesn't turn
function _bss_turn_s3k(_a, _b)
{
	return _a[0] * _b[1] - _a[1] * _b[0];
}

// Side by side. The original compares cell numbers, so the two ends of neighboring rows count too
function _bss_touching_s3k(_a, _b)
{
	if(!s3k_ring_conversion_fixes)
	{
		var _diff = abs(_a - _b);
		return _diff == 1 || _diff == board_width;
	}
	return _bss_move_s3k(_a, 1, 0) == _b || _bss_move_s3k(_a, -1, 0) == _b || _bss_move_s3k(_a, 0, 1) == _b || _bss_move_s3k(_a, 0, -1) == _b;
}

function _bss_get_s3k(_pos)
{
	return board[_pos mod board_width][_pos div board_width];
}

// Past the board's ends counts as empty
function _bss_get_line_s3k(_pos)
{
	if(_pos < 0 || _pos >= board_width * board_height) return BSS_CELL.NONE;
	return _bss_get_s3k(_pos);
}

function _bss_set_s3k(_pos, _cell)
{
	board[_pos mod board_width][_pos div board_width] = _cell;
}

function _bss_marked_s3k(_pos)
{
	return chain_marks[_pos mod board_width][_pos div board_width];
}

function _bss_mark_s3k(_pos, _marked)
{
	chain_marks[_pos mod board_width][_pos div board_width] = _marked;
}
