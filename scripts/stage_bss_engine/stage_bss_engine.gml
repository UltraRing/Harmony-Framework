// Blue Spheres engine, accurate port of Sonic Mania's code.

#macro BSS_W global.bss.w
#macro BSS_H global.bss.h
#macro BSS_MIN_SIZE 16

// Cell values
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
	SPARKLE       = 15,
	EMERALD_CHAOS = 16,
	EMERALD_SUPER = 17,
	MEDAL_SILVER  = 18,
	MEDAL_GOLD    = 19,
	GREEN_STOOD   = 0x81,
	BLUE_STOOD    = 0x82,
	PINK_STOOD    = 0x86,
}

// Setup states
enum BSS_STATE
{
	MOVE     = 0,
	TURNL    = 1,
	TURNR    = 2,
	TELE_IN  = 3,
	TELE_OUT = 4,
	JETTISON = 5,
	EMERALD  = 6,
	EXIT     = 7,
}

// Collected-event types
enum BSS_COLLECT
{
	RING        = 0,
	BLUE        = 1,
	BLUE_STOOD  = 2,
	GREEN       = 3,
	GREEN_STOOD = 4,
	PINK        = 5,
}

// Player anims
enum BSS_ANIM
{
	STAND  = 0,
	WALK   = 1,
	JUMP   = 2,
	SPRING = 3,
	TAIL   = 4,
}

// Column-major board: cell (x, y) lives at x * height + y
function bss_idx(_x, _y) 
{
	return (bss_wrap_x(_x) * BSS_H) + bss_wrap_y(_y);
}

// Torus wrap helpers
function bss_wrap_x(_v)
{
	var w = BSS_W;
	return ((_v mod w) + w) mod w;
}

function bss_wrap_y(_v)
{
	var h = BSS_H;
	return ((_v mod h) + h) mod h;
}

// BSS_Message two-part message
function bss_draw_message(_spr, _cx, _cy, _offset) 
{
	var fw = sprite_get_width(_spr);
	var fh = sprite_get_height(_spr);
	draw_sprite(_spr, 0, _cx - _offset - fw, _cy - (fh div 2));
	draw_sprite(_spr, 1, _cx + _offset,      _cy - (fh div 2));
}

// BSS_HUD_DrawNumbers
function bss_draw_number(_value, _right_x, _y) 
{
	var s = string(_value mod 1000);
	s = string_repeat("0", max(0, 3 - string_length(s))) + s;
	draw_set_font(global.bss_number);
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_text(_right_x, _y, s);
	draw_set_halign(fa_left);
}

// Build global.bss.pf_stage from the room's "Playfield" tilemap (mirrors Mania's BSS_Setup_StageLoad,
// which reads the playfield from a tile layer). Tile index == cell value; index 0 = BSS_CELL.NONE.
function bss_load_playfield() 
{
	//Board size comes from the room's tilemap (example: 512x512 of 16x16 tiles -> 32x32 cells)
	global.bss.w = 32;
	global.bss.h = 32;

	var lay = layer_get_id("Playfield");
	if (lay == -1)
	{
		global.bss.size = global.bss.w * global.bss.h;
		global.bss.pf_stage = array_create(global.bss.size, BSS_CELL.NONE);
		return;
	}

	var tm = layer_tilemap_get_id(lay);
	var tm_w = tilemap_get_width(tm);
	var tm_h = tilemap_get_height(tm);

	//Is the playfield size below the minimum?
	if (tm_w < BSS_MIN_SIZE || tm_h < BSS_MIN_SIZE)
		show_debug_message("BSS Playfield: " + string(tm_w) + "x" + string(tm_h) + " is below the " + string(BSS_MIN_SIZE) + "x" + string(BSS_MIN_SIZE) + " minimum, padding with empty cells");
	
	//Clamp playfield size
	global.bss.w = max(tm_w, BSS_MIN_SIZE);
	global.bss.h = max(tm_h, BSS_MIN_SIZE);
	global.bss.size = global.bss.w * global.bss.h;
	global.bss.pf_stage = array_create(global.bss.size, BSS_CELL.NONE);
	var spawns = 0;
	for (var gx = 0; gx < tm_w; gx++)
	{
		for (var gy = 0; gy < tm_h; gy++)
		{
			var t = tile_get_index(tilemap_get(tm, gx, gy)); //== Mania's tile & 0x3FF
			if (t > 24) t = BSS_CELL.NONE;
			global.bss.pf_stage[gx * BSS_H + gy] = t;
			if (t >= BSS_CELL.SPAWN_UP && t <= BSS_CELL.SPAWN_LEFT) spawns++;
		}
	}

	//editor-only markers, hidden in-game
	layer_set_visible(lay, false);

	if (spawns != 1)
		show_debug_message("BSS Playfield: expected exactly 1 spawn tile, found " + string(spawns));
}

// One-time setup at game start: the namespace and its static tables never change per stage
function bss_init()
{
	global.bss = {};
	bss_build_tables();
	bss_frustum_tables();
}

// Lookup tables copied verbatim from Mania's BSS_Setup.h / BSS_Collectable.h
function bss_build_tables()
{
	global.bss.screenYTable = [
		280, 270, 260, 251, 243, 235, 228, 221, 215, 208, 202, 197, 191, 185, 180, 175, 170, 165, 160, 155, 151, 147, 143,
		139, 135, 131, 127, 124, 121, 117, 114, 111, 108, 105, 103, 100, 97,  95,  92,  90,  88,  86,  83,  81,  79,  77,
		76,  74,  72,  70,  69,  67,  66,  64,  63,  62,  60,  59,  58,  57,  56,  55,  54,  53,  52,  51,  50,  49,  48,
		47,  47,  46,  45,  45,  44,  44,  43,  43,  42,  42,  41,  40,  40,  40,  40,  40,  40,  40,  40,  39,  39,  39,
		39,  39,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38
	];

	global.bss.divisorTable = [
		4096, 4032, 3968, 3904, 3840, 3776, 3712, 3648, 3584, 3520, 3456, 3392, 3328, 3264, 3200, 3136, 3072, 2995, 2920, 2847, 2775, 2706, 2639,
		2572, 2508, 2446, 2384, 2324, 2266, 2210, 2154, 2100, 2048, 2012, 1976, 1940, 1906, 1872, 1838, 1806, 1774, 1742, 1711, 1680, 1650, 1621,
		1592, 1564, 1536, 1509, 1482, 1455, 1429, 1404, 1379, 1354, 1330, 1307, 1283, 1260, 1238, 1216, 1194, 1173, 1152, 1134, 1116, 1099, 1082,
		1065, 1048, 1032, 1016, 1000, 985,  969,  954,  939,  925,  910,  896,  892,  888,  884,  880,  875,  871,  867,  863,  859,  855,  851,
		848,  844,  840,  836,  832,  830,  828,  826,  824,  822,  820,  818,  816,  814,  812,  810,  808,  806,  804,  802
	];

	global.bss.xMultiplierTable = [
		134, 131, 128, 125, 123, 121, 119, 117, 115, 114, 112, 111, 109, 108, 106, 104, 104, 102, 100, 98, 97, 96, 94, 93, 92, 90, 89, 88,
		86,  84,  83,  82,  80,  80,  79,  78,  77,  76,  74,  73,  72,  71,  70,  70,  68,  68,  67,  66, 65, 64, 63, 62, 61, 60, 60, 59,
		58,  57,  57,  56,  55,  54,  53,  53,  52,  51,  51,  50,  50,  49,  48,  48,  47,  47,  46,  46, 45, 45, 44, 44, 44, 43, 43, 43,
		42,  42,  42,  41,  41,  41,  41,  40,  40,  40,  40,  39,  39,  39,  39,  39,  38,  38,  38,  38, 38, 37, 37, 37, 37, 37, 36, 36
	];

	global.bss.frameTable = [
		31, 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 29, 28, 28, 28, 28, 27, 27, 27, 26, 26, 26, 26, 25, 25, 25,
		24, 24, 24, 24, 23, 23, 23, 23, 22, 22, 22, 22, 21, 21, 21, 21, 20, 20, 20, 20, 19, 19, 19, 19, 18, 18, 18, 18, 17, 17, 17, 17,
		16, 16, 16, 15, 15, 14, 14, 14, 13, 13, 13, 12, 12, 12, 11, 11, 10, 10, 10, 10, 9,  9,  9,  9,  8,  8,  8,  8,  7,  7,  7,  7,
		6,  6,  6,  6,  5,  5,  5,  5,  4,  4,  3,  3,  2,  2,  1,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	];

	global.bss.globeFrameTable = [0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0];
	global.bss.globeDirTableL  = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1];
	global.bss.globeDirTableR  = [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0];

	// Per-frame pixel lift so spheres sit on the surface
	global.bss.sphereLift = [1, 2, 3, 4, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6];

	// BSS_Collectable Mania ring/medal scale tables + the BSS_Collectable_StageLoad transform
	global.bss.ringScaleX = [2, 4, 4, 4, 6, 6, 6, 7, 7, 8, 8, 9, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 24, 26, 28, 30, 32, 32, 32];
	global.bss.ringScaleY = [2, 4, 4, 4, 6, 6, 6, 7, 7, 8, 8, 9, 9, 10, 11, 12, 13, 14, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 21, 22, 23, 24];
	global.bss.medalScale = [4, 4, 5, 5, 6, 6, 7, 7, 8, 10, 12, 14, 16, 18, 20, 22, 24, 25, 26, 27, 28, 29, 30, 31, 32, 32, 32, 32, 32, 32, 32, 32];
	global.bss.ringScreenY = array_create(32, 0);

	var did = 32;
	for (var i = 0; i < 32; i++)
	{
		global.bss.ringScaleX[i] *= 14;
		global.bss.ringScaleY[i] *= 14;
		global.bss.medalScale[i] *= 16;
		global.bss.ringScreenY[i] = did * (global.bss.ringScaleY[i] << 6);

		var sc  = i * (global.bss.ringScaleY[i] - global.bss.ringScaleX[i]);
		var scX = global.bss.ringScaleX[i];
		global.bss.ringScaleY[i] = scX + (sc >> 5);

		did--;
	}
}

// Blue sphere -> ring enclosure (BSS_Setup_ProcessChain family), masks verbatim.
// A chain step is only valid with a blue sphere in the 8 cells around it
function bss_check_sphere_valid(_x, _y) 
{
	var pf = global.bss.pf;
	var x1 = BSS_H * bss_wrap_x(_x - 1);
	var y1 = bss_wrap_y(_y - 1);
	var x2 = BSS_H * bss_wrap_x(_x + 1);
	var y2 = bss_wrap_y(_y + 1);

	if ((pf[x1 + y1] & 0x7F) == BSS_CELL.BLUE) return true;
	if ((pf[x2 + y1] & 0x7F) == BSS_CELL.BLUE || (pf[x1 + _y] & 0x7F) == BSS_CELL.BLUE || (pf[x2 + _y] & 0x7F) == BSS_CELL.BLUE) return true;
	if ((pf[x1 + y2] & 0x7F) != BSS_CELL.BLUE && (pf[x2 + y2] & 0x7F) != BSS_CELL.BLUE
		&& (pf[(BSS_H * _x) + y1] & 0x7F) != BSS_CELL.BLUE && (pf[(BSS_H * _x) + y2] & 0x7F) != BSS_CELL.BLUE) return false;
	return true;
}

// Walk a chain of reds away from the start sphere, branching sideways as it goes.
// A tail that never branched gets un-marked when the walk dead-ends
function bss_scan_up(_x, _y) 
{
	if (global.bss.loop) return true;
	var pf = global.bss.pf, ch = global.bss.chain, co = global.bss.coll;
	var px = BSS_H * _x;
	var cid = 0;
	while (true)
	{
		_y = bss_wrap_y(_y - 1);
		if ((pf[px + _y] & 0x7F) != BSS_CELL.RED) break;
		if ((ch[px + _y] & 0x7F) == BSS_CELL.BLUE) break;
		if (!bss_check_sphere_valid(_x, _y)) break;
		ch[_y + px] = BSS_CELL.BLUE;
		co[_y + px] = BSS_CELL.BLUE;
		if (_x == global.bss.lastSX && _y == global.bss.lastSY) { global.bss.loop = true; return true; }
		var found = false;
		if ((pf[_y + (BSS_H * bss_wrap_x(_x + 1))] & 0x7F) == BSS_CELL.RED) found = bss_scan_right(_x, _y) || found;
		if ((pf[_y + (BSS_H * bss_wrap_x(_x - 1))] & 0x7F) == BSS_CELL.RED) found = bss_scan_left(_x, _y) || found;
		if (!found) cid++; else cid = 0;
		if (global.bss.loop) return true;
	}
	for (var i = cid; i > 0; i--) { _y = bss_wrap_y(_y + 1); co[px + _y] = BSS_CELL.NONE; }
	return false;
}

function bss_scan_down(_x, _y) 
{
	if (global.bss.loop) return true;
	var pf = global.bss.pf, ch = global.bss.chain, co = global.bss.coll;
	var px = BSS_H * _x;
	var cid = 0;
	while (true)
	{
		_y = bss_wrap_y(_y + 1);
		if ((pf[px + _y] & 0x7F) != BSS_CELL.RED) break;
		if (ch[px + _y] == BSS_CELL.BLUE) break;
		if (!bss_check_sphere_valid(_x, _y)) break;
		ch[_y + px] = BSS_CELL.BLUE;
		co[_y + px] = BSS_CELL.BLUE;
		if (_x == global.bss.lastSX && _y == global.bss.lastSY) { global.bss.loop = true; return true; }
		var found = false;
		if ((pf[_y + (BSS_H * bss_wrap_x(_x - 1))] & 0x7F) == BSS_CELL.RED) found = bss_scan_left(_x, _y) || found;
		if ((pf[_y + (BSS_H * bss_wrap_x(_x + 1))] & 0x7F) == BSS_CELL.RED) found = bss_scan_right(_x, _y) || found;
		if (!found) cid++; else cid = 0;
		if (global.bss.loop) return true;
	}
	for (var i = cid; i > 0; i--) { _y = bss_wrap_y(_y - 1); co[px + _y] = BSS_CELL.NONE; }
	return false;
}

function bss_scan_left(_x, _y) 
{
	if (global.bss.loop) return true;
	var pf = global.bss.pf, ch = global.bss.chain, co = global.bss.coll;
	var cid = 0;
	while (true)
	{
		_x = bss_wrap_x(_x - 1);
		var px = BSS_H * _x;
		if ((pf[px + _y] & 0x7F) != BSS_CELL.RED) break;
		if ((ch[px + _y] & 0x7F) == BSS_CELL.BLUE) break;
		if (!bss_check_sphere_valid(_x, _y)) break;
		ch[_y + px] = BSS_CELL.BLUE;
		co[_y + px] = BSS_CELL.BLUE;
		if (_x == global.bss.lastSX && _y == global.bss.lastSY) { global.bss.loop = true; return true; }
		var found = false;
		if ((pf[(BSS_H * _x) + bss_wrap_y(_y - 1)] & 0x7F) == BSS_CELL.RED) found = bss_scan_up(_x, _y) || found;
		if ((pf[(BSS_H * _x) + bss_wrap_y(_y + 1)] & 0x7F) == BSS_CELL.RED) found = bss_scan_down(_x, _y) || found;
		if (!found) cid++; else cid = 0;
		if (global.bss.loop) return true;
	}
	for (var i = cid; i > 0; i--) { _x = bss_wrap_x(_x + 1); co[(BSS_H * _x) + _y] = BSS_CELL.NONE; }
	return false;
}

function bss_scan_right(_x, _y) 
{
	if (global.bss.loop) return true;
	var pf = global.bss.pf, ch = global.bss.chain, co = global.bss.coll;
	var cid = 0;
	while (true)
	{
		_x = bss_wrap_x(_x + 1);
		var px = BSS_H * _x;
		if ((pf[px + _y] & 0x7F) != BSS_CELL.RED) break;
		if ((ch[px + _y] & 0x7F) == BSS_CELL.BLUE) break;
		if (!bss_check_sphere_valid(_x, _y)) break;
		ch[_y + px] = BSS_CELL.BLUE;
		co[_y + px] = BSS_CELL.BLUE;
		if (_x == global.bss.lastSX && _y == global.bss.lastSY) { global.bss.loop = true; return true; }
		var found = false;
		if ((pf[(BSS_H * _x) + bss_wrap_y(_y + 1)] & 0x7F) == BSS_CELL.RED) found = bss_scan_down(_x, _y) || found;
		if ((pf[(BSS_H * _x) + bss_wrap_y(_y - 1)] & 0x7F) == BSS_CELL.RED) found = bss_scan_up(_x, _y) || found;
		if (!found) cid++; else cid = 0;
		if (global.bss.loop) return true;
	}
	for (var i = cid; i > 0; i--) { _x = bss_wrap_x(_x - 1); co[(BSS_H * _x) + _y] = BSS_CELL.NONE; }
	return false;
}

// A blue is enclosed when all four rays hit the chain before empty floor or a red
function bss_chained_count(_x, _y) 
{
	var pf = global.bss.pf, co = global.bss.coll;
	var px = BSS_H * _x;

	var y1 = bss_wrap_y(_y - 1);
	for (var i = 0; i < BSS_H; i++)
	{
		if (co[px + y1] == BSS_CELL.BLUE) break;
		var t = pf[px + y1] & 0x7F;
		if (t == BSS_CELL.NONE || t == BSS_CELL.RED) return false;
		y1 = bss_wrap_y(y1 - 1);
	}
	y1 = bss_wrap_y(_y + 1);
	for (var i = 0; i < BSS_H; i++)
	{
		if (co[px + y1] == BSS_CELL.BLUE) break;
		var t = pf[px + y1] & 0x7F;
		if (t == BSS_CELL.NONE || t == BSS_CELL.RED) return false;
		y1 = bss_wrap_y(y1 + 1);
	}
	var x1 = bss_wrap_x(_x - 1);
	for (var i = 0; i < BSS_W; i++)
	{
		if (co[_y + (BSS_H * x1)] == BSS_CELL.BLUE) break;
		var t = pf[_y + (BSS_H * x1)] & 0x7F;
		if (t == BSS_CELL.NONE || t == BSS_CELL.RED) return false;
		x1 = bss_wrap_x(x1 - 1);
	}
	x1 = bss_wrap_x(_x + 1);
	for (var i = 0; i < BSS_W; i++)
	{
		if (co[_y + (BSS_H * x1)] == BSS_CELL.BLUE) break;
		var t = pf[_y + (BSS_H * x1)] & 0x7F;
		if (t == BSS_CELL.NONE || t == BSS_CELL.RED) return false;
		x1 = bss_wrap_x(x1 + 1);
	}

	co[px + _y] = BSS_CELL.BLUE;
	return true;
}

// Runs when a blue sphere is collected. Sets global.bss.loop, converts enclosed cells to rings.
// Returns spheres converted (caller subtracts from sphere count)
function bss_process_chain() 
{
	var pf = global.bss.pf, ch = global.bss.chain, co = global.bss.coll;
	for (var i = 0; i < global.bss.size; i++) { ch[i] = BSS_CELL.NONE; co[i] = BSS_CELL.NONE; }

	var lp = bss_idx(global.bss.lastSX, global.bss.lastSY);
	//Temporarily red so the scans can walk through the start sphere
	pf[lp] = BSS_CELL.RED;
	co[lp] = BSS_CELL.BLUE;

	global.bss.loop = false;
	bss_scan_up(global.bss.lastSX, global.bss.lastSY);
	bss_scan_down(global.bss.lastSX, global.bss.lastSY);
	bss_scan_left(global.bss.lastSX, global.bss.lastSY);
	bss_scan_right(global.bss.lastSX, global.bss.lastSY);

	pf[lp] = BSS_CELL.BLUE;

	if (!global.bss.loop) return 0;

	//Count the blues the loop encloses
	var collected = 0;
	for (var gy = 0; gy < BSS_H; gy++)
	{
		for (var gx = 0; gx < BSS_W; gx++) {
			if ((pf[(gx * BSS_H) + gy] & 0x7F) == BSS_CELL.BLUE) collected += bss_chained_count(gx, gy) ? 1 : 0;
		}
	}
	if (collected <= 0) { global.bss.loop = false; return 0; }

	// Trim cells not actually enclosed ("the hell pit")
	for (var gy = 0; gy < BSS_H; gy++)
	{
		for (var gx = 0; gx < BSS_W; gx++)
		{
			var p = gx * BSS_H;
			var y1 = bss_wrap_y(gy - 1);
			var y2 = bss_wrap_y(gy + 1);
			var x1 = BSS_H * bss_wrap_x(gx - 1);
			var x2 = BSS_H * bss_wrap_x(gx + 1);
			if (co[p + gy] == BSS_CELL.BLUE)
			{
				if ((pf[p + y1] & 0x7F) != BSS_CELL.BLUE && (pf[p + y2] & 0x7F) != BSS_CELL.BLUE && (pf[x1 + gy] & 0x7F) != BSS_CELL.BLUE)
				{
					if ((pf[x2 + gy] & 0x7F) != BSS_CELL.BLUE && (pf[x1 + y1] & 0x7F) != BSS_CELL.BLUE
						&& (pf[x2 + y1] & 0x7F) != BSS_CELL.BLUE && (pf[x1 + y2] & 0x7F) != BSS_CELL.BLUE) {
						if ((pf[x2 + y2] & 0x7F) != BSS_CELL.BLUE) co[(gx * BSS_H) + gy] = BSS_CELL.NONE;
					}
				}
			}
		}
	}

	for (var gy = 0; gy < BSS_H; gy++)
	{
		for (var gx = 0; gx < BSS_W; gx++) {
			//Everything still marked becomes a ring
			if (co[(gx * BSS_H) + gy] != BSS_CELL.NONE) pf[(gx * BSS_H) + gy] = BSS_CELL.RING;
		}
	}

	// Play ringloss sound
	sound_play(sfx_ringloss);
	return collected;
}

// Draw one projected cell at screen (_x,_y), scale frame _f (0..31, 31 = closest).
function bss_draw_cell(_t, _x, _y, _f, _spin, _medal, _spark, _epal)
{
	// Lift the sphere so it sits on the globe's surface
	var ly = _y - global.bss.sphereLift[_f div 2];
	
	// Draw the cells here
	switch (_t)
	{
		case BSS_CELL.BLUE:   draw_sprite(spr_bss_sphere_blue,   _f div 2, _x, ly); break;
		case BSS_CELL.RED:    draw_sprite(spr_bss_sphere_red,    _f div 2, _x, ly); break;
		case BSS_CELL.BUMPER: draw_sprite(spr_bss_bumper,        _f div 2, _x, ly); break;
		case BSS_CELL.YELLOW: draw_sprite(spr_bss_sphere_yellow, _f div 2, _x, ly); break;
		case BSS_CELL.GREEN:  draw_sprite(spr_bss_sphere_green,  _f div 2, _x, ly); break;
		case BSS_CELL.PINK:   draw_sprite(spr_bss_sphere_pink,   _f div 2, _x, ly); break;

		case BSS_CELL.RING:
			//Uncomment this for Mania's method of drawing rings!
			/*
			var spin = floor(_spin) mod sprite_get_number(spr_bss_ring_mania);
			draw_sprite_ext(spr_bss_ring_mania, spin,
				_x, _y - (global.bss.ringScreenY[_f] / 65536), //1 << 16
				global.bss.ringScaleX[_f] / 512, global.bss.ringScaleY[_f] / 512, 0, c_white, 1);
			*/
			draw_sprite(spr_bss_ring, (global.bss.ring_phase * 16) + (_f div 2), _x, _y);
			break;

		case BSS_CELL.MEDAL_SILVER:
		case BSS_CELL.MEDAL_GOLD:
			var ms = global.bss.medalScale[_f] / 512;
			var mspr = (_t == BSS_CELL.MEDAL_GOLD) ? spr_bss_medal_gold : spr_bss_medal_silver;
			draw_sprite_ext(mspr, _medal mod sprite_get_number(mspr),
				_x, _y - (global.bss.ringScreenY[_f] / 65536), ms, ms, 0, c_white, 1); //1 << 16
			break;

		case BSS_CELL.EMERALD_CHAOS:
			effect_set_palette(tex_pal_bss_chaos_emeralds, _epal); //recolor to the awarded emerald's row
			draw_sprite(spr_bss_chaos_emerald, _f div 2, _x, _y);
			shader_reset();
			break;

		case BSS_CELL.BLUE_STOOD:  draw_sprite_ext(spr_bss_sphere_blue,  _f div 2, _x, ly, 1, 1, 0, c_white, 0.5); break;
		case BSS_CELL.GREEN_STOOD: draw_sprite_ext(spr_bss_sphere_green, _f div 2, _x, ly, 1, 1, 0, c_white, 0.5); break;
		case BSS_CELL.PINK_STOOD:  draw_sprite_ext(spr_bss_sphere_pink,  _f div 2, _x, ly, 1, 1, 0, c_white, 0.5); break;

		case BSS_CELL.SPARKLE: draw_sprite(spr_bss_ring_sparkle, _spark, _x, _y); break;
		default: break;
	}
}

// BSS_Setup_GetStartupInfo
function bss_setup_start_info()
{
	sphere_count = 0;
	pink_count   = 0;
	for (var gy = 0; gy < BSS_H; gy++)
	{
		for (var gx = 0; gx < BSS_W; gx++)
		{
			var p = (gx * BSS_H) + gy;
			switch (global.bss.pf[p])
			{
				case BSS_CELL.BLUE:
				case BSS_CELL.GREEN: sphere_count++; break;
				case BSS_CELL.PINK:  pink_count++; break;
				case BSS_CELL.SPAWN_UP:    angle = 0x00; player_x = gx; player_y = gy; global.bss.pf[p] = BSS_CELL.NONE; break;
				case BSS_CELL.SPAWN_RIGHT: angle = 0x40; player_x = gx; player_y = gy; global.bss.pf[p] = BSS_CELL.NONE; break;
				case BSS_CELL.SPAWN_DOWN:  angle = 0x80; player_x = gx; player_y = gy; global.bss.pf[p] = BSS_CELL.NONE; break;
				case BSS_CELL.SPAWN_LEFT:  angle = 0xC0; player_x = gx; player_y = gy; global.bss.pf[p] = BSS_CELL.NONE; break;
			}
		}
	}
}

// BSS_Setup_CollectRing
function bss_collect_ring()
{
	rings_collected++;
	sound_play(sfx_ring);
	if (ring_count > 0)
	{
		ring_count--;
		if (ring_count == 0)
		{
			//BSS_Message PERFECT
			perfect_active = true;
			perfect_phase  = 0;
			perfect_offset = 320;
			perfect_wait   = 0;
			sound_play(sfx_event);
		}
	}
}

// BSS_Setup_SetupFinishSequence
function bss_setup_finish()
{
	//Clear EVERYTHING!
	for (var gy = 0; gy < BSS_H; gy++)
		for (var gx = 0; gx < BSS_W; gx++) global.bss.pf[(gx * BSS_H) + gy] = BSS_CELL.NONE;

	//The reward lands 8 cells ahead of the player
	var fx = (sin256(angle) >> 5) + player_x;
	var fy = bss_wrap_y(player_y - (cos256(angle) >> 5));
	var fp = fy + (BSS_H * bss_wrap_x(fx));

	// Grant the next Chaos Emerald. Fall back to medals if all emeralds already collected.
	emerald_index     = game_emerald_count();
	reward_is_emerald = (emerald_index < array_length(global.emeralds));

	if (reward_is_emerald)
		global.bss.pf[fp] = BSS_CELL.EMERALD_CHAOS;
	else
		global.bss.pf[fp] = (ring_count > 0) ? BSS_CELL.MEDAL_SILVER : BSS_CELL.MEDAL_GOLD;
}

// BSS_Setup_HandleSteppedObjects (runs every grounded frame)
function bss_stepped_objects()
{
	var pf = global.bss.pf;
	if (globe_timer < 32)  disable_bumpers = false;
	if (globe_timer > 224) disable_bumpers = false;

	//Current cell, reacts in the first half of the roll
	var fp = player_y + (BSS_H * player_x);
	switch (pf[fp])
	{
		case BSS_CELL.BLUE:
			if (globe_timer < 128)
			{
				global.bss.lastSX = player_x;
				global.bss.lastSY = player_y;
				sphere_count -= bss_process_chain();
				sphere_count--;
				if (!global.bss.loop)
				{
					array_push(collected, { ce : BSS_COLLECT.BLUE, cx : player_x, cy : player_y, t : 0 });
					pf[fp] = BSS_CELL.BLUE_STOOD;
				}
				if (sphere_count <= 0)
				{
					sphere_count = 0;
					state = BSS_STATE.JETTISON;
					spin_timer = 0;
					sound_play(sfx_jettison);
					music_set_fade(FADE.OUT, 1);
				} else {
					sound_play(sfx_blue_sphere);
				}
			}
			break;

		case BSS_CELL.RED:
			if (state != BSS_STATE.EXIT && globe_timer < 32)
			{
				state = BSS_STATE.EXIT;
				spin_timer = 0;
				globe_timer = 0;
				stage_failed = true;
				sound_play(sfx_warp_exit);
				music_set_fade(FADE.OUT, 1);
			}
			break;

		case BSS_CELL.BUMPER:
			if (!disable_bumpers && globe_timer < 112)
			{
				if (globe_timer > 16)
				{
					if (globe_speed < 0)
					{
						disable_bumpers = true;
						globe_speed = -globe_speed;
						player_was_bumped = false;
						sound_play(sfx_bumper);
					}
				}
				else if (spin_state == 0)
				{
					if (globe_speed < 0)
					{
						globe_timer = 16;
						disable_bumpers = true;
						globe_speed = -globe_speed;
						player_was_bumped = false;
						sound_play(sfx_bumper);
					}
				}
			}
			break;

		case BSS_CELL.YELLOW:
			if (globe_timer < 128)
			{
				velocity_y = -1572864; //-TO_FIXED(24)
				on_ground = false;
				animation_play(animator, BSS_ANIM.SPRING);
				globe_speed *= 2;
				spin_state = 0;
				globe_speed_inc = 4;
				sound_play(sfx_spring);
			}
			break;

		case BSS_CELL.GREEN:
			if (globe_timer > 128)
			{
				array_push(collected, { ce : BSS_COLLECT.GREEN, cx : player_x, cy : player_y, t : 0 });
				pf[fp] = BSS_CELL.GREEN_STOOD;
				sound_play(sfx_blue_sphere);
			}
			break;

		case BSS_CELL.PINK:
			if (state != BSS_STATE.TELE_IN && globe_timer < 64)
			{
				state = BSS_STATE.TELE_IN;
				spin_timer = 0;
				globe_timer = 0;
				tele_timer = 0;
				sound_play(sfx_teleport);
				fade_change(FADE.OUT, 6, FADE_COLOR.WHITE);
			}
			break;

		case BSS_CELL.RING:
			if (globe_timer < 128)
			{
				array_push(collected, { ce : BSS_COLLECT.RING, cx : player_x, cy : player_y, t : 0 });
				pf[fp] = BSS_CELL.SPARKLE;
				bss_collect_ring();
			}
			break;
	}

	//Cell ahead, reacts in the second half of the roll
	var posX = bss_wrap_x(player_x + (sin256(angle) >> 8));
	var posY = bss_wrap_y(player_y - (cos256(angle) >> 8));
	fp = posY + (BSS_H * posX);

	switch (pf[fp])
	{
		case BSS_CELL.BLUE:
			if (globe_timer > 128)
			{
				global.bss.lastSX = posX;
				global.bss.lastSY = posY;
				sphere_count -= bss_process_chain();
				sphere_count--;
				if (!global.bss.loop)
				{
					array_push(collected, { ce : BSS_COLLECT.BLUE, cx : posX, cy : posY, t : 0 });
					pf[fp] = BSS_CELL.BLUE_STOOD;
				}
				if (sphere_count <= 0)
				{
					sphere_count = 0;
					state = BSS_STATE.JETTISON;
					spin_timer = 0;
					sound_play(sfx_jettison);
					music_set_fade(FADE.OUT, 1);
				} else {
					sound_play(sfx_blue_sphere);
				}
			}
			break;

		case BSS_CELL.RED:
			if (state != BSS_STATE.EXIT && globe_timer > 224)
			{
				palette_page ^= 1;
				state = BSS_STATE.EXIT;
				spin_timer = 0;
				globe_timer = 0;
				player_x = bss_wrap_x(player_x + (sin256(angle) >> 8));
				player_y = bss_wrap_y(player_y - (cos256(angle) >> 8));
				stage_failed = true;
				sound_play(sfx_warp_exit);
				music_set_fade(FADE.OUT, 1);
			}
			break;

		case BSS_CELL.BUMPER:
			if (!disable_bumpers && globe_timer > 144)
			{
				if (globe_timer >= 240)
				{
					if (spin_state == 0)
					{
						if (globe_speed > 0)
						{
							globe_timer = 240;
							disable_bumpers = true;
							globe_speed = -globe_speed;
							player_was_bumped = true;
							sound_play(sfx_bumper);
						}
					}
				}
				else
				{
					if (globe_speed > 0)
					{
						disable_bumpers = true;
						globe_speed = -globe_speed;
						player_was_bumped = true;
						sound_play(sfx_bumper);
					}
				}
			}
			break;

		case BSS_CELL.YELLOW:
			if (globe_timer > 128)
			{
				velocity_y = -1572864; //-TO_FIXED(24)
				on_ground = false;
				animation_play(animator, BSS_ANIM.SPRING);
				globe_speed *= 2;
				spin_state = 0;
				globe_speed_inc = 4;
				sound_play(sfx_spring);
			}
			break;

		case BSS_CELL.GREEN:
			if (globe_timer > 128)
			{
				array_push(collected, { ce : BSS_COLLECT.GREEN, cx : posX, cy : posY, t : 0 });
				pf[fp] = BSS_CELL.GREEN_STOOD;
				sound_play(sfx_blue_sphere);
			}
			break;

		case BSS_CELL.RING:
			if (globe_timer > 128)
			{
				array_push(collected, { ce : BSS_COLLECT.RING, cx : posX, cy : posY, t : 0 });
				pf[fp] = BSS_CELL.SPARKLE;
				bss_collect_ring();
			}
			break;

		case BSS_CELL.EMERALD_CHAOS:
		case BSS_CELL.EMERALD_SUPER:
		case BSS_CELL.MEDAL_SILVER:
		case BSS_CELL.MEDAL_GOLD:
			if (globe_timer > 240)
			{
				palette_page ^= 1;
				state = BSS_STATE.EXIT;
				spin_timer = 0;
				globe_timer = 0;
				player_x = bss_wrap_x(player_x + (sin256(angle) >> 8));
				player_y = bss_wrap_y(player_y - (cos256(angle) >> 8));
				sound_play(sfx_warp_exit);
			}
			break;
	}
}

// BSS_Collected_Update
function bss_update_collected()
{
	var pf = global.bss.pf;
	for (var i = array_length(collected) - 1; i >= 0; i--)
	{
		var e = collected[i];
		var fp = e.cy + (BSS_H * e.cx);
		var remove = false;

		switch (e.ce)
		{
			//Sparkle for 16 frames, then free the cell
			case BSS_COLLECT.RING:
				e.t++;
				if (e.t >= 16 && state == BSS_STATE.MOVE)
				{
					pf[fp] = BSS_CELL.NONE;
					remove = true;
				}
				break;

			case BSS_COLLECT.BLUE:
				if (sphere_count <= 0)
				{
					if (pf[fp] == BSS_CELL.BLUE_STOOD) pf[fp] = BSS_CELL.RED;
					remove = true;
				}
				else if (globe_timer < 32 || globe_timer > 224) {
					e.ce = BSS_COLLECT.BLUE_STOOD;
				}
				break;

			//Turns red once the player has rolled clear
			case BSS_COLLECT.BLUE_STOOD:
				if (state == BSS_STATE.MOVE && globe_timer > 32 && globe_timer < 224)
				{
					if (pf[fp] == BSS_CELL.BLUE_STOOD) pf[fp] = BSS_CELL.RED;
					remove = true;
				}
				break;

			case BSS_COLLECT.GREEN:
				if (globe_timer < 32 || globe_timer > 224)
				{
					e.t = 10;
					e.ce = BSS_COLLECT.GREEN_STOOD;
				}
				break;

			case BSS_COLLECT.GREEN_STOOD:
				if (state == BSS_STATE.MOVE)
				{
					e.t--;
					if (e.t <= 0)
					{
						if (pf[fp] == BSS_CELL.GREEN_STOOD) pf[fp] = BSS_CELL.BLUE;
						remove = true;
					}
				}
				break;

			case BSS_COLLECT.PINK:
				if (state == BSS_STATE.MOVE)
				{
					if (player_x != e.cx || player_y != e.cy)
					{
						if (pf[fp] == BSS_CELL.PINK_STOOD) pf[fp] = BSS_CELL.PINK;
						remove = true;
					}
				}
				break;
		}

		if (remove) array_delete(collected, i, 1);
	}
}

// Build the player + tail animators for the current character
function bss_setup_character()
{
	var _stand, _walk, _roll, _tail;
	switch (global.character)
	{
		case CHAR_TAILS:
			_stand = spr_bss_tails_stand;
			_walk  = spr_bss_tails_walk;
			_roll  = spr_bss_tails_roll;
			_tail  = spr_bss_tails_tail;
			break;
		case CHAR_KNUX:
			_stand = spr_bss_knuckles_stand;
			_walk  = spr_bss_knuckles_walk;
			_roll  = spr_bss_knuckles_roll;
			_tail  = noone;
			break;
		case CHAR_SONIC:
		default:
			_stand = spr_bss_sonic_stand;
			_walk  = spr_bss_sonic_walk;
			_roll  = spr_bss_sonic_roll;
			_tail  = noone;
			break;
	}

	//Keep the current pose when rebuilding over an existing animator
	var _had = variable_instance_exists(id, "animator");
	var _cur = _had ? animation_get_current_animation(animator) : BSS_ANIM.STAND;
	var _frm = _had ? animation_get_frame(animator) : 0;
	if (_cur < 0) _cur = BSS_ANIM.STAND;

	animator = new animator_create();
	animation_add(BSS_ANIM.STAND,  _stand, 0, 0, false);
	animation_add(BSS_ANIM.WALK,   _walk,  0, 0, true);
	animation_add(BSS_ANIM.JUMP,   _roll,  0, 0, true);
	animation_add(BSS_ANIM.SPRING, _roll,  0, 0, true);
	animation_play(animator, _cur);
	animation_set_frame(animator, _frm);

	has_tail = (_tail != noone);
	if (has_tail)
	{
		animation_add(BSS_ANIM.TAIL, _tail, 0, 0, true);
		tail_animator = new animator_create();
		animation_play(tail_animator, BSS_ANIM.TAIL);
	}
}

function bss_special_stage_start()
{
	global.bss.pf = [];
	array_copy(global.bss.pf, 0, global.bss.pf_stage, 0, global.bss.size);

	angle    = 0;
	player_x = 0;
	player_y = 0;
	bss_setup_start_info();

	ring_count      = ring_target;
	rings_collected = 0;

	state             = BSS_STATE.MOVE;
	globe_timer       = 0;
	globe_speed       = 0;
	globe_speed_inc   = 0;
	speedup_level     = 0;
	speedup_timer     = 0;
	speedup_interval  = 30 * 60;
	spin_state        = 0;
	spin_timer        = 0;
	palette_page      = 0;
	palette_line      = 0;
	player_was_bumped = false;
	disable_bumpers   = false;
	timer_100         = 0;
	tele_timer        = 0;
	globe_hidden      = false;
	turn_frame        = 0;
	turn_flip         = 0;
	exit_timer        = 0;
	medal_spin        = 0;
	reward_is_emerald = false;
	emerald_index     = 0;
	stage_failed      = false;
	bg_scroll_x       = 0;
	bg_scroll_y       = 0;

	//player (BSS_Player entity)
	on_ground        = true;
	velocity_y       = 0;
	gravity_strength = 0;
	walk_timer       = 0;
	roll_timer       = 0;
	input_active     = true;
	animation_play(animator, BSS_ANIM.STAND);

	collected = [];

	//intro (BSS_Message GETSPHERES)
	msg_phase      = 0;   //0 = fade-in, 1 = wait, 2 = sliding out, 3 = gone
	msg_fade_timer = 512;
	msg_wait_timer = 0;
	intro_offset   = 0;   //slide-out offset once the globe starts

	//PERFECT message (BSS_Message)
	perfect_active = false;
	perfect_phase  = 0;
	perfect_offset = 320;
	perfect_wait   = 0;

	ring_spin       = 0;
	ring_spin_timer = 0;
	spark_spin_timer = 0;
	global.bss.ring_phase = 0;
	global.bss.spark_phase = 0;
}

// Mania's BSS_Setup_SetupFrustum converts hand-authored tiles from layers "Frustum 1" and "Frustum 2" into offset values.
// We'll just use these offset values right away instead.
function bss_frustum_tables() {
	global.bss.frustum1X = [
	-5,5,-4,4,-5,5,-3,3,-4,4,-2,2,-1,1,0,-3,3,-4,4,-2,2,-1,1,0,-3,3,-4,4,-2,2,
	-3,3,-1,1,0,-2,2,-3,3,-1,1,-3,3,0,-2,2,-1,1,-2,2,0,-2,2,-1,1,0,-1,1,0
];
	global.bss.frustum1Y = [
	-6,-6,-6,-6,-5,-5,-6,-6,-5,-5,-6,-6,-6,-6,-6,-5,-5,-4,-4,-5,-5,-5,-5,-5,-4,-4,-3,-3,-4,-4,
	-3,-3,-4,-4,-4,-3,-3,-2,-2,-3,-3,-1,-1,-3,-2,-2,-2,-2,-1,-1,-2,0,0,-1,-1,-1,0,0,0
];
	global.bss.frustum2X = [
	-4,4,-4,4,-3,3,-4,4,-4,4,-3,3,-2,2,-4,4,-4,4,-2,2,-3,3,-3,3,-1,1,-4,4,-4,4,
	-1,1,0,-4,4,0,-2,2,-3,3,-3,3,-2,2,-1,1,-3,3,-3,3,-1,1,0,-3,3,0,-2,2,-2,2,
	-1,1,-2,2,-2,2,-1,1,0,-2,2,0,-1,1,-1,1,0,-1,1,0,0
];
	global.bss.frustum2Y = [
	-4,-4,4,4,-4,-4,-3,-3,3,3,4,4,-4,-4,-2,-2,2,2,4,4,-3,-3,3,3,-4,-4,-1,-1,1,1,
	4,4,-4,0,0,4,-3,-3,-2,-2,2,2,3,3,-3,-3,-1,-1,1,1,3,3,-3,0,0,3,-2,-2,2,2,
	-2,-2,-1,-1,1,1,2,2,-2,0,0,2,-1,-1,1,1,-1,0,0,1,0
];
}
