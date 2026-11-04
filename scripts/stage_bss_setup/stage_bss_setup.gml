// Blue Spheres special stage, ported from Sonic Mania's BSS objects.
// Every bss_* function runs on obj_bss_controller unless its header says otherwise. Ones starting with _bss_ are internal.

#macro BSS_MIN_SIZE 16
#macro BSS_JUMP_SPEED (-16 << 16)
#macro BSS_SPRING_SPEED (-24 << 16)
#macro BSS_GLOBE_Y 240
#macro BSS_PLAYER_Y 170

// Built-in cell numbers. The ones you paint are their tile's index in tex_tile_bss_editor, the ones the engine
// places start at 1000, so tiles from 1000 up load as empty floor. See stage_bss_cells for what each one does
enum BSS_CELL
{
	NONE          = 0,
	BLUE          = 1,
	RED           = 2,
	BUMPER        = 3,
	YELLOW        = 4,
	GREEN         = 5,
	PINK          = 6,
	RING          = 7,
	SPAWN_UP      = 8,
	SPAWN_RIGHT   = 9,
	SPAWN_DOWN    = 10,
	SPAWN_LEFT    = 11,
	SPARKLE       = 1000,
	EMERALD_CHAOS = 1001,
	MEDAL_SILVER  = 1002,
	MEDAL_GOLD    = 1003,
	GREEN_STOOD   = 1004,
	BLUE_STOOD    = 1005,
	PINK_STOOD    = 1006,
}

// The tile after the built-in ones, where your own cells start. They can go up to 999, see stage_bss_config
#macro BSS_CELL_CUSTOM 12

// Player animations
enum BSS_ANIM
{
	STAND  = 0,
	WALK   = 1,
	JUMP   = 2,
	SPRING = 3,
	TAIL   = 4,
}

/// @self								obj_bss_controller
/// @description						Builds the Blue Spheres lookup tables, called by obj_bss_controller's Create event
function bss_init()
{
	// Values from Sonic Mania's BSS_Setup and BSS_Collectable
	tables =
	{
		// Per depth row (0 = nearest): screen y, horizon curve divisor, sideways spread, sprite scale
		row_y : [
			280, 270, 260, 251, 243, 235, 228, 221, 215, 208, 202, 197, 191, 185, 180, 175, 170, 165, 160, 155, 151, 147, 143,
			139, 135, 131, 127, 124, 121, 117, 114, 111, 108, 105, 103, 100, 97,  95,  92,  90,  88,  86,  83,  81,  79,  77,
			76,  74,  72,  70,  69,  67,  66,  64,  63,  62,  60,  59,  58,  57,  56,  55,  54,  53,  52,  51,  50,  49,  48,
			47,  47,  46,  45,  45,  44,  44,  43,  43,  42,  42,  41,  40,  40,  40,  40,  40,  40,  40,  40,  39,  39,  39,
			39,  39,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38
		],
		
		row_curve : [
			4096, 4032, 3968, 3904, 3840, 3776, 3712, 3648, 3584, 3520, 3456, 3392, 3328, 3264, 3200, 3136, 3072, 2995, 2920, 2847, 2775, 2706, 2639,
			2572, 2508, 2446, 2384, 2324, 2266, 2210, 2154, 2100, 2048, 2012, 1976, 1940, 1906, 1872, 1838, 1806, 1774, 1742, 1711, 1680, 1650, 1621,
			1592, 1564, 1536, 1509, 1482, 1455, 1429, 1404, 1379, 1354, 1330, 1307, 1283, 1260, 1238, 1216, 1194, 1173, 1152, 1134, 1116, 1099, 1082,
			1065, 1048, 1032, 1016, 1000, 985,  969,  954,  939,  925,  910,  896,  892,  888,  884,  880,  875,  871,  867,  863,  859,  855,  851,
			848,  844,  840,  836,  832,  830,  828,  826,  824,  822,  820,  818,  816,  814,  812,  810,  808,  806,  804,  802
		],
		
		row_spread : [
			134, 131, 128, 125, 123, 121, 119, 117, 115, 114, 112, 111, 109, 108, 106, 104, 104, 102, 100, 98, 97, 96, 94, 93, 92, 90, 89, 88,
			86,  84,  83,  82,  80,  80,  79,  78,  77,  76,  74,  73,  72,  71,  70,  70,  68,  68,  67,  66, 65, 64, 63, 62, 61, 60, 60, 59,
			58,  57,  57,  56,  55,  54,  53,  53,  52,  51,  51,  50,  50,  49,  48,  48,  47,  47,  46,  46, 45, 45, 44, 44, 44, 43, 43, 43,
			42,  42,  42,  41,  41,  41,  41,  40,  40,  40,  40,  39,  39,  39,  39,  39,  38,  38,  38,  38, 38, 37, 37, 37, 37, 37, 36, 36
		],
		
		row_scale : [
			31, 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 29, 28, 28, 28, 28, 27, 27, 27, 26, 26, 26, 26, 25, 25, 25,
			24, 24, 24, 24, 23, 23, 23, 23, 22, 22, 22, 22, 21, 21, 21, 21, 20, 20, 20, 20, 19, 19, 19, 19, 18, 18, 18, 18, 17, 17, 17, 17,
			16, 16, 16, 15, 15, 14, 14, 14, 13, 13, 13, 12, 12, 12, 11, 11, 10, 10, 10, 10, 9,  9,  9,  9,  8,  8,  8,  8,  7,  7,  7,  7,
			6,  6,  6,  6,  5,  5,  5,  5,  4,  4,  3,  3,  2,  2,  1,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		],
		
		// Turn animation frame and mirroring for each of its 15 steps
		turn_frames     : [0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0],
		turn_flip_left  : [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1],
		turn_flip_right : [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
		
		// Per sprite frame pixel lift so spheres sit on the globe's surface
		sphere_lift : [1, 2, 3, 4, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6],
		
		// Mania ring and medal scales per scale step
		ring_scale_x  : [2, 4, 4, 4, 6, 6, 6, 7, 7, 8, 8, 9, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 24, 26, 28, 30, 32, 32, 32],
		ring_scale_y  : [2, 4, 4, 4, 6, 6, 6, 7, 7, 8, 8, 9, 9, 10, 11, 12, 13, 14, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 21, 22, 23, 24],
		medal_scale   : [4, 4, 5, 5, 6, 6, 7, 7, 8, 10, 12, 14, 16, 18, 20, 22, 24, 25, 26, 27, 28, 29, 30, 31, 32, 32, 32, 32, 32, 32, 32, 32],
		ring_screen_y : array_create(32, 0),
		
		// Board cells around the player that can be on screen, relative to facing up and in drawing order.
		// Mania builds these from its "Frustum 1" and "Frustum 2" tile layers, the second one covers mid-turn angles
		view_straight_x : [
			-5,5,-4,4,-5,5,-3,3,-4,4,-2,2,-1,1,0,-3,3,-4,4,-2,2,-1,1,0,-3,3,-4,4,-2,2,
			-3,3,-1,1,0,-2,2,-3,3,-1,1,-3,3,0,-2,2,-1,1,-2,2,0,-2,2,-1,1,0,-1,1,0
		],
		view_straight_y : [
			-6,-6,-6,-6,-5,-5,-6,-6,-5,-5,-6,-6,-6,-6,-6,-5,-5,-4,-4,-5,-5,-5,-5,-5,-4,-4,-3,-3,-4,-4,
			-3,-3,-4,-4,-4,-3,-3,-2,-2,-3,-3,-1,-1,-3,-2,-2,-2,-2,-1,-1,-2,0,0,-1,-1,-1,0,0,0
		],
		view_turning_x : [
			-4,4,-4,4,-3,3,-4,4,-4,4,-3,3,-2,2,-4,4,-4,4,-2,2,-3,3,-3,3,-1,1,-4,4,-4,4,
			-1,1,0,-4,4,0,-2,2,-3,3,-3,3,-2,2,-1,1,-3,3,-3,3,-1,1,0,-3,3,0,-2,2,-2,2,
			-1,1,-2,2,-2,2,-1,1,0,-2,2,0,-1,1,-1,1,0,-1,1,0,0
		],
		view_turning_y : [
			-4,-4,4,4,-4,-4,-3,-3,3,3,4,4,-4,-4,-2,-2,2,2,4,4,-3,-3,3,3,-4,-4,-1,-1,1,1,
			4,4,-4,0,0,4,-3,-3,-2,-2,2,2,3,3,-3,-3,-1,-1,1,1,3,3,-3,0,0,3,-2,-2,2,2,
			-2,-2,-1,-1,1,1,2,2,-2,0,0,2,-1,-1,1,1,-1,0,0,1,0
		],
	}
	
	// BSS_Collectable_StageLoad
	var _tables = tables;
	var _lift = 32;
	for (var i = 0; i < 32; i++)
	{
		_tables.ring_scale_x[i] *= 14;
		_tables.ring_scale_y[i] *= 14;
		_tables.medal_scale[i] *= 16;
		_tables.ring_screen_y[i] = _lift * (_tables.ring_scale_y[i] << 6);
		_tables.ring_scale_y[i] = _tables.ring_scale_x[i] + ((i * (_tables.ring_scale_y[i] - _tables.ring_scale_x[i])) >> 5);
		_lift--;
	}
}

/// @self								obj_bss_controller
/// @description						Reads the room's "Playfield" tile layer into the board. Tile index == cell value
function bss_load_playfield() //BSS_Setup_StageLoad
{
	var _layer = layer_get_id("Playfield");
	var _tilemap = (_layer != -1) ? layer_tilemap_get_id(_layer) : -1;
	var _tiles_w = (_tilemap != -1) ? tilemap_get_width(_tilemap) : 0;
	var _tiles_h = (_tilemap != -1) ? tilemap_get_height(_tilemap) : 0;
	
	if(_tilemap == -1)
		show_debug_message("BSS Playfield: no \"Playfield\" tile layer found, the board is empty");
	else if(_tiles_w < BSS_MIN_SIZE || _tiles_h < BSS_MIN_SIZE)
		show_debug_message("BSS Playfield: " + string(_tiles_w) + "x" + string(_tiles_h) + " is below the " + string(BSS_MIN_SIZE) + "x" + string(BSS_MIN_SIZE) + " minimum, padding with empty cells");
	
	// Smaller playfields get padded with empty cells
	board_width = max(_tiles_w, BSS_MIN_SIZE);
	board_height = max(_tiles_h, BSS_MIN_SIZE);
	board = bss_board_create();
	chain_marks = bss_board_create();
	ring_marks = bss_board_create();
	
	var _spawns = 0;
	var _reserved = 0;
	for (var gx = 0; gx < _tiles_w; gx++)
	{
		for (var gy = 0; gy < _tiles_h; gy++)
		{
			// Tiles with no cell defined are empty floor, and so are tiles numbered like the engine's own cells
			var _cell = tile_get_index(tilemap_get(_tilemap, gx, gy));
			if(_cell >= BSS_CELL.SPARKLE)
			{
				_cell = BSS_CELL.NONE;
				_reserved++;
			}
			else if(_cell >= array_length(cell_types) || !bss_cell_type(_cell).defined) _cell = BSS_CELL.NONE;
			board[gx][gy] = _cell;
			if(bss_cell_type(_cell).spawn_angle != -1) _spawns++;
		}
	}
	
	// Editor-only markers
	if(_layer != -1) layer_set_visible(_layer, false);
	
	if(_spawns != 1)
		show_debug_message("BSS Playfield: expected exactly 1 spawn tile, found " + string(_spawns));
	if(_reserved > 0)
		show_debug_message("BSS Playfield: " + string(_reserved) + " tiles numbered " + string(BSS_CELL.SPARKLE) + " or above were left empty, those numbers belong to the engine's own cells");
}

/// @self								obj_bss_controller
/// @description						Counts the spheres and puts the player on the spawn cell
function bss_read_start_board() //BSS_Setup_GetStartupInfo
{
	sphere_count = 0;
	pink_count = 0;
	for (var gy = 0; gy < board_height; gy++)
	{
		for (var gx = 0; gx < board_width; gx++)
		{
			var _type = bss_cell_type(board[gx][gy]);
			if(_type.required) sphere_count++;
			if(_type.kind == BSS_CELL.PINK) pink_count++;
			
			if(_type.spawn_angle != -1)
			{
				angle = _type.spawn_angle;
				player_x = gx;
				player_y = gy;
				board[gx][gy] = BSS_CELL.NONE;
			}
		}
	}
}
