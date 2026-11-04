// Blue Spheres cell types. Every board cell value, built-in or custom, has a type in the controller's cell_types.
// The ones you paint are defined in bss_config_cells (stage_bss_config), the ones the engine places in bss_cells_init.
// A single stage can also define or override them from its room creation code:
//	with(obj_bss_controller) bss_cell_define(BSS_CELL_CUSTOM, { ... });
//
// Properties (all optional):
//	sprite			Sphere sprite with one frame per two scale steps, drawn by bss_draw_sphere
//	alpha			Draw alpha for bss_draw_sphere
//	draw			function(_type, _x, _y, _scale) to draw it yourself, scale goes from 0 (far) to 31 (near)
//	touch			function(_x, _y, _ahead) run every frame the globe touches cells, for the cell under the player (_ahead = false)
//					and the cell in front (_ahead = true). Use bss_touch_reached(_ahead) for regular pick-up timing
//	kind			What it counts as for ring loops and teleports, BSS_CELL.BLUE / RED / PINK... Ring loops take BLUE ones
//					off sphere_count, so only give that kind to cells that are counted, like required ones
//	required		Counted in sphere_count at the start. Call bss_collect_required() when it's collected
//	blocks_teleport	A pink sphere teleport won't send the player out toward it
//	spawn_angle		Marks the start, facing this angle (0x00 up, 0x40 right, 0x80 down, 0xC0 left)
//
// Touch and draw functions run on obj_bss_controller, so the bss_* helpers and stage variables work inside them.

/// @self								obj_bss_controller
/// @description						Defines the cells the engine places, then the rest with bss_config_cells
function bss_cells_init()
{
	cell_types = [];
	
	bss_cell_define(BSS_CELL.SPARKLE, { draw : bss_draw_sparkle });
	bss_cell_define(BSS_CELL.EMERALD_CHAOS, { sprite : spr_bss_chaos_emerald, draw : bss_draw_emerald, touch : bss_touch_reward });
	bss_cell_define(BSS_CELL.MEDAL_SILVER, { sprite : spr_bss_medal_silver, draw : bss_draw_medal, touch : bss_touch_reward });
	bss_cell_define(BSS_CELL.MEDAL_GOLD, { sprite : spr_bss_medal_gold, draw : bss_draw_medal, touch : bss_touch_reward });
	
	// Touched spheres, drawn see-through until they change into their kind
	bss_cell_define(BSS_CELL.GREEN_STOOD, { sprite : spr_bss_sphere_green, alpha : 0.5, kind : BSS_CELL.BLUE });
	bss_cell_define(BSS_CELL.BLUE_STOOD, { sprite : spr_bss_sphere_blue, alpha : 0.5, kind : BSS_CELL.RED });
	bss_cell_define(BSS_CELL.PINK_STOOD, { sprite : spr_bss_sphere_pink, alpha : 0.5, kind : BSS_CELL.PINK });
	
	bss_config_cells();
}

/// @self								obj_bss_controller
/// @description						Defines or overrides a cell type
/// @param {Real} _id					Cell number, also its tile index in tex_tile_bss_editor
/// @param {Struct} _props				Properties to set, see the top of this script
function bss_cell_define(_id, _props)
{
	// Numbers skipped on the way get blank types
	while(array_length(cell_types) <= _id)
	{
		array_push(cell_types,
		{
			defined : false,
			sprite : undefined,
			alpha : 1,
			draw : bss_draw_sphere,
			touch : undefined,
			kind : array_length(cell_types),
			required : false,
			blocks_teleport : false,
			spawn_angle : -1,
		});
	}
	
	var _type = cell_types[_id];
	_type.defined = true;
	
	var _names = variable_struct_get_names(_props);
	for (var i = 0; i < array_length(_names); i++)
	{
		var _value = _props[$ _names[i]];
		
		// Functions written inline get unbound so they run on the controller
		if(is_method(_value)) _value = method(undefined, _value);
		_type[$ _names[i]] = _value;
	}
}

/// @self								obj_bss_controller
/// @description						Returns the type of a cell value
/// @param {Real} _cell					Cell value
/// @returns {Struct}
function bss_cell_type(_cell)
{
	return cell_types[_cell];
}

/// @self								obj_bss_controller
/// @description						Returns what a cell value counts as, see the kind property
/// @param {Real} _cell					Cell value
/// @returns {Real}
function bss_cell_kind(_cell)
{
	return cell_types[_cell].kind;
}

/// @self								obj_bss_controller
/// @description						Regular pick-up timing: the cell under the player in the first half of the roll, the one ahead in the second half
/// @param {Bool} _ahead				The touch function's ahead argument
/// @returns {Bool}
function bss_touch_reached(_ahead)
{
	return _ahead ? (cell_progress > 128) : (cell_progress < 128);
}

// Blue sphere: turns red once the player has rolled clear of it

function bss_touch_blue(_x, _y, _ahead)
{
	if(bss_touch_reached(_ahead)) bss_collect_blue(_x, _y);
}

/// @self								obj_bss_controller
/// @description						Collects the blue sphere at (_x, _y), turning any loop it closes into rings
/// @param {Real} _x					Cell x
/// @param {Real} _y					Cell y
function bss_collect_blue(_x, _y)
{
	if(s3k_ring_conversion)
		_bss_collect_blue_s3k(_x, _y);
	else
	{
		last_sphere_x = _x;
		last_sphere_y = _y;
		sphere_count -= bss_chain_convert();
		
		if(!chain_closed)
		{
			bss_add_event(_x, _y, bss_event_blue);
			board[_x][_y] = BSS_CELL.BLUE_STOOD;
		}
	}
	
	// Last one, the board flies off
	if(!bss_collect_required()) sound_play(sfx_blue_sphere);
}

// S3&K: becomes a ring itself if it closed a loop
function _bss_collect_blue_s3k(_x, _y)
{
	board[_x][_y] = BSS_CELL.BLUE_STOOD;
	var _converted = bss_chain_convert_s3k(_x, _y);
	sphere_count -= _converted;
	if(_converted > 0)
		board[_x][_y] = BSS_CELL.RING;
	else
		bss_add_event(_x, _y, bss_event_blue_s3k);
}

function bss_event_blue(_event)
{
	var _gx = _event.gx;
	var _gy = _event.gy;
	
	if(_event.phase == 0)
	{
		if(sphere_count <= 0)
		{
			if(board[_gx][_gy] == BSS_CELL.BLUE_STOOD) board[_gx][_gy] = BSS_CELL.RED;
			return true;
		}
		if(cell_progress < 32 || cell_progress > 224) _event.phase = 1;
		return false;
	}
	
	if(state != bss_state_move || cell_progress <= 32 || cell_progress >= 224) return false;
	
	if(board[_gx][_gy] == BSS_CELL.BLUE_STOOD) board[_gx][_gy] = BSS_CELL.RED;
	return true;
}

// S3&K: turns red 10 frames later, once the player is off the cell center
function bss_event_blue_s3k(_event)
{
	if(++_event.timer <= 10 || _bss_on_center_s3k()) return false;
	
	if(board[_event.gx][_event.gy] == BSS_CELL.BLUE_STOOD) board[_event.gx][_event.gy] = BSS_CELL.RED;
	return true;
}

// Red sphere: ends the stage, only right on top of it

function bss_touch_red(_x, _y, _ahead)
{
	if(state != bss_state_exit && (_ahead ? cell_progress > 224 : cell_progress < 32))
	{
		bss_end_stage(true);
		if(_ahead) bss_advance(1);
	}
}

// Bumper: bounces the player back

function bss_touch_bumper(_x, _y, _ahead)
{
	if(s3k_bumpers)
	{
		_bss_touch_bumper_s3k(_x, _y, _ahead);
		return;
	}
	
	if(disable_bumpers) return;
	
	// Bounces back off the one ahead, or forward again off the one under the player when rolling back into it
	if(_ahead)
	{
		if(cell_progress > 144 && move_speed > 0 && (cell_progress < 240 || queued_turn == 0))
		{
			if(cell_progress >= 240) cell_progress = 240;
			bss_bounce(true);
		}
	}
	else if(cell_progress < 112 && move_speed < 0 && (cell_progress > 16 || queued_turn == 0))
	{
		if(cell_progress <= 16) cell_progress = 16;
		bss_bounce(false);
	}
}

/// @self								obj_bss_controller
/// @description						Reverses the globe, ignoring bumpers until the player is near a cell center
/// @param {Bool} _bumped_back			Keep rolling backwards until up is held
function bss_bounce(_bumped_back)
{
	disable_bumpers = true;
	move_speed = -move_speed;
	bumped_back = _bumped_back;
	sound_play(sfx_bumper);
}

// S3&K: bounces whenever it's the nearest cell, whichever way the player rolls,
// pushes the player back to the center of another cell, then rolls away backwards (_bss_roll_speed_s3k)
function _bss_touch_bumper_s3k(_x, _y, _ahead)
{
	if(bumper_hit || _ahead != _bss_ahead_is_nearest_s3k()) return;
	
	bumper_hit = true;
	bumper_x = _x;
	bumper_y = _y;
	bumped_back = true;
	sound_play(sfx_bumper);
}

// Yellow sphere: springs the player over the next cells

function bss_touch_yellow(_x, _y, _ahead)
{
	if(bss_touch_reached(_ahead)) bss_spring();
}

/// @self								obj_bss_controller
/// @description						Launches the player high, doubling the speed until landing
function bss_spring()
{
	jump_speed = BSS_SPRING_SPEED;
	jump_queued = false;
	on_ground = false;
	animation_play(animator, BSS_ANIM.SPRING);
	roll_timer = 0;
	move_speed *= 2;
	queued_turn = 0;
	acceleration = 4;
	sound_play(sfx_spring);
}

// Green sphere: turns blue once collected, so it takes two passes

// Like Mania, the cell under the player is collected past the middle too
function bss_touch_green(_x, _y, _ahead)
{
	if(cell_progress > 128) bss_collect_green(_x, _y);
}

/// @self								obj_bss_controller
/// @description						Collects the green sphere at (_x, _y), it turns blue shortly after
/// @param {Real} _x					Cell x
/// @param {Real} _y					Cell y
function bss_collect_green(_x, _y)
{
	bss_add_event(_x, _y, bss_event_green);
	board[_x][_y] = BSS_CELL.GREEN_STOOD;
	sound_play(sfx_blue_sphere);
}

function bss_event_green(_event)
{
	if(_event.phase == 0)
	{
		if(cell_progress < 32 || cell_progress > 224)
		{
			_event.timer = 10;
			_event.phase = 1;
		}
		return false;
	}
	
	if(state != bss_state_move || --_event.timer > 0) return false;
	
	if(board[_event.gx][_event.gy] == BSS_CELL.GREEN_STOOD) board[_event.gx][_event.gy] = BSS_CELL.BLUE;
	return true;
}

// Pink sphere: teleports the player to another one, usable again once they leave it

function bss_touch_pink(_x, _y, _ahead)
{
	if(!_ahead && state != bss_state_teleport_in && cell_progress < 64) bss_start_teleport();
}

function bss_event_pink(_event)
{
	if(state != bss_state_move || (player_x == _event.gx && player_y == _event.gy)) return false;
	
	if(board[_event.gx][_event.gy] == BSS_CELL.PINK_STOOD) board[_event.gx][_event.gy] = BSS_CELL.PINK;
	return true;
}

// Ring: sparkles, then frees the cell

function bss_touch_ring(_x, _y, _ahead)
{
	if(bss_touch_reached(_ahead)) bss_collect_ring(_x, _y);
}

/// @self								obj_bss_controller
/// @description						Collects the ring at (_x, _y)
/// @param {Real} _x					Cell x
/// @param {Real} _y					Cell y
function bss_collect_ring(_x, _y) //BSS_Setup_CollectRing
{
	bss_add_event(_x, _y, bss_event_ring);
	board[_x][_y] = BSS_CELL.SPARKLE;
	rings_collected++;
	sound_play(sfx_ring);
	
	if(ring_count > 0)
	{
		ring_count--;
		if(ring_count == 0) bss_show_perfect();
	}
}

function bss_event_ring(_event)
{
	_event.timer++;
	if(_event.timer < 16 || state != bss_state_move) return false;
	
	board[_event.gx][_event.gy] = BSS_CELL.NONE;
	return true;
}

// Emeralds and medals: reaching one clears the stage

function bss_touch_reward(_x, _y, _ahead)
{
	if(_ahead && cell_progress > 240)
	{
		bss_end_stage(false);
		bss_advance(1);
	}
}
