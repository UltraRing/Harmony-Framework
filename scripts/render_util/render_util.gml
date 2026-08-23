// ===========================================================================================================
// Draw utility functions
// ===========================================================================================================

/// @self									
/// @description						Function used for drawing tiled sprite (Improved over gamemaker's default one)
/// @param {Asset.GMSprite} sprite		The sprite that will be drawn
/// @param {Real} subimg				The frame of the sprite
/// @param {Real} x						Horizontal position of the sprite
/// @param {Real} y						Vertical position of the sprite
/// @param {Real} [type]				The looping direction of the sprite
function draw_sprite_tiled_new(sprite, subimg, x, y, type = 0)
{
	var sprW = sprite_get_width(sprite);
	var sprH = sprite_get_height(sprite);
	
	var camX = camera_get_view_x(view_camera[view_current]);
	var camY = camera_get_view_y(view_camera[view_current]);
	var camW = camera_get_view_width(view_camera[view_current]);
	var camH = camera_get_view_height(view_camera[view_current]);
	
	var offsetX = x mod sprW;
	var offsetY = y mod sprH;
	
	var startTileX = floor((camX - offsetX) / sprW) - 1;
    var endTileX = ceil((camX + camW - offsetX) / sprW) + 1;
	var startTileY = floor((camY - offsetY) / sprH) - 1;
    var endTileY = ceil((camY + camH - offsetY) / sprH) + 1;
	
	switch(type)
	{
		default:
		case 0:
			for (var i = startTileX; i <= endTileX; i++)
		    {
				draw_sprite(sprite, subimg, offsetX + i * sprW, y);
		    }
		break;
		

		case 1:
			for (var i = startTileY; i <= endTileY; i++)
		    {
				draw_sprite(sprite, subimg, x, offsetY + i * sprH);
		    }
		break;
		
		case 2:
			for (var i = startTileX; i <= endTileX; i++)
		    {
				for (var j = startTileY; j <= endTileY; j++)
				{
					draw_sprite(sprite, subimg, offsetX + i * sprW, offsetY + j * sprH);
				}
		    }
		break;
	}
}

/// @self									
/// @description						Function used for drawing the object with positions being floored
function draw_self_floor()
{
	//Only purpose of this is because of GameMaker's horrible sub - pixeling
	draw_sprite_ext(sprite_index, image_index, floor(x) , floor(y), image_xscale, image_yscale, image_angle, draw_get_color(), draw_get_alpha());
}

/// @self								
/// @description						Function that draws the sprite using the animation system
/// @param {Struct} animator			The animation system struct that will be used
/// @param {Real} [pos_x]				The horizontal sprite position (The default is floored X position of the object)
/// @param {Real} [pos_y]				The vertical sprite position (The default is floored Y position of the object)
/// @param {Real} [x_scale]				The horizontal scale of the sprite (The default is x scale of the object)
/// @param {Real} [y_scale]				The vertical scale of the sprite (The default is y scale of the object)
/// @param {Real} [angle]				The angle of the sprite (The default is the sprite angle of the object | In degrees)
/// @param {Real} [color]				The sprite tint color (The default is object's tint color)
/// @param {Real} [alpha]				The alpha blend of the sprite (The default is alpha of the object)
function draw_animator(animator, pos_x = floor(x), pos_y = floor(y), x_scale = image_xscale, y_scale = image_yscale, angle = image_angle, color = image_blend, alpha = image_alpha)
{	
	draw_sprite_ext(animator.animation_sprite, animator.animation_frame, pos_x, pos_y, x_scale, y_scale, angle, color, alpha);
}

/// @self									
/// @description						Function that pushes the current rendering state to the rendering stack
function draw_state_push()
{
	
	global.draw_state_holder = 
	{
		col : draw_get_colour(),
		alpha : draw_get_alpha(),
		halign : draw_get_halign(),
		valign : draw_get_valign(),
		font : draw_get_font(),
        blendmode : gpu_get_blendmode(),
        blendmode_ext : gpu_get_blendmode_ext(),
        colourwriteenable : gpu_get_colourwriteenable(),
        cullmode : gpu_get_cullmode(),
        fog : gpu_get_fog(),
        ztestenable : gpu_get_ztestenable(),
        zfunc : gpu_get_zfunc(),
        zwriteenable : gpu_get_zwriteenable(),
        alphatestenable : gpu_get_alphatestenable(),
        alphatestref : gpu_get_alphatestref(),
        filter : gpu_get_texfilter(),
        wrap : gpu_get_texrepeat(),
        shader : shader_current(),
        mw : matrix_get(matrix_world),
        mv : matrix_get(matrix_view),
        mp : matrix_get(matrix_projection)
    };
	
	ds_stack_push(global.draw_state, global.draw_state_holder);
}

/// @self									
/// @description						Function that restores the rendering state that was previously pushed to the stack
function draw_state_pop()
{
    var _state = ds_stack_pop(global.draw_state);
    
	draw_set_color(_state.col);
	draw_set_alpha(_state.alpha);
	
	draw_set_halign(_state.valign);
	draw_set_valign(_state.halign);
	draw_set_font(_state.font);
	
    gpu_set_blendmode(_state.blendmode);
    
    var blend_src = _state.blendmode_ext[0];
    var blend_dest = _state.blendmode_ext[1];
    gpu_set_blendmode_ext(blend_src, blend_dest);
    
    var colour_write = _state.colourwriteenable;
    gpu_set_colourwriteenable(colour_write[0], colour_write[1], colour_write[2], colour_write[3]);
    
    gpu_set_cullmode(_state.cullmode);
    
    var fog_data = _state.fog;
    gpu_set_fog(fog_data[0], fog_data[1], fog_data[2], fog_data[3]);
    
    gpu_set_ztestenable(_state.ztestenable);
    gpu_set_zfunc(_state.zfunc);
    gpu_set_zwriteenable(_state.zwriteenable);
    
    gpu_set_alphatestenable(_state.alphatestenable);
    gpu_set_alphatestref(_state.alphatestref);
    
    gpu_set_texfilter(_state.filter);
    gpu_set_texrepeat(_state.wrap);
    
    shader_set(_state.shader);
    
    matrix_set(matrix_world, _state.mw);
    matrix_set(matrix_view, _state.mv);
    matrix_set(matrix_projection, _state.mp);
}

/// @self									
/// @description						Function that makes everything drawn follow the viewport's camera
function draw_set_follow_camera()
{
	// Store because of the matrices
	draw_state_push();
	
	// Make the view matrix follow the camera
	matrix_set(matrix_view, matrix_build(-CAMERA_VIEW_W / 2, -CAMERA_VIEW_H / 2, 16000, 0, 0, 0, 1, 1, 1));
}

/// @self									
/// @description						Function that stops following the camera during the rendering
function draw_set_follow_end()
{
	// Restore the old stuff, pretty much a wrapper
	draw_state_pop();
}

// ===========================================================================================================
// Effect utility functions
// ===========================================================================================================

/// @self									
/// @description						Function that applies alpha dither shader
/// @param {Real} dither_amount			The precentage of the dither amount (Range of 0.0 - 1.0)
function effect_set_alpha_dither(dither_amount)
{
	//Get the shader uniform
	var uniform_alpha = shader_get_uniform(shd_alpha_dither, "dAlpha");
	
	//Set the shader itself
	shader_set(shd_alpha_dither);

	//Set the shader uniform
	shader_set_uniform_f(uniform_alpha, dither_amount);
}

/// @self									
/// @description						Function that creates chaotix styled dust destruction effect
/// @param {Real} [type]				The type of the dust effect
function effect_create_dust(t = 0)
{
	//Setup the effect
	var obj = instance_create_depth(x, y, depth, obj_dust_effect, {sprite_index : other.sprite_index});
	obj.frame = image_index;
	obj.type = t;
	
	//Destroy the object
	instance_destroy();	
}

/// @self									
/// @description						Function that applies the palette swap shader
/// @param {Asset.GMSprite} texture		The sprite texture of the palette origin and palette that will get swapped (First column is the origin color)
/// @param {Real} index					The palette collumn offset index in the sprite image
function effect_set_palette(texture, index)
{
	 
	//Get the shader
	var shader = shd_color_replacer;
	
	//Get shader uniforms
	var sampled_id = shader_get_sampler_index(shader, "u_sPalette");
	var u_coords = shader_get_uniform(shader, "u_vPalcoords");
	var u_size = shader_get_uniform(shader, "u_vSize");
	var u_index = shader_get_uniform(shader, "u_fIndex");
	var u_tolerance = shader_get_uniform(shader, "u_fTolerance");
	
	//Get values for shader
	var tex = sprite_get_texture(texture, 0);
	var coords = texture_get_uvs(tex);
	var size_w = texture_get_texel_width(tex);
	var size_h = texture_get_texel_height(tex);
	var tolerance = 0.004;
	
	//Get sprite height
	var height = sprite_get_height(texture)
	
	//Set the shader
	shader_set(shader);
	var ind
	ind = index mod (height-1);
	//ind = max(ind, 1);
	
	//Set the shader uniforms
	texture_set_stage(sampled_id, tex);
	shader_set_uniform_f(u_coords, coords[0], coords[1], coords[2], coords[3]);
	shader_set_uniform_f(u_size, size_w, size_h);
	shader_set_uniform_f(u_index, ind + 1);
	shader_set_uniform_f(u_tolerance, tolerance);
}

/// @self									
/// @description						Function that applies the LUT color grading shader
/// @param {Asset.GMSprite} texture		The sprite texture of the LUT (Note: the texture MUST be on the separate texture page)
/// @param {Real} size					The height of the LUT texture
function effect_set_color_grading(texture, size)
{
	//Get the shader that will be used
	var shader = shd_color_grading
	
	//Get shader uniforms
	var u_lut_tex = shader_get_sampler_index(shader, "lut_tex");
	var u_size = shader_get_uniform(shader, "size");
	
	//Get LUT texture
	var lut_tex	= sprite_get_texture(texture, 0);
	
	//Set the shader
	shader_set(shader);
	
	//Set shader uniforms
	shader_set_uniform_f(u_size, size);
	texture_set_stage(u_lut_tex, lut_tex);
}

/// @self									
/// @description						Function that applies a scanline deformation, this is mostly targetted towards surfaces
/// @param {Real} width					The texture width
/// @param {Real} height				The texture height
/// @param {Array} deform_data			The scanline offset deformation data (Note: In the shader the maximum array limit is 512, this can be increased by editing the shader)
/// @param {Real} offset				The scanline deformation offset of the deformation table
/// @param {Real} [mode]				This is the used to set the scanline offset direction (The default is 0)
/// @param {Real} [dir]					This is the used to set the scanline direction (The default is 0)
function effect_surface_deform(width, height, deform_data, offset, mode = 0, dir = 0)
{
	//Surface deform argument description
	/*
		width - The width of the surface;
		height - The height of the surface;
		deform_data - an array of line offsets
		offset - offset for the lines to move (Apply camera position so scrolling won't be weird)
		mode - mode 0 is for horizontal line offset and mode 1 is for vertical line offset
	*/

	//Get the shader uniforms
	var dist = shader_get_uniform(shd_line_dist, "dist");
	var size = shader_get_uniform(shd_line_dist, "size");
	var array_size = shader_get_uniform(shd_line_dist, "array_size");
	var off = shader_get_uniform(shd_line_dist, "offset");
	var m = shader_get_uniform(shd_line_dist, "mode");
	var d = shader_get_uniform(shd_line_dist, "direction");
	
	//Apply the shader
	shader_set(shd_line_dist);
	
	//Apply the shader uniforms
	shader_set_uniform_f_array(dist, deform_data);
	shader_set_uniform_f(size, width, height);
	shader_set_uniform_f(off, offset);
	shader_set_uniform_f(m, mode);
	shader_set_uniform_f(d, dir);
	shader_set_uniform_f(array_size, array_length(deform_data));
}