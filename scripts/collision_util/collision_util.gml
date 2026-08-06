/// @self						
/// @description							Function that returns the distance between the set position and a solid surface
/// @param {Real} px						The horizontal position of the collision check
/// @param {Real} py						The vertical position of the collision check
/// @param {Real} [mode]					On which orentation collision will get tested on (The default is floor)
/// @param {Real} [plane]					On which plane can collision get tested on (The default is "Plane A")						
/// @param {Bool} [semi_solid]				Can it collide with semi solid tiles (By default it can't)
/// @return {Real}
function collision_get_distance(px, py, mode = COLLISION_MODE.FLOOR, plane = PLANE.A, semi_solid = false)
{
    px = floor(px);
    py = floor(py);

    var best_h = 9999;

    for (var i = 0; i < array_length(global.col_tile); i++)
    {
        var l = global.col_tile[i];
		
		
        if ((!semi_solid && l == "CollisionSemi") ||  (plane != PLANE.A && l == "CollisionA") ||  (plane != PLANE.B && l == "CollisionB"))
        {
            continue;
        }

        var h;

        switch (mode)
        {
            case COLLISION_MODE.FLOOR:
                h = _tile_get_height(px, py, l);
            break;

            case COLLISION_MODE.LEFT_WALL:
                h = _tile_get_width(px, py, l);
            break;

            case COLLISION_MODE.CEILING:
                h = _tile_get_height(px, py - 1, l, true);
            break;

            case COLLISION_MODE.RIGHT_WALL:
                h = _tile_get_width(px - 1, py, l, true);
            break;
        }

        if (h < best_h)
            best_h = h;
    }

    return best_h;
}

/// @self						
/// @description							Function that takes the left side and right side of the tile surface and calculates the angle between them (In degrees)
/// @param {Real} px						The horizontal position of the collision check
/// @param {Real} py						The vertical position of the collision check
/// @param {Real} [mode]					On which orentation collision will get tested on (The default is floor)
/// @param {Real} [plane]					On which plane can collision get tested on (The default is "Plane A")						
/// @return {Real}
function collision_get_angle(px, py, mode = COLLISION_MODE.FLOOR, plane = PLANE.A)
{
	px = floor(px);
	py = floor(py);
	
	// Points
	var ax, bx, ay, by; 
	
	switch(mode)
	{
		case COLLISION_MODE.FLOOR:
			ax = px - px mod ANGLE_GRID_SIZE;
			bx = px + ((ANGLE_GRID_SIZE - 1) - px mod ANGLE_GRID_SIZE);
			ay = collision_get_distance(ax, py, mode, plane, true);	
			by = collision_get_distance(bx, py, mode, plane, true);
		break;
		
		case COLLISION_MODE.LEFT_WALL:
			by = py - py mod ANGLE_GRID_SIZE;
			ay = py + ((ANGLE_GRID_SIZE - 1) - py mod ANGLE_GRID_SIZE);
			ax = collision_get_distance(px, ay, mode, plane, true);	
			bx = collision_get_distance(px, by, mode, plane, true);
		break;
		
		case COLLISION_MODE.CEILING:
			bx = px - px mod ANGLE_GRID_SIZE;
			ax = px + ((ANGLE_GRID_SIZE - 1) - px mod ANGLE_GRID_SIZE);
			by = collision_get_distance(ax, py, mode, plane, true);	
			ay = collision_get_distance(bx, py, mode, plane, true);
		break;
		
		case COLLISION_MODE.RIGHT_WALL:
			ay = py - py mod ANGLE_GRID_SIZE;
			by = py + ((ANGLE_GRID_SIZE - 1) - py mod ANGLE_GRID_SIZE);
			bx = collision_get_distance(px, ay, mode, plane, true);	
			ax = collision_get_distance(px, by, mode, plane, true);
		break;
	}
	var angle = point_direction(ax, ay, bx, by);
	
	return angle;
}

/// @self						
/// @description							This functions has 3 collision checks, on the left, on the middle and on the right, and it returns the distance of a sensor that is the closest to the surface. It returns a struct that contains the distance of an active sensor and an angle of the active sensor
/// @param {Real} radius_x					The horizontal radius offset of the collision check
/// @param {Real} radius_y					The vertical radius offset of the collision check
/// @param {Real} [mode]					On which orentation collision will get tested on (The default is floor)
/// @param {Real} [plane]					On which plane can collision get tested on (The default is "Plane A")						
/// @param {Bool} [semi_solid]				Can it collide with semi solid tiles (By default it can't)
/// @return {Real}
function collision_active_sensor(radius_x, radius_y, mode = COLLISION_MODE.FLOOR, plane = PLANE.A, semi_solid = false)
{
	// Default struct
	var colResult = {
		height : 0,
		angle : 0
	}
	
	//Change direction
	var x_dir = dsin(90 * mode);
	var y_dir = dcos(90 * mode);
	
	// Get the correct point position
	var pxL = x - radius_x * y_dir + radius_y * x_dir;
	var pyL = y + radius_y * y_dir - radius_x * -x_dir;
	
	var pxM = x + 0 * y_dir + radius_y * x_dir;
	var pyM = y + radius_y * y_dir + 0 * -x_dir;
	
	var pxR = x + radius_x * y_dir + radius_y * x_dir;
	var pyR = y + radius_y * y_dir + radius_x * -x_dir;
	
	// Get all of 3 sensors
	var heightL = collision_get_distance(pxL, pyL, mode, plane, semi_solid);
	var heightM = collision_get_distance(pxM, pyM, mode, plane, semi_solid);
	var heightR = collision_get_distance(pxR, pyR, mode, plane, semi_solid);
	
	// Default to the left sensor
	colResult.height = heightL;
	colResult.angle = collision_get_angle(pxL, pyL, mode, plane);
	
	// Set the result to the middle sensor
	if(heightM < colResult.height)
	{
		colResult.height = heightM;
		colResult.angle = collision_get_angle(pxM, pyM, mode, plane);
	}
	
	// Set the result to the right sensor
	if(heightR < colResult.height)
	{
		colResult.height = heightR;
		colResult.angle = collision_get_angle(pxR, pyR, mode, plane);
	}
	
	// Make angle flat if the results of the height are also flat
	if(colResult.height == heightL && (heightL == heightM || heightL == heightR)) ||
	(colResult.height == heightM && heightM == heightR)
	{
		colResult.angle = 90 * mode;
	}
	
    return colResult;
}

// ===========================================================================================================
// Internal utility functions
// ===========================================================================================================
/// @self												
/// @param {Real} xpos						The horizontal position of the collision check
/// @param {Real} ypos						The vertical position of the collision check
/// @param {String} [l]						On which collision layer are we getting the data from
/// @param {Real} [flip]					Is the collision side flipped? (By default it is not)				
/// @return {Real}
function _tile_get_height2(xpos, ypos, l = "CollisionMain", flip = false)
{

	xpos = floor(xpos);
	ypos = floor(ypos);
	
	// Get the tile layer
	var layer_id = layer_tilemap_get_id(l);
	
	var cellX = floor(xpos / 16);
	var cellY = floor(ypos / 16);
	
	// Get the height from active tile ID
	var tile_id = tilemap_get(layer_id, cellX, cellY);
	var tile_sprite = layer_tilemap_get_colmask(layer_id)
	var height = _tiledata_get_height(tile_id, tile_sprite, xpos, flip);
	
	// Flip height
	if(flip)
		height = -height;
	
	// Return the correct distance
	if(height > 0)
	{
		return 15 - (height + (ypos & 15));	
			
	}
	else if(height < 0)
	{
		if(height + (ypos & 15) < 0)
			return (ypos & 15) ^ ~0;
	}
	
	return 15 - (ypos & 15);
}

/// @self						
/// @description							An internal function used for getting collision surface distance, Vertical axis
/// @param {Real} xpos						The horizontal position of the collision check
/// @param {Real} ypos						The vertical position of the collision check
/// @param {String} [l]						On which collision layer are we getting the data from
/// @param {Real} [flip]					Is the collision side flipped? (By default it is not)				
/// @return {Real}
function _tile_get_height(xpos, ypos, l = "CollisionMain", flip = false)
{
	xpos = floor(xpos);
	ypos = floor(ypos);
	
	// Get the tile layer
	var layer_id = layer_tilemap_get_id(l);
	
	// Get cell's position
	var cellX = floor(xpos / 16);
	var cellY = floor(ypos / 16);
	
	// Get the height from active tile ID
	var tile_id = tilemap_get(layer_id, cellX, cellY);
	var tile_sprite = layer_tilemap_get_colmask(layer_id)
	var height = _tiledata_get_height(tile_id, tile_sprite, xpos, flip);
	
	// Second pass offset
	var a = 16;
	
	// Flip everything needed
	if(flip)
	{
		ypos ^= 15
		height = -height;
		a = -a;
	}
	
	// Return the correct distance
	if(height > 0)
	{
		if(height != 16)
		{
			return 15 - (height + (ypos & 15));	
		}
		else
			return _tile_get_height2(xpos, ypos - a, l, flip) - 16;
			
	}
	else
	{
		if(height + (ypos & 15) < 0)
			return _tile_get_height2(xpos, ypos - a, l, flip) - 16; 
	}
	
	return _tile_get_height2(xpos, ypos + a, l, flip) + 16;
}

/// @self						
/// @description							
/// @param {Real} xpos						The horizontal position of the collision check
/// @param {Real} ypos						The vertical position of the collision check
/// @param {String} [l]						On which collision layer are we getting the data from
/// @param {Real} [flip]					Is the collision side flipped? (By default it is not)				
/// @return {Real}
function _tile_get_width2(xpos, ypos, l = "CollisionMain", flip = false)
{
	xpos = floor(xpos);
	ypos = floor(ypos);
	
	// Get the tile layer
	var layer_id = layer_tilemap_get_id(l);
	
	// Get cell's position
	var cellX = floor(xpos / 16);
	var cellY = floor(ypos / 16);
	
	// Get the height from active tile ID
	var tile_id = tilemap_get(layer_id, cellX, cellY);
	var tile_sprite = layer_tilemap_get_colmask(layer_id)
	var height = _tiledata_get_width(tile_id, tile_sprite, ypos, flip);
	
	// Second pass offset
	var a = 16;
	
	// Flip everything needed
	if(flip)
		height = -height;

	// Return the correct distance
	if(height > 0)
	{
		return 15 - (height + (xpos & 15));	
			
	}
	else if(height < 0)
	{
		if(height + (xpos & 15) < 0)
			return (xpos & 15) ^ ~0;
	}
	
	return 15 - (xpos & 15);
}

/// @self						
/// @description							An internal function used for getting collision surface distance, Horizontal axis
/// @param {Real} xpos						The horizontal position of the collision check
/// @param {Real} ypos						The vertical position of the collision check
/// @param {String} [l]						On which collision layer are we getting the data from
/// @param {Real} [flip]					Is the collision side flipped? (By default it is not)				
/// @return {Real}
function _tile_get_width(xpos, ypos, l = "CollisionMain", flip = false)
{
	xpos = floor(xpos);
	ypos = floor(ypos);
	
	// Get the tile layer
	var layer_id = layer_tilemap_get_id(l);
	
	// Get cell's position
	var cellX = floor(xpos / 16);
	var cellY = floor(ypos / 16);
	
	// Get the height from active tile ID
	var tile_id = tilemap_get(layer_id, cellX, cellY);
	var tile_sprite = layer_tilemap_get_colmask(layer_id)
	var height = _tiledata_get_width(tile_id, tile_sprite, ypos, flip);
	
	// Second pass offset
	var a = 16;
	
	// Flip everything needed
	if(flip)
	{
		xpos ^= 15
		height = -height;
		a = -16;
	}
	
	// Return the correct distance
	if(height > 0)
	{
		if(height != 16)
		{
			return 15 - (height + (xpos & 15));	
		}
		else
			return _tile_get_width2(xpos - a, ypos, l, flip) - 16;
			
	}
	else
	{
		if(height + (xpos & 15) < 0)
			return _tile_get_width2(xpos - a, ypos, l, flip) - 16; 
	}
	
	return _tile_get_width2(xpos + a, ypos, l, flip) + 16;
}

// ==========================================================================================
// Tile data segment
// ==========================================================================================
/// @self						
/// @description							An internal function used for getting a height map data.
/// @param {Real} tile_id					Which tile data is being used
/// @param {Asset.GMSprite} tile_sprite		Which tilemap sprite is being refrence
/// @param {Real} xpos						The horizontal height map offset
/// @param {Real} [flip]					Is the collision side flipped? (By default it is not)				
/// @return {Real}
function _tiledata_get_height(tile_id, tile_sprite, xpos, flip = false)
{
	// Turn X position into an offset
	if((!tile_get_mirror(tile_id) && !tile_get_rotate(tile_id))|| (tile_get_rotate(tile_id) && tile_get_flip(tile_id)))
		xpos %= 16;
	else
		xpos = 15 - xpos % 16;
	
	// Get the tile ID
	var index = tile_get_index(tile_id);
	
	// Return blank height if the tile is invalid
	if(index <= 0 || index > array_length(global.tile_top[? tile_sprite]))
	{
		return 0;
	}
	
	// Up direction collision height
	if(flip)
	{
		if(tile_get_rotate(tile_id)) {
			if (tile_get_mirror(tile_id)) {
				return -global.tile_left[? tile_sprite][index][xpos];
			} else {
				return -global.tile_right[? tile_sprite][index][xpos];
			}
		}
		
		
		// Return collision height if the tile is flipped
		if(tile_get_flip(tile_id))
			return -global.tile_top[? tile_sprite][index][xpos];
		
		// Otherwise default to the normal one
		return -global.tile_bottom[? tile_sprite][index][xpos];
	}
	else	// Down direction
	{
		if(tile_get_rotate(tile_id)) {
			if (tile_get_mirror(tile_id)) {
				return global.tile_right[? tile_sprite][index][xpos];
			} else {
				return global.tile_left[? tile_sprite][index][xpos];
			}
		}
		
		// Return collision height if the tile is flipped
		if(tile_get_flip(tile_id))
			return global.tile_bottom[? tile_sprite][index][xpos];
		
		// Otherwise default to the normal one
		return global.tile_top[? tile_sprite][index][xpos];
	}
}

/// @self						
/// @description							An internal function used for getting a height map data.
/// @param {Real} tile_id					Which tile data is being used
/// @param {Asset.GMSprite} tile_sprite		Which tilemap sprite is being refrence
/// @param {Real} ypos						The horizontal height map offset
/// @param {Real} [flip]					Is the collision side flipped? (By default it is not)				
/// @return {Real}
function _tiledata_get_width(tile_id, tile_sprite, ypos, flip = false)
{
	// Turn X position into an offset
	if((!tile_get_flip(tile_id) && !tile_get_rotate(tile_id))|| (!tile_get_mirror(tile_id) && tile_get_rotate(tile_id)))
		ypos %= 16;
	else
		ypos = 15 - ypos % 16;
	
	// Get the tile ID
	var index = tile_get_index(tile_id);
	
	// Return blank height if the tile is invalid
	if(index <= 0 || index > array_length(global.tile_top[? tile_sprite]))
	{
		return 0;
	}
	
	// Up direction collision height
	if(flip)
	{
		if(tile_get_rotate(tile_id)) {
			if(tile_get_flip(tile_id)){
				return -global.tile_bottom[? tile_sprite][index][ypos];
			}
			return -global.tile_top[? tile_sprite][index][ypos];
		}
		
		
		// Return collision height if the tile is flipped
		if(tile_get_mirror(tile_id))
			return -global.tile_left[? tile_sprite][index][ypos];	
			
		// Otherwise default to the normal one
		return -global.tile_right[? tile_sprite][index][ypos];
	}
	else
	{
		if(tile_get_rotate(tile_id)) {
			if(tile_get_flip(tile_id)){
				return global.tile_top[? tile_sprite][index][ypos];
			}
			return global.tile_bottom[? tile_sprite][index][ypos];
		}
		
		// Return collision height if the tile is flipped
		if(tile_get_mirror(tile_id))
			return global.tile_right[? tile_sprite][index][ypos];
			
		// Otherwise default to the normal one
		return global.tile_left[? tile_sprite][index][ypos];	
	}
}
