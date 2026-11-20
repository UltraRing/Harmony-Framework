// This is where you configure the Blue Spheres engine: its characters and cells.
// Settings for each stage (music, palette, S3&K rules...) go in its room creation code, see obj_bss_controller's Create event

/// @self								obj_bss_controller
/// @description						Sprites for each character, in CHAR_* order. Characters missing from the list use Sonic's
/// @returns {Array<Struct>}
function bss_config_characters()
{
	return
	[
		{ stand : spr_bss_sonic_stand,    walk : spr_bss_sonic_walk,    roll : spr_bss_sonic_roll,    tail : noone },				// CHAR_SONIC
		{ stand : spr_bss_tails_stand,    walk : spr_bss_tails_walk,    roll : spr_bss_tails_roll,    tail : spr_bss_tails_tail },	// CHAR_TAILS
		{ stand : spr_bss_knuckles_stand, walk : spr_bss_knuckles_walk, roll : spr_bss_knuckles_roll, tail : noone },				// CHAR_KNUX
	];
}

/// @self								obj_bss_controller
/// @description						Defines the cells you paint. A cell's number is its tile's index in tex_tile_bss_editor: add your tiles
///										to the end of it, from BSS_CELL_CUSTOM (12) up to 999. See stage_bss_cells for every property.
///										Runs after the engine defines its own cells, so it can override those too
function bss_config_cells()
{
	bss_cell_define(BSS_CELL.BLUE, { sprite : spr_bss_sphere_blue, required : true, touch : bss_touch_blue });
	bss_cell_define(BSS_CELL.RED, { sprite : spr_bss_sphere_red, blocks_teleport : true, touch : bss_touch_red });
	bss_cell_define(BSS_CELL.BUMPER, { sprite : spr_bss_bumper, blocks_teleport : true, touch : bss_touch_bumper });
	bss_cell_define(BSS_CELL.YELLOW, { sprite : spr_bss_sphere_yellow, touch : bss_touch_yellow });
	bss_cell_define(BSS_CELL.GREEN, { sprite : spr_bss_sphere_green, required : true, touch : bss_touch_green });
	bss_cell_define(BSS_CELL.PINK, { sprite : spr_bss_sphere_pink, blocks_teleport : true, touch : bss_touch_pink });
	bss_cell_define(BSS_CELL.RING, { draw : bss_draw_ring, touch : bss_touch_ring });
	
	bss_cell_define(BSS_CELL.SPAWN_UP,    { spawn_angle : 0x00 });
	bss_cell_define(BSS_CELL.SPAWN_RIGHT, { spawn_angle : 0x40 });
	bss_cell_define(BSS_CELL.SPAWN_DOWN,  { spawn_angle : 0x80 });
	bss_cell_define(BSS_CELL.SPAWN_LEFT,  { spawn_angle : 0xC0 });
	
	// Your own cells go here. Example, a sphere that springs the player and disappears:
	//
	//	bss_cell_define(BSS_CELL_CUSTOM,
	//	{
	//		sprite : spr_bss_sphere_yellow,
	//		touch : function(_x, _y, _ahead)
	//		{
	//			if(!bss_touch_reached(_ahead)) return;
	//			bss_cell_set(_x, _y, BSS_CELL.NONE);
	//			bss_spring();
	//		},
	//	});
}
